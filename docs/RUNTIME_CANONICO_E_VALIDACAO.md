# Runtime Canonico e Validacao

## Escopo

Este documento define o que hoje e considerado suportado e mantido neste repositorio para operacao local, validacao e distribuicao Android.

## Runtime suportado

O projeto suporta hoje um unico app Flutter com dois modos principais de execucao local:

- web local para desenvolvimento:
  - `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
- Android local:
  - `flutter run -d android`

Configuracao de ambiente:

- arquivo: `.env`
- exemplo versionado: `.env.example`
- chaves esperadas:
  - `GLPI_BASE_URL`
  - `GLPI_DEBUG_LOGS`

Endpoint operacional principal hoje:

- `http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`

Contrato canonico de produto, UI e componentes:

- `SIS_MOBILE_PRODUTO_UI_CANONICO.md`

## Resolucao real do Flutter neste host

Evidencia atual:

- `flutter` nao estava disponivel diretamente no `PATH` deste terminal
- `Flutter 3.43.0-0.3.pre` respondeu corretamente em:
  - `C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat`

Implicacao operacional:

- comandos canonicos podem usar esse binario explicitamente quando o `PATH` nao estiver preparado
- o script `tool/android/build_release.ps1` ja implementa fallback automatico para localizacao do Flutter

## Scripts suportados

### Build Android

- `tool/android/build_release.ps1`
  - release APK
  - release AAB com `-Aab`
  - fallback de localizacao do Flutter
  - build com endpoint alternativo usando `-GlpiBaseUrl`
  - build a partir de arquivo de ambiente alternativo usando `-EnvFile`

### Acesso externo controlado

Para uso em celular fora da intranet, o runtime suportado nao inclui:

- bridge USB/LAN
- `adb reverse`
- proxy local rodando em notebook de desenvolvimento
- APKs variantes apontando para `127.0.0.1`, IP de LAN local ou porta ad hoc

Quando for necessario uso externo real, a ordem correta e:

- priorizar VPN institucional mobile, quando existir
- na ausencia de VPN, usar um endpoint externo estavel
- exigir TLS e hostname controlado
- exigir host sempre ligado e institucionalmente operavel
- exigir seguranca e observabilidade compativeis com expor um backend interno

O desenho canonico e detalhado esta em:

- `ACESSO_EXTERNO_CONTROLADO.md`

## Validacao suportada

### Estrutural

- `flutter analyze`
- `flutter test`

### Operacional

- login real
- catalogo
- meus chamados
- detalhe do chamado
- conversa e followup
- criacao de chamado
- anexo
- regra de entidade online e offline

### Visual local

- `tool/frontend/validate_widgetbook.ps1`
  - roda `pub get`, `analyze`, `test` e `build web` no laboratorio `widgetbook/`
  - aceita `-UpdateGoldens` para atualizar baselines visuais de forma explicita
  - nao substitui prova de runtime Android

As consolidacoes atuais dessas evidencias estao em:

- `validation-and-testing-guide.md`
- `entity-governance-and-android-testing.md`
- `ACESSO_EXTERNO_CONTROLADO.md`

## Build e distribuicao

Fluxo suportado para distribuicao Android:

1. configurar `android/key.properties` quando houver assinatura release real
2. rodar `tool/android/build_release.ps1`
3. usar o playbook:
   - `android-distribution-playbook.md`

Artefatos em `Downloads` ou APKs produzidas em rodadas anteriores servem como evidencia operacional, nao como contrato normativo permanente.

## Limites conhecidos

- o backend GLPI e interno; validacao completa depende de rede interna ou VPN
- uso externo em celular depende de um endpoint publico controlado e estavel; notebook como relay nao e solucao suportada
- existem sinais de mojibake residual em comentarios e logs internos
- o fallback web mobile-first existe apenas como plano, nao como runtime canonico

## O que nao e runtime canonico hoje

- web mobile-first como produto paralelo
- configuracoes persistentes de CLI dentro do repo sem uso real
- APKs temporarias soltas fora do fluxo de build oficial
- bridge USB/LAN, `adb reverse` e proxy local de notebook para contornar a intranet

## Ordem de precedencia pratica

Quando houver duvida operacional, siga esta ordem:

1. codigo e scripts atuais em `lib/`, `test/` e `tool/`
2. `../README.md`
3. este documento
4. docs operacionais especializadas desta pasta
