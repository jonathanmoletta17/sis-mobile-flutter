# Handoff Mobile -> Hub

## Objetivo

Definir o que pertence a este repositorio mobile e o que pertence ao Hub
Operacional Web na disponibilizacao de QR Code e download de APKs.

## Separacao de responsabilidades

### Responsabilidade deste repo mobile

- manter a identidade visual dos apps mobile e seus assets de launcher
- gerar APKs instalaveis para SIS e DTIC
- padronizar nomes de artefatos para publicacao
- produzir metadados minimos de handoff para o Hub
- manter RH e DMP apenas como linha futura, sem prometer APK inexistente

### Responsabilidade do Hub Operacional Web

- hospedar os APKs em URL realmente publica para o celular
- nunca gerar QR Code com `127.0.0.1`, `localhost` ou `window.location.origin`
  quando a origem for local de desenvolvimento
- usar URL absoluta de download por app
- exibir SIS e DTIC como disponiveis
- exibir RH e DMP como `coming_soon`/indisponiveis
- renderizar QR Code, link clicavel e estados visuais da vitrine de apps

## Causa do problema observado

O QR Code do Hub foi gerado a partir de origem local (`127.0.0.1`), o que no
celular aponta para o proprio aparelho e nao para o PC/Hub. Alem disso, os APKs
esperados em `/downloads/mobile/*.apk` ainda nao estavam servidos pelo Hub.

Esse problema nao se corrige no app Flutter. Ele se corrige no Hub e na forma
de publicar os artefatos.

## Contrato de artefatos para o Hub

O Hub deve consumir os APKs publicados com estes nomes:

- `/downloads/mobile/sis-mobile.apk`
- `/downloads/mobile/dtic-mobile.apk`
- `/downloads/mobile/sis-mobile.apk.sha256`
- `/downloads/mobile/dtic-mobile.apk.sha256`
- `/downloads/mobile/mobile-apps.json`

O manifesto `mobile-apps.json` deve informar:

- `generatedAt`
- `channel`
- `version`
- lista de apps com `id`, `name`, `status` e `downloadPath`

## Script de export

Depois de gerar os APKs, exporte o handoff com:

```bash
tool/android/export_hub_download_artifacts.sh release
```

Ou, para uma rodada de teste local:

```bash
tool/android/export_hub_download_artifacts.sh debug
```

Destino padrao:

```text
output/hub-mobile-downloads/downloads/mobile/
```

Esse diretorio e o pacote de handoff para o Hub. O Hub pode copiar esses
arquivos para seu `public/downloads/mobile` ou para storage/CDN equivalente.

## Pre-condicoes

- SIS release deve existir em `build/app/outputs/flutter-apk/app-sis-release.apk`
- DTIC release deve existir em `build/app/outputs/flutter-apk/app-dtic-release.apk`

Para builds release no fluxo canonico Windows host:

```powershell
.\tool\android\build_release.ps1 -App sis
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local
```

## Estado atual

- SIS e DTIC ja possuem icones Android atualizados neste repo
- RH e DMP existem apenas como direcao visual futura
- a vitrine de download, QR Code e hospedagem publica pertencem ao Hub
