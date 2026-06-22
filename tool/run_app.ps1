# Script para rodar o SIS Mobile Flutter no Chrome
# Executar: powershell -ExecutionPolicy Bypass -File tool\run_app.ps1

Write-Host "=== SIS Mobile Flutter - Launch App ===" -ForegroundColor Cyan

# Verificar Flutter
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "ERRO: Flutter nao encontrado no PATH. Verifique a instalacao." -ForegroundColor Red
    exit 1
}

Write-Host "Flutter encontrado: $($flutterCmd.Source)" -ForegroundColor Green

# Verificar se/.env existe
$envFile = ".env"
if (Test-Path $envFile) {
    Write-Host "Arquivo .env encontrado - configuracoes de runtime serao carregadas" -ForegroundColor Green
} else {
    Write-Host "AVISO: Arquivo .env nao encontrado. Copie .env.example para .env e configure." -ForegroundColor Yellow
}

# Rodar no Chrome
Write-Host "`nIniciando app no Chrome..." -ForegroundColor Cyan
flutter run -d chrome --web-renderer html