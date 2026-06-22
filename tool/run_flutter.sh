#!/bin/bash
# SIS Mobile Flutter - Launcher
# Execute: ./tool/run_flutter.sh

echo "=== SIS Mobile Flutter - Launch ==="
echo ""
echo "Para rodar o app, execute no Windows PowerShell:"
echo "  powershell -ExecutionPolicy Bypass -File tool\\run_flutter.ps1"
echo ""
echo "Ou manualmente:"
echo "  1. Abra PowerShell no Windows"
echo "  2. Navegue até: $(pwd)"
echo "  3. Execute: flutter run -d chrome --web-renderer html"
echo ""
echo "Pre-flight checks:"

# Verificar Flutter no Windows
if command -v powershell.exe &> /dev/null; then
    echo "[OK] PowerShell disponivel"
else
    echo "[WARN] PowerShell nao encontrado na WSL - execute diretamente no Windows"
fi

# Verificar .env
if [ -f ".env" ]; then
    echo "[OK] .env encontrado"
    grep -E "^(GLPI_BASE_URL|SIS_GLPI_BASE_URL)=" .env | head -2
else
    echo "[ERRO] .env nao encontrado - copie .env.example e configure"
    exit 1
fi

echo ""
echo "=== Pronto para rodar ==="
