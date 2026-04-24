# BOOTSTRAP

Mapa operacional inicial deste repositorio para agentes e CLIs.

## O que este repo e

- App Flutter da SIS para operacao de chamados GLPI.
- O codigo principal vive em `lib/`.
- Os testes vivem em `test/`.
- O laboratorio visual Flutter vive em `widgetbook/`.
- Os scripts operacionais vivem em `tool/android/`.
- Os scripts de validacao frontend vivem em `tool/frontend/`.
- A documentacao operacional vive em `docs/`.

## Ordem minima de leitura

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`

Antes de planejar mudanca nao trivial, rode tambem um discovery no Cerebro Central:

- `C:\Users\jonathan-moletta\code\inteligencia-md-local\cerebro_central`

Leia tambem quando aplicavel:

- `docs/entity-governance-and-android-testing.md` para entidade e testes Android
- `docs/validation-and-testing-guide.md` para historico de validacao
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md` para contrato de produto, UI e componentes Flutter
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md` para a doutrina de frontend profissional, design lab, workbench e guarda visual
- `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md` para a stack escolhida, o roadmap e os artefatos do laboratorio Flutter
- `docs/FRONTEND_SURFACE_DISCOVERY_FLUTTER.md` para o inventario real das superficies Flutter e a ordem recomendada de trabalho visual
- `docs/FRONTEND_SKILLS_FLUTTER.md` para os contratos planejados de skills de frontend Flutter sem instalar configuracao global
- `docs/WIDGETBOOK_WORKBENCH.md` para a operacao do workbench separado e os comandos canonicos dessa trilha
- `docs/ACESSO_EXTERNO_CONTROLADO.md` para estrategia de acesso externo real
- `docs/android-distribution-playbook.md` para release e distribuicao
- `docs/web-mobile-fallback-plan.md` para iniciativa futura de fallback web
- `docs/CONTROL_PLANE_LOCAL.md` para mapeamento deste repo no control plane

## Runtime canonico

- Configuracao via `.env` na raiz.
- Endpoint principal esperado: `GLPI_BASE_URL=http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`
- Fluxos suportados hoje:
  - web local: `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
  - Android local: `flutter run -d android`
  - release Android: `.\tool\android\build_release.ps1`

Para uso externo em celular fora da intranet, priorize VPN institucional mobile quando existir.
Na ausencia de VPN, o repo nao suporta bridge USB/LAN nem proxy de notebook.
O caminho aceitavel passa a ser um endpoint externo estavel e controlado, descrito em `docs/ACESSO_EXTERNO_CONTROLADO.md`.

## Resolucao do Flutter nesta maquina

- O binario `flutter` pode nao estar no `PATH` do terminal.
- Ha evidencia real de Flutter funcional em:
  - `C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat`
- O script `tool/android/build_release.ps1` tambem resolve esse fallback automaticamente.

## Comandos-base

- Pub get: `& 'C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat' pub get`
- Analyze: `& 'C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat' analyze`
- Test: `& 'C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat' test`
- Run web: `& 'C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat' run -d web-server --web-hostname 127.0.0.1 --web-port 8083`
- Run Android: `& 'C:\Users\jonathan-moletta\code\tools\flutter\bin\flutter.bat' run -d android`
- Build release: `powershell -ExecutionPolicy Bypass -File tool\android\build_release.ps1`
- Gate visual Widgetbook: `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1`
- Atualizar goldens intencionalmente: `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens`

## Politica de validacao

- Mudanca documental: nao exige build, mas exige coerencia com a operacao real.
- Mudanca visual relevante: passar por `widgetbook/` e `tool/frontend/validate_widgetbook.ps1` antes da prova de runtime.
- Mudanca intencional de baseline visual: usar `tool/frontend/validate_widgetbook.ps1 -UpdateGoldens` e revisar o diff gerado.
- Mudanca em `lib/` ou `test/`: rodar `analyze` e `test`.
- Mudanca em `tool/android/`: rodar pelo menos o script de build correspondente.
- Mudanca em `tool/frontend/` ou `widgetbook/`: rodar o gate visual Widgetbook.
- Mudanca no contrato de rede ou acesso externo: revisar `docs/ACESSO_EXTERNO_CONTROLADO.md` e revalidar o fluxo descrito.

## Regras locais

- O GLPI da SIS e interno. Teste real depende de rede interna ou VPN.
- Acesso externo em celular prioriza VPN institucional mobile; sem isso, exige um endpoint externo estavel. Bridge USB/LAN e `adb reverse` nao fazem parte da estrategia suportada.
- APKs em `Downloads` e logs XML/PNG/TXT sao evidencia operacional, nao fonte normativa.
- O fallback web mobile-first existe como plano exploratorio; nao e o runtime canonico atual.
- O Widgetbook e a baseline Alchemist sao a guarda local para UI; Android continua sendo prova final, nao laboratorio de primeira tentativa.
- Uso do Cerebro Central e esperado em discovery relevante deste repo, especialmente para:
  - governanca local
  - modelagem para control plane
  - comparacao com padroes de outros projetos
  - consolidacao documental
- O Cerebro nao substitui a leitura do repo atual.
