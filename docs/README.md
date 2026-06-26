# Documentacao SIS Mobile

## Objetivo

Esta pasta concentra a documentacao operacional suportada deste repositorio.

Ela deve responder, com o minimo de ruido:

- como o app builda
- como valida
- como conversa com o GLPI interno
- como distribuir para Android
- como este repo deve ser lido por agentes e pelo control plane

O fluxo operacional e hibrido: WSL para fonte, `analyze`, `test`, web local e Widgetbook; Windows host para Android SDK, emulator, `adb`, `flutter run -d android` e builds Android quando o SDK esta no host.

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
- `DTIC_MOBILE_V1.md`
  Contrato da linha DTIC isolada, Worker com App-Token server-side e MVP
  FormCreator read-only/validacao local.
- `PADRONIZACAO_APPS_SIS_DTIC.md`
  Contrato de padronizacao entre as linhas SIS e DTIC: telas, funcionamento,
  reaproveitamento, diferencas intencionais e lacunas de guarda visual.
- `MOBILE_WORKSPACE_ORGANIZATION.md`
  Plano normativo para organizar SIS Mobile e DTIC Mobile em
  `/home/jonathan/projects/work/mobile`, com fases, gates e criterios para uma
  eventual separacao fisica por pastas.
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
  Estrategia aceita para uso externo fora da intranet, incluindo a decisao de nao exigir VPN por aparelho quando o requisito for "somente o APK".
- `ACESSO_EXTERNO_WORKERS_VPC.md`
  Arquitetura de primeira fase para endpoint externo sem dominio proprio: Cloudflare Worker em `workers.dev`, Workers VPC e Tunnel.
- `PILOTO_CLOUDFLARE_PASS_THROUGH.md`
  Playbook historico/fallback para pass-through com hostname proprio, `cloudflared`, proxy e build do APK publico.
- `PLANO_ESTABILIZACAO_ACESSO_EXTERNO.md`
  Plano operacional para sair do quick tunnel e fechar o hostname estavel, o tunnel nomeado e o APK distribuivel.
- `entity-governance-and-android-testing.md`
  Regra da entidade do usuario e roteiro de teste Android.
- `validation-and-testing-guide.md`
  Consolidacao da validacao atual do app.
- `AUDITORIA_OPERACIONAL_TECNICOS_APK_PWA_ANEXOS_2026-06-25.md`
  Auditoria funcional do fluxo dos tecnicos, consistencia APK/PWA, fila
  operacional, assuncao/status e anexos.
- `QUALITY_FOUNDATION_ADAPTACAO_FLUTTER.md`
  Registro da adaptacao do pacote externo de qualidade para a realidade Flutter/Dart/GLPI deste repo.
- `domain/ticket/STATES.md`
  Estados GLPI e locais que o app Flutter precisa respeitar ao ler, exibir e alterar tickets.
- `domain/ticket/TRANSITIONS.md`
  Matriz operacional de papeis, estados e acoes para tickets.
- `domain/ticket/INVARIANTS.md`
  Regras que devem permanecer verdadeiras nos fluxos de ticket, com pontos de codigo e testes relacionados.
- `domain/ticket/SOURCES_OF_TRUTH.md`
  Mapa de origem dos dados por superficie: lista, detalhe, conversa e criacao.
- `domain/ticket/EXTRACAO_INVARIANTES_2026-04-29.md`
  Extracao de regras reais do codigo atual, com lacunas de guarda e proximos testes minimos.
- `quality/DOR.md`
  Definition of Ready adaptado ao SIS Mobile Flutter para features/fixes nao triviais.
- `quality/DOR_GUARDAS_EXECUCAO_TICKET.md`
  DoR preenchido para o proximo fix de guardas de execucao contra estado obsoleto.
- `quality/DOD.md`
  Definition of Done adaptado aos gates Flutter, Widgetbook, Android, GLPI e documentacao.
- `quality/PROTOCOLO_FINALIZACAO.md`
  Roteiro operacional para classificar mudancas, aplicar o rigor certo e encerrar entregas sem refactor adjacente.
- `quality/BUG_AUTOPSY_TEMPLATE.md`
  Template de autopsia para bugs de dominio, estado, permissao ou sincronizacao.
- `AUTOPSIA_RAPIDA.md`
  Protocolo curto para bugs localizados, com timebox, confianca explicita e aprendizado obrigatorio.
- `AUTOPSIA_COMPLETA.md`
  Protocolo investigativo para divergencias de estado, UI, API, permissoes e transicoes criticas.
- `AUTOPSIA_TICKET_FECHADO_STALE_STATE.md`
  Autopsia guiada do caso de ticket fechado com tela antiga expondo acoes inconsistentes.

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

## Seguranca GLPI para agentes

- preservar funcionalidades reais de producao do app; abertura, follow-up, anexo, solucao, status, atribuicao e sincronizacao offline continuam sendo capacidades funcionais para usuarios autorizados
- agentes nao devem executar validacoes mutaveis contra tickets reais de usuarios, nem usar Worker SIS pass-through para metodo destrutivo, `DELETE /Ticket`, purge ou cleanup automatizado sem aprovacao humana explicita, ambiente isolado e alvo sintetico confirmado
- docs historicos de validacao real devem ser lidos como evidencia, nao como permissao operacional permanente
