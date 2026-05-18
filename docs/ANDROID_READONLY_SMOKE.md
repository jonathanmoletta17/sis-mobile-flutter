# Android read-only smoke - SIS/DTIC Mobile

Data: 2026-05-18

Este procedimento valida instalacao, abertura e validacao local de login dos APKs SIS/DTIC sem credenciais e sem qualquer acao mutavel no GLPI.

## Escopo seguro

O smoke executa apenas:

1. valida hash/integridade dos APKs;
2. inspeciona o `.env` publico embutido;
3. sobe AVD Android headless;
4. instala SIS e DTIC;
5. abre cada app;
6. captura screenshot da tela de login;
7. toca `Entrar` com campos vazios;
8. captura screenshot da validacao local;
9. coleta dumpsys/logcat;
10. encerra o emulador e restaura permissao temporaria de KVM.

Nao executa:

- login GLPI;
- `initSession`;
- leitura autenticada de tickets;
- criacao de ticket;
- followup;
- anexo;
- alteracao de status;
- solucao/aprovacao/recusa;
- `DELETE`, purge ou cleanup.

## Comando

```bash
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
./tool/android/readonly_smoke_android.sh --allow-kvm-chmod
```

O flag `--allow-kvm-chmod` permite temporariamente acesso ao `/dev/kvm` quando o usuario nao esta no grupo `kvm`. O script restaura o modo original no final.

Para manter o emulador aberto para inspecao manual:

```bash
./tool/android/readonly_smoke_android.sh --allow-kvm-chmod --keep-emulator
```

## Variaveis opcionais

```bash
AVD_NAME=hermes_sis_mobile_api35
ANDROID_HOME=/home/jonathan/Android/Sdk
ANDROID_AVD_HOME=/home/jonathan/.android/avd
SIS_APK=/mnt/c/Users/jonathan-moletta/ops/sis-mobile/sis-mobile-release-worker-status-rules-public-20260518.apk
DTIC_APK=/mnt/c/Users/jonathan-moletta/ops/dtic-mobile/dtic-mobile-release-worker-status-rules-public-20260518.apk
OUT_DIR=/home/jonathan/.brain/evidence/sis-mobile/android-smoke-YYYYMMDD-HHMMSS
```

## Evidencias geradas

Exemplo de saida validada:

```text
/home/jonathan/.brain/evidence/sis-mobile/android-smoke-20260518-061923/
```

Arquivos principais:

```text
summary.txt
context.txt
apk-sha256.txt
apk-public-env.txt
apk-badging.txt
device.txt
packages.txt
sis-login.png
sis-empty-login-validation.png
dtic-login.png
dtic-empty-login-validation.png
sis-package-dumpsys.txt
dtic-package-dumpsys.txt
sis-logcat-tail.txt
dtic-logcat-tail.txt
emulator.log
```

## Resultado esperado

`summary.txt` deve conter:

```text
READ-ONLY ANDROID SMOKE PASSED
No credentials used.
No GLPI login/initSession executed.
No ticket/followup/attachment/status/solution/DELETE/purge/cleanup executed.
SIS and DTIC installed and launched.
Empty-form validation screenshots captured.
No FATAL EXCEPTION / Force finishing / Fatal signal found in captured app logcat tails.
```

## Evidencia visual esperada

SIS:

- tela `GLPI SIS`;
- campos `Usuario GLPI` e `Senha`;
- botao `Entrar`;
- ao submeter vazio: `O nome de usuario e obrigatorio` e `A senha e obrigatoria`.

DTIC:

- tela `GLPI DTIC` / `DTIC Mobile`;
- campos `Usuario de rede` e `Senha`;
- botao `Entrar`;
- ao submeter vazio: `Informe o usuario.` e `Informe a senha.`.

## Gates restantes

Este smoke nao substitui a validacao autenticada. Para avancar alem da tela de login, e obrigatorio Gate D explicito com escopo aprovado:

- pode ou nao fazer login real;
- usuario autorizado;
- se pode criar ticket sintetico;
- prefixo do ticket sintetico;
- acoes permitidas;
- proibicao de tocar tickets fora do prefixo;
- criterio de abort.
