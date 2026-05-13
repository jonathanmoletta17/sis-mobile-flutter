# SIS Mobile Android - Playbook de Distribuicao

## Objetivo
Padronizar build release, piloto em dispositivos reais e distribuicao interna do app SIS Mobile.

## 1) Pre-requisitos
- Flutter Windows instalado e disponivel no `PATH` do Windows ou via `FLUTTER_ROOT`.
- Android Studio + Android SDK instalados no Windows host.
- `adb` disponivel no Windows (`where adb` deve localizar `platform-tools\adb.exe`).
- Acesso de rede ao GLPI SIS (`GLPI_BASE_URL`).
- Keystore de assinatura release (obrigatorio para distribuicao oficial).
- Flutter, Android SDK e PowerShell sao dependencias de build no Windows host; a fonte canonica do app permanece na raiz WSL do repo.
- Nao exigir PowerShell, Android SDK ou `ANDROID_HOME` dentro da WSL.
- Nao versionar `.env`, `android/key.properties`, keystores, secrets ou outputs de build.
- Nesta maquina, os caminhos Windows validados sao:
  - Flutter: `C:\Users\jonathan-moletta\tools\flutter`
  - Android SDK: `C:\Users\jonathan-moletta\Android\Sdk`
  - JDK: `C:\Program Files\Microsoft\jdk-21.0.10.7-hotspot`

Raiz WSL canonica:

```text
/home/jonathan/projects/work/mobile/sis-mobile-flutter
```

Caminho Windows para operar o mesmo workspace pelo host:

```text
\\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
```

## 1.1) Diagnostico do host Windows

Execute no Windows host, nao dentro da WSL:

```powershell
where flutter
where adb
flutter doctor -v
adb devices
flutter devices
```

Se `where adb` nao encontrar nada, configure o `PATH` do Windows para incluir o `platform-tools` real do Android SDK, por exemplo:

```powershell
$env:Path += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"
```

Para persistir a configuracao, ajuste as variaveis de ambiente do Windows ou use:

```powershell
setx ANDROID_HOME "$env:LOCALAPPDATA\Android\Sdk"
setx ANDROID_SDK_ROOT "$env:LOCALAPPDATA\Android\Sdk"
setx PATH "$env:Path;$env:LOCALAPPDATA\Android\Sdk\platform-tools"
```

O caminho real do SDK pode variar. Confirme no Android Studio em `Settings > Languages & Frameworks > Android SDK`.

## 1.2) Papel da WSL

Use a WSL para:

```bash
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Use o Windows host para Android:

```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
flutter run -d android
.\tool\android\build_release.ps1
```

`adb.exe` do Windows pode ser exposto a WSL apenas para diagnostico avancado de dispositivo, mas `adb` sozinho nao substitui Android SDK/build-tools para compilar APK/AAB com Flutter Linux. Sem SDK Android compativel com Linux na WSL, build/run Android permanece no Windows host.

Se Gradle/Java falhar operando direto sobre o caminho UNC do WSL, use um espelho operacional Windows temporario. Isso nao move a fonte canonica; apenas cria um workspace de build host-native:

```bash
rm -rf /mnt/c/Users/jonathan-moletta/build-mirrors/sis-mobile-flutter
mkdir -p /mnt/c/Users/jonathan-moletta/build-mirrors/sis-mobile-flutter
tar \
  --exclude='./.git' \
  --exclude='./.dart_tool' \
  --exclude='./build' \
  --exclude='./android/.gradle' \
  --exclude='./android/key.properties' \
  --exclude='./android/keystore-secrets.txt' \
  --exclude='./android/keystores' \
  --exclude='./android/local.properties' \
  --exclude='./widgetbook/.dart_tool' \
  --exclude='./widgetbook/build' \
  -cf - . | tar -xf - -C /mnt/c/Users/jonathan-moletta/build-mirrors/sis-mobile-flutter
```

Depois, no Windows host:

```powershell
cd C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter
.\tool\android\build_release.ps1
```

Nao edite codigo-fonte no espelho. Para distribuicao oficial assinada, configure assinatura release de forma local e segura, sem versionar `android/key.properties` ou keystores.

## 2) Gerar keystore release (uma unica vez)
Execute no PowerShell do Windows host:

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
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
.\tool\android\build_release.ps1
```

AAB (Play/loja):

```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
.\tool\android\build_release.ps1 -Aab
```

DTIC:

```powershell
cd \\wsl.localhost\Ubuntu-24.04\home\jonathan\projects\work\mobile\sis-mobile-flutter
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local
```

`.env.dtic.local` deve apontar para o Worker DTIC e nao deve conter `App-Token`.

## 5) Instalacao em dispositivo real (piloto)
1. Ative `Opcoes do desenvolvedor` e `Depuracao USB` no Android.
2. Conecte via USB.
3. Instale o APK gerado pelo script. Para build com flavor, use o nome impresso
   ao final do comando (`app-sis-release.apk` ou `app-dtic-release.apk`):

```powershell
adb install -r .\build\app\outputs\flutter-apk\app-sis-release.apk
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
