# CLAUDE

**Constituicao objetiva:** este repositorio e a interface Flutter multiplataforma do ecossistema SIS para chamados GLPI. A fonte canonica nesta maquina fica em `/home/jonathan/projects/work/mobile/sis-mobile-flutter`; referencias `C:\Users\...` nos docs existem como camada host ou historico operacional, nao como raiz de codigo-fonte para este workspace.

## Papel do Claude aqui

- Operar este repo como agente de codigo, documentacao e consolidacao local.
- Respeitar `AGENTS.md`, `BOOTSTRAP.md`, `HERMES.md` e `.claude.json` como contexto de governanca do projeto.
- Tratar configuracao persistente do Claude como user-scope, salvo necessidade comprovada dentro deste repo.

## O que consultar antes de mudar algo

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
6. `docs/CONTROL_PLANE_LOCAL.md`

## Constituicao operacional do projeto

- Produto: app Flutter da SIS para operacao de chamados GLPI.
- Runtime local: configuracao via `.env` na raiz.
- Superficies principais: `lib/`, `test/`, `widgetbook/`, `tool/android/`, `tool/frontend/`.
- Integracoes: GLPI real interno; acesso direto depende de rede interna ou VPN, mas distribuicao externa para usuarios finais deve usar endpoint controlado.
- Fronteira local: codigo-fonte na raiz WSL; WSL roda desenvolvimento, `analyze`, `test`, web local e Widgetbook por comandos Flutter Linux.
- Camada Android: Windows host concentra Android SDK, emulator, dispositivo fisico, `adb`, `flutter run -d android` e build release. PowerShell nao precisa existir dentro da WSL.
- Acesso externo mobile: para "somente o APK", preferir Worker `workers.dev` + Workers VPC + Tunnel; VPN por aparelho fica para desenvolvimento, suporte ou grupos controlados. Nao usar bridge USB/LAN, `adb reverse` ou proxy de notebook como estrategia suportada.
- Hermes/Antigravity: trate `HERMES.md` como contrato de orquestracao e contexto; nao replique runtime Hermes nem control plane dentro deste repo.

## Artefatos relevantes para agentes

- `AGENTS.md`
- `BOOTSTRAP.md`
- `CLAUDE.md`
- `HERMES.md`
- `docs/*.md`

Artefatos que nao devem ser criados sem caso de uso concreto:

- `.claude/settings.json`
- `.claude/settings.local.json`
- `.mcp.json`

## Validacao recomendada

- Mudanca documental: revisar consistencia entre os docs principais.
- Mudanca de codigo: `/opt/flutter/bin/flutter analyze` e `/opt/flutter/bin/flutter test` na WSL, ou `flutter analyze`/`flutter test` quando o PATH estiver configurado.
- Mudanca visual relevante: revalidar `widgetbook/` por comandos Flutter na WSL ou pelo script PowerShell no Windows host.
- Mudanca de build ou distribuicao Android: usar os scripts oficiais em `tool/android/` no Windows host com Flutter/Android SDK/adb configurados.

## Regras locais

- Nao trate logs, dumps XML, screenshots ou caches de build como fonte normativa.
- Nao versionar `.env`, variantes locais de `.env`, `android/key.properties`, keystores, secrets, caches, build outputs ou runtime artifacts.
- Nao promova configuracao global do Claude para dentro do repo sem necessidade real.
- O projeto depende de rede interna, VPN ou endpoint externo controlado para validacao plena contra o GLPI real.
- Use este arquivo como contexto de projeto; trate qualquer configuracao persistente do Claude como user-scope.
- preservar funcionalidades reais de producao do app; nao remover capacidades funcionais por causa de riscos de validacao
- Conta de teste como ator universal de validacao: existe UMA conta de teste dedicada (login proprio de QA/bot, credenciais em `.env` nao versionado) usada para TODA validacao mutavel necessaria no GLPI real. Claude/agentes operam sempre como essa conta, nunca como usuario real e nunca pela sessao de servico elevada do Worker (essa permanece restrita a GET de diretorio User/Group).
- Criar chamado e mutacao NAO-destrutiva e reversivel. Claude/agentes PODEM, como a conta de teste, criar tickets de teste no GLPI real (incl. producao) via `POST /Ticket` e agir SOMENTE sobre os tickets criados na mesma execucao (`PUT` de status, followup, solucao, anexo), sob TODAS as condicoes abaixo:
  - Marcacao obrigatoria: todo ticket de teste leva prefixo identificavel no titulo (ex.: `[TESTE-AUTOMATIZADO SIS]`) e conteudo deixando claro que e teste automatizado descartavel.
  - Cleanup e auditoria: apos validar, encerrar/cancelar o proprio ticket de teste e registrar o ID criado para limpeza humana e auditoria.
  - Escopo fechado: nunca executar mutacao em ticket cujo requerente/criador nao seja a propria conta de teste; nunca tocar tickets de usuarios reais.
- Simulacao de papeis: para validar fluxos de Solicitante, Tecnico/Conservacao, Tecnico/Manutencao, observador e demais papeis, e permitido alternar o PERFIL ATIVO (`changeActiveProfile`) e a ENTIDADE ATIVA da sessao da conta de teste entre os perfis/entidades atribuidos a ela. Esse caminho exige GLPI direto (rede interna/VPN), pois o Worker nao expoe `changeActiveProfile`.
- Ajuste de atribuicoes da conta de teste: conceder/revogar perfis (`Profile_User`) e entidades e permitido EXCLUSIVAMENTE sobre a propria conta de teste, de forma reversivel e registrada, revertendo ao estado original ao fim da validacao. Exige credenciais administrativas de teste fornecidas explicitamente para esse fim (em `.env`), nunca a sessao de servico do Worker. PROIBIDO alterar atribuicoes, perfis ou entidades de qualquer outro usuario.
- Variaveis em `.env` (nao versionado): `SIS_TEST_USER`/`SIS_TEST_PASSWORD` para a conta de teste; credenciais administrativas de teste em chave separada quando o ajuste de atribuicoes for necessario. O harness de validacao e read-only por padrao; muta so com flag explicita.
- Proibicao absoluta, independente de identidade ou ambiente: `DELETE /Ticket`, `DELETE`/purge de usuarios, grupos ou entidades, cleanup destrutivo automatizado e qualquer metodo destrutivo via Worker SIS pass-through permanecem vetados sem aprovacao humana explicita e ambiente isolado.
- usar validacoes read-only por padrao quando houver GLPI real no caminho; mutacao apenas pelos fluxos de teste acima, de forma consciente e parcimoniosa
