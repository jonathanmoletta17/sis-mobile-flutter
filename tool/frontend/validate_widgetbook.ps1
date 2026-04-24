[CmdletBinding()]
param(
    [switch]$UpdateGoldens,
    [switch]$SkipBuild,
    [string]$FlutterPath
)

$ErrorActionPreference = 'Stop'

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
        & $script:flutter @FlutterArgs
        if ($LASTEXITCODE -ne 0) {
            throw "flutter $($FlutterArgs -join ' ') failed with exit code $LASTEXITCODE"
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
