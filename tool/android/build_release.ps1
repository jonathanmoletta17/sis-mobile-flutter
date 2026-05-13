param(
    [switch]$Aab,
    [switch]$Clean,
    [ValidateSet("sis", "dtic")]
    [string]$App = "sis",
    [string]$GlpiBaseUrl,
    [string]$EnvFile,
    [string]$GlpiDebugLogs = "false"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $repoRoot

function Test-JdkHome {
    param(
        [string]$Path
    )

    if (-not $Path) {
        return $false
    }

    $javaExe = Join-Path $Path "bin\java.exe"
    $javacExe = Join-Path $Path "bin\javac.exe"
    return (Test-Path $javaExe) -and (Test-Path $javacExe)
}

function Get-JdkCandidates {
    param(
        [string]$RepoRoot
    )

    $candidates = New-Object System.Collections.Generic.List[string]

    $staticCandidates = @(
        $env:JAVA_HOME,
        (Join-Path $RepoRoot "tool\android\runtime\jdk17\jdk-17.0.18+8"),
        (Join-Path $RepoRoot "tool\android\runtime\jdk17"),
        "C:\Program Files\Android\Android Studio\jbr",
        "C:\Program Files\Java\latest",
        "C:\Program Files\Java\jdk-21",
        "C:\Program Files\Java\jdk-17",
        "C:\Program Files\Eclipse Adoptium"
    ) | Where-Object { $_ }

    foreach ($candidate in $staticCandidates) {
        if (-not $candidates.Contains($candidate)) {
            $candidates.Add($candidate)
        }
    }

    $dynamicRoots = @(
        (Join-Path $RepoRoot "tool\android\runtime"),
        "C:\Program Files\Java",
        "C:\Program Files\Eclipse Adoptium"
    )

    foreach ($root in $dynamicRoots) {
        if (-not (Test-Path $root)) {
            continue
        }

        Get-ChildItem -Path $root -Directory -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                if (-not $candidates.Contains($_.FullName)) {
                    $candidates.Add($_.FullName)
                }
            }
    }

    return $candidates
}

if ($GlpiBaseUrl -and $EnvFile) {
    throw "Use apenas um entre -GlpiBaseUrl e -EnvFile."
}

$flavor = $App.ToLowerInvariant()
$targetFile = if ($flavor -eq "dtic") { "lib/main_dtic.dart" } else { "lib/main.dart" }

$envPath = Join-Path $repoRoot ".env"
$originalEnvExists = Test-Path $envPath
$originalEnvBytes = if ($originalEnvExists) {
    [System.IO.File]::ReadAllBytes($envPath)
} else {
    $null
}
$temporaryEnvApplied = $false

function Write-Utf8NoBomFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Set-TemporaryEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    Write-Utf8NoBomFile -Path $envPath -Content $Content
    $script:temporaryEnvApplied = $true
}

function Copy-TemporaryEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath
    )

    [System.IO.File]::Copy($SourcePath, $envPath, $true)
    $script:temporaryEnvApplied = $true
}

function Resolve-RequestedEnvFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestedPath
    )

    if ([System.IO.Path]::IsPathRooted($RequestedPath)) {
        return (Resolve-Path $RequestedPath).Path
    }

    return (Resolve-Path (Join-Path $repoRoot $RequestedPath)).Path
}

if ($GlpiBaseUrl) {
    Write-Host "Aplicando .env temporario para build com URL GLPI customizada..."
    $specificBaseUrlKey = if ($flavor -eq "dtic") { "DTIC_GLPI_BASE_URL" } else { "SIS_GLPI_BASE_URL" }
    $tempEnvContent = @(
        "GLPI_BASE_URL=$GlpiBaseUrl"
        "$specificBaseUrlKey=$GlpiBaseUrl"
        "GLPI_DEBUG_LOGS=$GlpiDebugLogs"
        ""
    ) -join [Environment]::NewLine
    Set-TemporaryEnvFile -Content $tempEnvContent
} elseif ($EnvFile) {
    $resolvedEnvFile = Resolve-RequestedEnvFile -RequestedPath $EnvFile
    Write-Host "Aplicando .env temporario a partir de: $resolvedEnvFile"
    Copy-TemporaryEnvFile -SourcePath $resolvedEnvFile
}

$resolvedJdkHome = $null
$jdkCandidates = Get-JdkCandidates -RepoRoot $repoRoot

foreach ($candidate in $jdkCandidates) {
    if (Test-JdkHome -Path $candidate) {
        $resolvedJdkHome = $candidate
        break
    }
}

if (-not $resolvedJdkHome) {
    throw "Nenhum JDK valido encontrado. Verifique JAVA_HOME ou instale um JDK com java.exe e javac.exe."
}

if ($env:JAVA_HOME -and -not (Test-JdkHome -Path $env:JAVA_HOME)) {
    Write-Warning "JAVA_HOME atual aponta para um caminho invalido: $env:JAVA_HOME"
}

$env:JAVA_HOME = $resolvedJdkHome
if ($env:Path -notlike "$resolvedJdkHome\bin*") {
    $env:Path = "$resolvedJdkHome\bin;$env:Path"
}

Write-Host "Usando JAVA_HOME: $resolvedJdkHome"

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    $candidatePaths = @(
        $(if ($env:FLUTTER_ROOT) { Join-Path $env:FLUTTER_ROOT "bin\\flutter.bat" }),
        "C:\\src\\flutter\\bin\\flutter.bat",
        "C:\\flutter\\bin\\flutter.bat",
        "C:\\Users\\jonathan-moletta\\flutter\\bin\\flutter.bat",
        (Join-Path $repoRoot "tools\flutter\bin\flutter.bat"),
        (Join-Path $repoRoot "..\tools\flutter\bin\flutter.bat")
    ) | Where-Object { $_ }

    $resolved = $candidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($resolved) {
        $flutterCmd = (Resolve-Path $resolved).Path
    } else {
        throw "Flutter nao encontrado no PATH, FLUTTER_ROOT ou nos caminhos esperados (tools\\flutter, ..\\tools\\flutter, C:\\src\\flutter, C:\\flutter, C:\\Users\\jonathan-moletta\\flutter)."
    }
} else {
    $flutterCmd = $flutterCmd.Source
}

$keyProps = Join-Path $repoRoot "android\key.properties"
if (-not (Test-Path $keyProps)) {
    if ($Aab) {
        throw "android/key.properties nao encontrado. Build AAB exige assinatura release valida."
    }

    Write-Warning "android/key.properties nao encontrado. O build APK release assinara com chave debug (fallback)."
    Write-Warning "Para distribuicao oficial, configure android/key.properties (ver android/key.properties.example)."
}

try {
    if ($Clean) {
        & $flutterCmd clean
    }

    & $flutterCmd pub get

    if ($Aab) {
        & $flutterCmd build appbundle --release --flavor $flavor -t $targetFile
        $artifactCandidates = @(
            (Join-Path $repoRoot ("build\app\outputs\bundle\{0}Release\app-{0}-release.aab" -f $flavor)),
            (Join-Path $repoRoot "build\app\outputs\bundle\release\app-release.aab")
        )
    } else {
        & $flutterCmd build apk --release --flavor $flavor -t $targetFile
        $artifactCandidates = @(
            (Join-Path $repoRoot ("build\app\outputs\flutter-apk\app-{0}-release.apk" -f $flavor)),
            (Join-Path $repoRoot "build\app\outputs\flutter-apk\app-release.apk")
        )
    }

    $artifact = $artifactCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $artifact) {
        throw "Artefato nao encontrado. Candidatos: $($artifactCandidates -join ', ')"
    }

    Write-Host ""
    Write-Host "Build concluido com sucesso para app/flavor: $flavor"
    Write-Host $artifact
} finally {
    if ($temporaryEnvApplied) {
        if ($originalEnvExists) {
            [System.IO.File]::WriteAllBytes($envPath, $originalEnvBytes)
        } elseif (Test-Path $envPath) {
            Remove-Item -LiteralPath $envPath -Force
        }
    }
}
