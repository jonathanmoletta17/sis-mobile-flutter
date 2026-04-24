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

if (-not (Test-Path $resolvedEnvFile)) {
    throw "Arquivo de ambiente nao encontrado: $resolvedEnvFile"
}

$profileArgs = @()
if ($WithTunnel) {
    $profileArgs = @("--profile", "tunnel")
}

Write-Host "Subindo stack de pass-through..."
docker compose --env-file $resolvedEnvFile -f $composeFile @profileArgs up -d

$bindAddress = "127.0.0.1"
$bindPort = "18080"
Get-Content -LiteralPath $resolvedEnvFile | ForEach-Object {
    if ($_ -match '^LOCAL_BIND_ADDRESS=(.+)$') { $bindAddress = $Matches[1].Trim() }
    if ($_ -match '^LOCAL_BIND_PORT=(.+)$') { $bindPort = $Matches[1].Trim() }
}

Write-Host ""
Write-Host "Stack iniciada."
Write-Host "Health local: http://$bindAddress`:$bindPort/healthz"
if ($WithTunnel) {
    Write-Host "Tunnel profile: ativo"
} else {
    Write-Host "Tunnel profile: desativado"
}
