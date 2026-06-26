# SIS Mobile Flutter - Launch Script
# Execute este script no PowerShell do Windows:
#   powershell -ExecutionPolicy Bypass -File tool\run_flutter.ps1

Write-Host "=== SIS Mobile Flutter - Launch App ===" -ForegroundColor Cyan
Set-Location $PSScriptRoot\..

# Verificar Flutter
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "ERRO: Flutter nao encontrado no PATH." -ForegroundColor Red
    Write-Host "Instale Flutter ou adicione ao PATH do Windows." -ForegroundColor Yellow
    exit 1
}

Write-Host "Flutter: $($flutterCmd.Source)" -ForegroundColor Green
Write-Host "Directory: $(Get-Location)" -ForegroundColor Gray

# Verificar .env
if (Test-Path ".env") {
    Write-Host ".env: carregado" -ForegroundColor Green
} else {
    Write-Host "AVISO: .env nao encontrado" -ForegroundColor Yellow
}

Write-Host "`n=== Iniciando app no Chrome ===" -ForegroundColor Cyan
flutter run -d chrome --web-renderer html