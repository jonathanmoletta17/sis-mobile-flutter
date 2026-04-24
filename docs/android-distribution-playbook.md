# SIS Mobile Android - Playbook de Distribuicao

## Objetivo
Padronizar build release, piloto em dispositivos reais e distribuicao interna do app SIS Mobile.

## 1) Pre-requisitos
- Flutter e Android SDK instalados.
- Acesso de rede ao GLPI SIS (`GLPI_BASE_URL`).
- Keystore de assinatura release (obrigatorio para distribuicao oficial).

## 2) Gerar keystore release (uma unica vez)
Execute no PowerShell:

```powershell
New-Item -ItemType Directory -Path .\keystores -Force | Out-Null
keytool -genkeypair `
  -v `
  -keystore .\keystores\sis-mobile-upload.jks `
  -alias sis-mobile `
  -keyalg RSA `
  -keysize 2048 `
  -validity 3650
```

## 3) Configurar assinatura
1. Copie `android/key.properties.example` para `android/key.properties`.
2. Ajuste `storeFile`, `storePassword`, `keyAlias`, `keyPassword`.

## 4) Build release
APK:

```powershell
.\tool\android\build_release.ps1
```

AAB (Play/loja):

```powershell
.\tool\android\build_release.ps1 -Aab
```

## 5) Instalacao em dispositivo real (piloto)
1. Ative `Opcoes do desenvolvedor` e `Depuracao USB` no Android.
2. Conecte via USB.
3. Instale o APK:

```powershell
adb install -r .\build\app\outputs\flutter-apk\app-release.apk
```

## 6) Canais de distribuicao recomendados
1. Piloto rapido: APK via USB/compartilhamento interno.
2. Operacao corporativa: MDM (Intune/Workspace ONE/afim).
3. Esteira de atualizacao: Google Play em trilha fechada (internal/closed).

## 7) Checklist de entrada em producao
- Assinatura release ativa (sem chave debug).
- Versao do app incrementada (`version` no `pubspec.yaml`).
- Homologacao com usuarios reais SIS.
- Conectividade validada no ambiente corporativo (rede interna ou VPN).
- Plano de rollback definido (versao anterior assinada).

## 8) Nota sobre emulador (digitação)
No Android Emulator, habilite `Extended controls > Settings > Enable keyboard input` para digitar com teclado fisico.
