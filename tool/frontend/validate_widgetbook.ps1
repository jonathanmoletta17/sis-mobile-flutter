[CmdletBinding()]
param(
    [switch]$UpdateGoldens,
    [switch]$SkipBuild,
    [string]$FlutterPath
)

$ErrorActionPreference = 'Stop'

$windowsRoot = if ($env:WINDIR) { $env:WINDIR } else { 'C:\Windows' }
$script:baseWindowsPath = (@(
    (Join-Path $windowsRoot 'System32'),
    $windowsRoot,
    (Join-Path $windowsRoot 'System32\Wbem'),
    (Join-Path $windowsRoot 'System32\WindowsPowerShell\v1.0'),
    'C:\Program Files\Git\cmd',
    'C:\Program Files\Git\bin'
) -join ';')
$env:Path = $script:baseWindowsPath

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$widgetbookRoot = Join-Path $repoRoot 'widgetbook'

if (-not (Test-Path -LiteralPath $widgetbookRoot)) {
    throw "Widgetbook root not found: $widgetbookRoot"
}

function Resolve-Flutter {
    param([string]$ExplicitPath)

    if ($ExplicitPath) {
        if (-not (Test-Path -LiteralPath $ExplicitPath)) {
            throw "FlutterPath not found: $ExplicitPath"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    $fromPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($fromPath) {
        return $fromPath.Source
    }

    $fallback = Join-Path $repoRoot '..\tools\flutter\bin\flutter.bat'
    if (Test-Path -LiteralPath $fallback) {
        return (Resolve-Path -LiteralPath $fallback).Path
    }

    throw 'Flutter executable not found. Pass -FlutterPath or add flutter to PATH.'
}

function Invoke-Flutter {
    param([string[]]$FlutterArgs)

    Push-Location $widgetbookRoot
    try {
        $cmd = Join-Path $windowsRoot 'System32\cmd.exe'
        $quotedFlutter = '"' + $script:flutter + '"'
        $quotedArgs = ($FlutterArgs | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join ' '
        $flutterDir = Split-Path -Parent $script:flutter
        $runner = Join-Path ([IO.Path]::GetTempPath()) "sis-widgetbook-$([Guid]::NewGuid()).cmd"
        $runnerLines = @(
            '@echo off',
            ('set "PATH=' + $script:baseWindowsPath + ';' + $flutterDir + '"'),
            'set "PATHEXT=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC"',
            ('cd /d "' + $widgetbookRoot + '"'),
            ($quotedFlutter + ' ' + $quotedArgs),
            'exit /b %ERRORLEVEL%'
        )
        Set-Content -LiteralPath $runner -Value $runnerLines -Encoding ASCII
        $process = Start-Process `
            -FilePath $cmd `
            -ArgumentList @('/d', '/c', $runner) `
            -NoNewWindow `
            -PassThru `
            -Wait
        $exitCode = $process.ExitCode
        Remove-Item -LiteralPath $runner -Force -ErrorAction SilentlyContinue
        if ($exitCode -ne 0) {
            throw "flutter $($FlutterArgs -join ' ') failed with exit code $exitCode"
        }
    } finally {
        Pop-Location
    }
}

$script:flutter = Resolve-Flutter -ExplicitPath $FlutterPath
Write-Host "Using Flutter: $script:flutter"
Write-Host "Widgetbook root: $widgetbookRoot"

Invoke-Flutter @('pub', 'get')
Invoke-Flutter @('analyze')

if ($UpdateGoldens) {
    Write-Host 'Updating Widgetbook visual goldens intentionally.'
    Invoke-Flutter @('test', '--update-goldens')
}

Invoke-Flutter @('test')

if (-not $SkipBuild) {
    Invoke-Flutter @('build', 'web')
}

Write-Host 'Widgetbook visual gate completed.'
