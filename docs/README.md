# Documentacao SIS Mobile

## Objetivo

Esta pasta concentra a documentacao operacional suportada deste repositorio.

Ela deve responder, com o minimo de ruido:

- como o app builda
- como valida
- como conversa com o GLPI interno
- como distribuir para Android
- como este repo deve ser lido por agentes e pelo control plane

## Leitura principal

1. `../README.md`
   Porta de entrada geral do projeto.
2. `RUNTIME_CANONICO_E_VALIDACAO.md`
   Runtime suportado, comandos validos e ordem de precedencia operacional.
3. `CONTROL_PLANE_LOCAL.md`
   Mapeamento deste repo para o ecossistema de CLIs e control plane.

## Documentos operacionais ativos

- `android-distribution-playbook.md`
  Build release, assinatura e distribuicao Android.
- `SIS_MOBILE_PRODUTO_UI_CANONICO.md`
  Contrato de produto, UI, componentes canonicos e direcao visual do app Flutter.
- `FRONTEND_PROFISSIONAL_FLUTTER.md`
  Doutrina de frontend profissional, design lab, workbench de componentes, guarda visual e prova de runtime.
- `PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md`
  Decisao de stack, ordem de adocao, workbench Flutter, guarda visual e roadmap de implantacao.
- `FRONTEND_SURFACE_DISCOVERY_FLUTTER.md`
  Discovery real das superficies Flutter, familias dominantes, lacunas do Widgetbook e sequencia recomendada de trabalho.
- `FRONTEND_SKILLS_FLUTTER.md`
  Blueprint de skills planejadas para discovery, design lab, Widgetbook, guarda visual, runtime evidence e conteudo.
- `WIDGETBOOK_WORKBENCH.md`
  Operacao do laboratorio Flutter separado do runtime principal, com comandos e cobertura inicial.
- `ACESSO_EXTERNO_CONTROLADO.md`
  Estrategia aceita para uso externo fora da intranet, incluindo prioridade para VPN institucional mobile e alternativas temporarias com endpoint estavel.
- `PILOTO_CLOUDFLARE_PASS_THROUGH.md`
  Playbook operacional da Opcao A com host intermediario, `cloudflared`, proxy e build do APK publico.
- `PLANO_ESTABILIZACAO_ACESSO_EXTERNO.md`
  Plano operacional para sair do quick tunnel e fechar o hostname estavel, o tunnel nomeado e o APK distribuivel.
- `entity-governance-and-android-testing.md`
  Regra da entidade do usuario e roteiro de teste Android.
- `validation-and-testing-guide.md`
  Consolidacao da validacao atual do app.

## Documento exploratorio

- `web-mobile-fallback-plan.md`
  Direcao futura para fallback web mobile-first.

Esse documento nao altera o runtime canonico atual do app Flutter.

## Regra editorial

Promova documento novo para `docs/` apenas quando ele for:

1. normativo
2. operacional recorrente
3. evidencia consolidada que precisa sobreviver ao turno atual

Nao promova para `docs/`:

- dumps temporarios de UI
- logs locais de uma rodada
- XMLs, PNGs e TXT de depuracao pontual
- notas intermediarias sem valor duravel

## Fonte de verdade

Em caso de conflito, a ordem pratica e:

1. codigo e scripts atuais do repo
2. `../README.md`
3. `RUNTIME_CANONICO_E_VALIDACAO.md`
4. docs operacionais especializados desta pasta
