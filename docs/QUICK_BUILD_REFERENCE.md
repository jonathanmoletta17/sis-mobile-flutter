# Build, Test & Validation Quick Reference

Guia consolidado de **todos os comandos** para build, testes e validação do SIS Mobile Flutter.
Consulte aqui antes de pedir.

## Pré-requisito: Configuração

Crie `.env` na raiz (ou copie de `.env.example`):

```env
SIS_GLPI_BASE_URL=http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php
GLPI_DEBUG_LOGS=false
DTIC_GLPI_BASE_URL=... (opcional, se testar DTIC)
SIS_TEST_USER=...
SIS_TEST_PASSWORD=...
SIS_TEST_ADMIN_USER=...
SIS_TEST_ADMIN_PASSWORD=...
GLPI_APP_TOKEN=...
```

Após criar `.env`, execute uma única vez:

```bash
/opt/flutter/bin/flutter pub get
```

---

## WEB DEV (PWA local com hot reload)

### SIS — Porta 8083
```bash
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083
```
→ Acesse: **http://localhost:8083**

### DTIC — Porta 8084
```bash
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
/opt/flutter/bin/flutter run -t lib/main_dtic.dart -d web-server --web-hostname 127.0.0.1 --web-port 8084
```
→ Acesse: **http://localhost:8084**

---

## ANDROID DEV (emulator ou dispositivo físico)

**Local:** Windows host (WSL pode acompanhar por git, mas build/run é Windows-only)

### Pré-check
```powershell
flutter doctor -v
adb devices
flutter devices
```

### SIS
```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
flutter run --flavor sis -t lib/main.dart -d android
```

### DTIC
```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
flutter run --flavor dtic -t lib/main_dtic.dart -d android
```

---

## ANDROID RELEASE BUILD (APK para distribuição)

**Local:** Windows host  
**Saída:** `build/app/outputs/flutter-apk/app-release.apk` e `build/app/outputs/bundle/release/app-release.aab`

### SIS Release (padrão)
```powershell
cd \path\to\sis-mobile-flutter
.\tool\android\build_release.ps1
```

### SIS Release com endpoint customizado
```powershell
.\tool\android\build_release.ps1 -GlpiBaseUrl https://seu-host/sis/apirest.php
```

### SIS Release com arquivo .env específico
```powershell
.\tool\android\build_release.ps1 -EnvFile .env.prod
```

### DTIC Release
```powershell
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local
```

### App Bundle para Play Store (SIS)
```powershell
.\tool\android\build_release.ps1 -Aab
```

### App Bundle para Play Store (DTIC)
```powershell
.\tool\android\build_release.ps1 -App dtic -Aab
```

**Opções combinadas:**
```powershell
# DTIC com endpoint customizado e gerar bundle
.\tool\android\build_release.ps1 -App dtic -GlpiBaseUrl https://dtic-prod/apirest.php -Aab
```

Veja `docs/android-distribution-playbook.md` para instruções pós-build (upload Play Store, distribuição beta, etc).

---

## TESTES E VALIDAÇÃO

### Análise (linting + type check)
```bash
/opt/flutter/bin/flutter analyze
```

### Testes unitários + widget
```bash
/opt/flutter/bin/flutter test
```

### Ambos juntos
```bash
/opt/flutter/bin/flutter analyze && /opt/flutter/bin/flutter test
```

### Teste específico
```bash
/opt/flutter/bin/flutter test test/service_catalog_repository_test.dart
```

### Teste com output verboso
```bash
/opt/flutter/bin/flutter test --verbose
```

---

## WIDGETBOOK (Lab visual Flutter)

### Build Widgetbook locally (WSL)
```bash
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter/widgetbook
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter build web
# Saída em: widgetbook/build/web/
```

### Validar & atualizar goldens (Windows)
```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

### Atualizar goldens
```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

---

## SMOKE TESTS (Android validação read-only)

### Smoke test padrão (Windows)
```powershell
.\tool\android\readonly_smoke_android.sh --sis-apk build/app/outputs/flutter-apk/app-release.apk
```

### Com emulator customizado
```powershell
.\tool\android\readonly_smoke_android.sh --sis-apk build/app/outputs/flutter-apk/app-release.apk --keep-emulator
```

Veja `docs/ANDROID_READONLY_SMOKE.md` para opções completas.

---

## FLUXO RECOMENDADO: Mudança Não-Trivial

1. **Desenvolver em WSL**
   ```bash
   /opt/flutter/bin/flutter analyze
   /opt/flutter/bin/flutter test
   ```

2. **Testar web localmente (WSL)**
   ```bash
   /opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083
   ```

3. **Testar Android no Windows**
   ```powershell
   flutter run --flavor sis -t lib/main.dart -d android
   ```

4. **Build release APK (Windows)**
   ```powershell
   .\tool\android\build_release.ps1
   ```

5. **Validar visualmente (Widgetbook)**
   ```powershell
   powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
   ```

---

## TROUBLESHOOTING RÁPIDO

| Problema | Solução |
|----------|---------|
| `flutter: command not found` (WSL) | Use `/opt/flutter/bin/flutter` ou adicione ao PATH |
| `Gradle failed` (Windows) | Copie projeto para `C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter` como espelho temporário |
| `.env` ausente | Crie `echo "SIS_GLPI_BASE_URL=..." > .env` na raiz |
| Web port already in use | Use `--web-port 8085` (ou outra porta) |
| Android device not found | Execute `adb devices` e verifique conexão USB ou emulator |
| Goldens mismatch | Execute `validate_widgetbook.ps1 -UpdateGoldens` no Windows |

---

## Documentação Relacionada

- **BOOTSTRAP.md** — Visão geral de runtime híbrido WSL + Windows
- **README.md** — Escopo, requisitos, configuração
- **docs/android-distribution-playbook.md** — Release, Play Store, distribuição
- **docs/WIDGETBOOK_WORKBENCH.md** — Operação do lab visual em profundidade
- **docs/ANDROID_READONLY_SMOKE.md** — Smoke tests e validação APK
- **docs/quality/DOR.md** — Definition of Ready (antes de implementar)
- **docs/quality/DOD.md** — Definition of Done (antes de declarar pronto)
