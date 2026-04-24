param(
    [string]$EnvFile = ".env.host",
    [switch]$WithTunnel
)

$ErrorActionPreference = "Stop"

$stackDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$composeFile = Join-Path $stackDir "docker-compose.yml"

if ([System.IO.Path]::IsPathRooted($EnvFile)) {
    $resolvedEnvFile = $EnvFile
} else {
    $resolvedEnvFile = Join-Path $stackDir $EnvFile
}

$profileArgs = @()
if ($WithTunnel) {
    $profileArgs = @("--profile", "tunnel")
}

Write-Host "Parando stack de pass-through..."
if (Test-Path $resolvedEnvFile) {
    docker compose --env-file $resolvedEnvFile -f $composeFile @profileArgs down
} else {
    Write-Warning "Arquivo de ambiente nao encontrado: $resolvedEnvFile"
    Write-Warning "Executando docker compose down sem env-file explicito."
    docker compose -f $composeFile @profileArgs down
}
