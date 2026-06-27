# AGENTS.md

## Objetivo

- Manter este repositorio operavel como app Flutter da SIS para chamados GLPI.
- Priorizar validacao real de runtime e distribuicao Android antes de refactors amplos.

## Ambiente canonico

- A raiz canonica deste workspace e `/home/jonathan/projects/work/mobile/sis-mobile-flutter` em WSL/ext4.
- SIS Mobile e DTIC Mobile existem hoje como linhas de produto dentro deste
  workspace Flutter; DTIC nao tem raiz Flutter propria confirmada em
  `/home/jonathan/projects/work/mobile`.
- Separacao fisica futura deve seguir `docs/MOBILE_WORKSPACE_ORGANIZATION.md`
  e passar pelos gates antes de mover codigo.
- Nao trate `C:\Users\...`, `/mnt/c/...` ou outros caminhos Windows como raiz de codigo-fonte deste projeto.
- Windows e camada host para GUI, Android SDK, Flutter SDK, Docker Desktop e historico operacional; a fonte do app vive na raiz WSL acima.
- Flutter SDK e Android SDK sao dependencias de execucao/build, nao superficies de codigo-fonte do repo.
- O ambiente e hibrido: WSL e a camada de desenvolvimento de codigo; Windows e a camada preferencial para Android SDK, emulator, dispositivo fisico e `adb`.
- Ausencia de PowerShell, Android SDK ou `ANDROID_HOME` dentro da WSL nao torna o projeto quebrado; apenas indica que a validacao Android deve ocorrer na camada Windows ou em um modelo hibrido explicitamente configurado.
- Para distribuicao externa com "somente o APK", nao trate VPN por aparelho como primeira fase; use endpoint externo controlado, preferencialmente Worker `workers.dev` + Workers VPC + Tunnel quando nao houver dominio proprio.
- Configuracao runtime local usa `.env` na raiz; mantenha `.env.example` como exemplo versionado.
- Nao versionar `.env`, variantes locais de `.env`, `android/key.properties`, keystores, secrets, caches, build outputs ou runtime artifacts.
- preservar funcionalidades reais de producao do app; abertura de chamado, follow-up, anexo, solucao, status, atribuicao e sincronizacao offline continuam sendo capacidades funcionais para usuarios autorizados
- agentes nao devem executar validacoes mutaveis contra tickets reais de usuarios, nem usar Worker SIS pass-through para metodo destrutivo, `DELETE /Ticket`, purge ou cleanup automatizado sem aprovacao humana explicita, ambiente isolado e alvo sintetico confirmado
- quando validar contra GLPI real, separar leitura/verificacao de mutacao; por padrao, agentes devem usar fluxo read-only

## Pontos de entrada

Leia nesta ordem antes de mudancas substanciais:

1. `BOOTSTRAP.md`
2. `README.md`
3. `docs/README.md`
4. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`

Leia tambem conforme o tipo de mudanca:

- `docs/entity-governance-and-android-testing.md`
- `docs/validation-and-testing-guide.md`
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`
- `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md`
- `docs/FRONTEND_SURFACE_DISCOVERY_FLUTTER.md`
- `docs/FRONTEND_SKILLS_FLUTTER.md`
- `docs/WIDGETBOOK_WORKBENCH.md`
- `docs/ACESSO_EXTERNO_CONTROLADO.md`
- `docs/ACESSO_EXTERNO_WORKERS_VPC.md`
- `docs/domain/ticket/STATES.md`
- `docs/domain/ticket/TRANSITIONS.md`
- `docs/domain/ticket/INVARIANTS.md`
- `docs/domain/ticket/SOURCES_OF_TRUTH.md`
- `docs/glpi/METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md`
- `docs/glpi/MAPA_FONTE_DA_VERDADE_GLPI.md`
- `docs/glpi/PORTABILIDADE_NOVA_INSTANCIA_GLPI.md`
- `docs/quality/DOR.md`
- `docs/quality/DOD.md`
- `docs/quality/BUG_AUTOPSY_TEMPLATE.md`
- `docs/android-distribution-playbook.md`
- `docs/CONTROL_PLANE_LOCAL.md`
- `docs/MOBILE_WORKSPACE_ORGANIZATION.md`
- `GEMINI.md`
- `CLAUDE.md`
- `HERMES.md`

## Contexto externo

- Nao ha Cerebro Central canonico disponivel neste workspace.
- Nao assuma existencia de repo externo em Windows, `/mnt/c` ou outro local nao presente no ambiente atual.
- Se no futuro houver um indice cross-project local realmente acessivel, trate-o apenas como fonte consultiva; a decisao final precisa bater com os arquivos e scripts deste repo.

## Protocolo de discovery externo

- Para tarefas nao triviais, discovery, planejamento, governanca, desenho de runtime, modelagem para control plane ou duvidas cross-project, comece pelos docs deste repo.
- Use contexto externo somente quando ele existir no filesystem atual e for explicitamente relevante.
- Se contexto externo estiver indisponivel, registre isso objetivamente e siga pela alternativa mais conservadora.
- Nenhum indice externo substitui a leitura do repo atual.

## Principio de Projecao Dinamica (GLPI como fonte da verdade)

- O app deve **refletir** o GLPI, nao re-implementar um palpite dele. Classifique toda
  informacao do GLPI em: **protocolo/esquema** (estavel por versao; ex.: itemtypes,
  bitmask de rights `Ticket::READMY=1`, status 1-6, field-IDs de search; pode ser
  constante rotulada) vs. **configuracao de instancia** (muda por instalacao/web; ex.:
  nomes de perfil, IDs de grupo/categoria, templates, formularios, RuleTicket, limite de
  sub-niveis; nunca hardcodar, sempre buscar de endpoint e projetar).
- Regra de revisao: antes de introduzir constante ligada a perfil/grupo/categoria/status/
  regra, classifique-a; se for de instancia, ela tem que vir de um endpoint da API.
- Para descobrir onde mora qualquer regra, use a cadeia de 7 perguntas de
  `docs/glpi/METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md` e registre o achado em
  `docs/glpi/MAPA_FONTE_DA_VERDADE_GLPI.md`. Para subir o app sobre um GLPI novo (DTIC e
  proximos), siga `docs/glpi/PORTABILIDADE_NOVA_INSTANCIA_GLPI.md`.
- Caveat de API: nao presuma reaplicacao da logica de web num `POST`. Ha relato nao
  confirmado de templates de categoria nao aplicados via API (GLPI #15225, stale; nao cobre
  RuleTicket); o comportamento de RuleTicket deve ser confirmado empiricamente. Validar
  read-back apos criar.

## Protocolo investigativo para bugs

- Ao analisar bug ou inconsistencia, separe sempre: fato observado, hipoteses, evidencias necessarias, causa raiz provavel, correcao minima e aprendizado de processo.
- Nao trate comportamento observado como diagnostico fechado. Toda inferencia deve declarar confianca: alta, media ou baixa.
- Antes de propor abstracao, refactor estrutural ou nova camada, registre a evidencia concreta, por que a correcao local nao basta e qual custo a nova estrutura introduz.
- Classifique o problema antes de corrigir: bug local, sincronizacao, interpretacao errada de regra, ausencia de guarda, duplicacao de regra ou falha sistemica real.
- Use `docs/AUTOPSIA_RAPIDA.md` para bugs localizados e `docs/AUTOPSIA_COMPLETA.md` para divergencia entre UI, API, estado remoto, permissoes ou transicoes criticas.
- Para o caso de ticket fechado com tela obsoleta, use `docs/AUTOPSIA_TICKET_FECHADO_STALE_STATE.md`.
- Para mudancas de dominio de ticket, confronte tambem `docs/domain/ticket/STATES.md`, `docs/domain/ticket/TRANSITIONS.md`, `docs/domain/ticket/INVARIANTS.md` e `docs/domain/ticket/SOURCES_OF_TRUTH.md`.
- Para features ou fixes nao triviais, use `docs/quality/DOR.md` antes de implementar e `docs/quality/DOD.md` antes de declarar pronto.
- Criterio de stop: encerrar quando a causa raiz estiver suficientemente provavel, a correcao minima estiver validada e o aprendizado de processo estiver registrado.

## Validacao obrigatoria

- Mudanca documental pura: revisar coerencia entre `README.md`, `docs/README.md` e `docs/RUNTIME_CANONICO_E_VALIDACAO.md`.
- Mudanca visual relevante: modelar ou atualizar o use case no `widgetbook/` e rodar o gate Widgetbook. Na WSL use os comandos Flutter equivalentes dentro de `widgetbook/`; no Windows host pode ser usado `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1`.
- Atualizacao de baseline visual: atualizar goldens somente de forma explicita e registrar que a mudanca foi intencional.
- Mudanca de codigo nao trivial: rodar `flutter analyze` e `flutter test`.
- Mudanca em build Android, acesso externo, `.env` ou runtime: revalidar tambem os scripts em `tool/`.
- Mudanca que afete distribuicao Android: validar na camada Windows com Flutter/Android SDK/adb configurados e usar `tool/android/build_release.ps1` a partir do Windows host. Nao exija PowerShell dentro da WSL.

Restricao GLPI:

- nao usar docs historicos de validacao como permissao para criar, alterar, fechar ou anexar em tickets reais de usuarios
- validacao mutavel exige aprovacao humana explicita, ambiente de homologacao/sandbox ou ticket sintetico isolado, credencial apropriada e criterio de parada
- o Worker SIS pass-through deve ser tratado como superficie sensivel ate existir allowlist/bloqueio tecnico de metodos destrutivos

## Regras de edicao

- Nao reverta mudancas do usuario sem pedido explicito.
- Nao invente arquivos de configuracao de CLI, MCP ou skill sem necessidade concreta confirmada neste repo.
- Separe contexto de projeto de configuracao persistente de usuario.
- Prefira artefatos pequenos, normativos e sustentaveis.
- Nao promova redesign ou mudanca visual importante direto em `lib/` sem laboratorio visual e baseline local.
- Nao reintroduza bridge USB/LAN, `adb reverse` ou proxy de notebook como solucao suportada para acesso externo.

## Formato de entrega

- Relatar o que foi encontrado, o que foi criado e o que foi validado.
- Citar caminhos exatos dos arquivos e comandos realmente executados.
- Se alguma validacao nao puder ser executada, dizer isso explicitamente.
