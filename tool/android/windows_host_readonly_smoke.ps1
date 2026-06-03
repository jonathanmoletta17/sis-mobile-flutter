param(
    [Parameter(Mandatory = $true)]
    [string]$Apk,
    [string]$Package = "br.gov.rs.casacivil.sismobile",
    [string]$Activity = "br.gov.rs.casacivil.sismobile.MainActivity",
    [string]$OutDir = "$env:USERPROFILE\ops\sis-mobile\android-smoke-$(Get-Date -Format yyyyMMdd-HHmmss)",
    [switch]$Install,
    [switch]$ClearAppData
)

$ErrorActionPreference = "Stop"

function Resolve-CommandPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string[]]$Fallbacks = @()
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    foreach ($fallback in $Fallbacks) {
        if ($fallback -and (Test-Path $fallback)) { return (Resolve-Path $fallback).ProviderPath }
    }

    throw "$Name nao encontrado. Fallbacks testados: $($Fallbacks -join ', ')"
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Exe,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    & $Exe @Arguments 2>&1 | Tee-Object -FilePath $script:RunLog -Append
    $exitCode = if ($global:LASTEXITCODE -is [int]) { $global:LASTEXITCODE } else { 0 }
    if ($exitCode -ne 0) {
        throw "Comando falhou com exit code ${exitCode}: $Exe $($Arguments -join ' ')"
    }
}

# Evita warnings/falhas de ferramentas Windows quando PowerShell foi iniciado
# a partir de cwd UNC (\\wsl.localhost\...).
Set-Location $env:TEMP
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$script:RunLog = Join-Path $OutDir "run.log"

$adb = Resolve-CommandPath -Name "adb.exe" -Fallbacks @(
    "$env:USERPROFILE\Android\Sdk\platform-tools\adb.exe",
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
)
$aapt = Resolve-CommandPath -Name "aapt.exe" -Fallbacks @(
    "$env:USERPROFILE\Android\Sdk\build-tools\36.0.0\aapt.exe",
    "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.0.0\aapt.exe"
)

$apkPath = (Resolve-Path $Apk).ProviderPath
if (-not (Test-Path $apkPath)) { throw "APK nao encontrado: $Apk" }

@(
    "host=$env:COMPUTERNAME",
    "user=$env:USERNAME",
    "adb=$adb",
    "aapt=$aapt",
    "apk=$apkPath",
    "package=$Package",
    "activity=$Activity",
    "out_dir=$OutDir",
    "scope=read-only Android host smoke: sem credenciais, sem initSession, sem mutacao GLPI"
) | Set-Content -Encoding UTF8 (Join-Path $OutDir "context.txt")

Get-FileHash $apkPath -Algorithm SHA256 | Format-List | Out-File -Encoding UTF8 (Join-Path $OutDir "apk-sha256.txt")
& $aapt dump badging $apkPath |
    Select-String "^package:|^sdkVersion:|^targetSdkVersion:|^application-label:'|^launchable-activity:" |
    ForEach-Object { $_.Line } |
    Set-Content -Encoding UTF8 (Join-Path $OutDir "apk-badging.txt")

Invoke-Checked $adb start-server
$devicesRaw = & $adb devices -l
$devicesRaw | Set-Content -Encoding UTF8 (Join-Path $OutDir "adb-devices.txt")
$serial = ($devicesRaw | Select-String "\tdevice\b" | Select-Object -First 1).Line -replace "\s+.*$", ""
if (-not $serial) {
    throw "Nenhum Android device/emulator autorizado encontrado pelo adb.exe do Windows. Abra/inicie o emulador no host e rode novamente. Evidencia: $OutDir\adb-devices.txt"
}

if ($Install) {
    Invoke-Checked $adb -s $serial install -r $apkPath
}

if ($ClearAppData) {
    Invoke-Checked $adb -s $serial shell pm clear $Package
}

Invoke-Checked $adb -s $serial shell am force-stop $Package
Invoke-Checked $adb -s $serial shell logcat -c
Invoke-Checked $adb -s $serial shell am start -n "$Package/$Activity"
Start-Sleep -Seconds 8

Invoke-Checked $adb -s $serial shell screencap -p /sdcard/sis-mobile-smoke.png
Invoke-Checked $adb -s $serial pull /sdcard/sis-mobile-smoke.png (Join-Path $OutDir "login-screen.png")
Invoke-Checked $adb -s $serial shell rm /sdcard/sis-mobile-smoke.png
Invoke-Checked $adb -s $serial shell dumpsys window
& $adb -s $serial shell dumpsys package $Package |
    Select-String "Package \[|versionName|versionCode|firstInstallTime|lastUpdateTime" |
    ForEach-Object { $_.Line } |
    Set-Content -Encoding UTF8 (Join-Path $OutDir "package-dumpsys.txt")
& $adb -s $serial logcat -d -t 1200 | Set-Content -Encoding UTF8 (Join-Path $OutDir "logcat-tail.txt")

if (Select-String -Path (Join-Path $OutDir "logcat-tail.txt") -Pattern "FATAL EXCEPTION|Force finishing|Fatal signal" -Quiet) {
    throw "Assinatura de crash encontrada no logcat. Veja $OutDir\logcat-tail.txt"
}

@(
    "READ-ONLY WINDOWS ANDROID SMOKE PASSED",
    "serial=$serial",
    "apk=$apkPath",
    "No credentials used.",
    "No GLPI initSession or ticket mutation executed.",
    "Screenshot: $OutDir\login-screen.png"
) | Set-Content -Encoding UTF8 (Join-Path $OutDir "summary.txt")

Write-Host "Read-only Android smoke concluido: $OutDir"
