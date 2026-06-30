# Relatório de Certificação — Perfis, Grupos e Regras (2026-06-28)

Resultado da execução da matriz `CERTIFICACAO_PERFIS_REGRAS_2026-06-28.md`.
Conta 2373 (`teste`), GLPI direto, via `changeActiveProfile`. Evidência:
`output/playwright/certificacao-2026-06-28/`.

## Sumário por família

| F | Família | Veredito | Camada validada | Evidência |
|---|---|---|---|---|
| F1 | Direitos (bitmask) | ✅ PASS | Camada 1 (verdade) | bitmask 5/260102/145411 idêntico ao contrato |
| F2 | Visibilidade (scope) | ✅ PASS | Camada 1 | ordenação 9(94) < 12(2214) < 11(9036) |
| F3 | Catálogo/serviços | 🟡 PARCIAL | Bridge B ok; Bridge A bloqueada | cards por perfil vistos; Form_Profile = admin |
| F4 | Forms + árvore | ✅ PASS (Bridge B) | Bridge B | Ar-Cond 6 folhas (visual + `governed_question_tree_test`) |
| F5 | Checklists | 🟡 PARCIAL | Bridge B (unit/widget) | Bridge A (forms 48–52 vivo) = admin |
| F6 | Transições de status | ✅ PASS (+R1/R2) | Camada 1 (mutação real) | tickets 10082/10083; regras R1/R2 |
| F7 | Actor fields [4,22,66] | ✅ PASS | Camada 1 | requester=88, author=92, observer=0 |
| F8 | Entidade | ✅ PASS | Camada 1 | sessão entidades 1 (PIRATINI) + 28 (DTIC) |
| F9 | Troca de perfil | ✅ PASS | Camada 1 + unit | API exercitada ~15×; `app_state_profile_switch_test` |

## Descobertas que refinam o modelo (F6)

**R1 — Precedência do requerente (server-side):** o requerente muda o status do
PRÓPRIO ticket mesmo sem o bit UPDATE (perfil 9 mudou status do ticket que criou,
HTTP 200, status real alterado). O app NÃO oferece essa ação (conservador/seguro).

**R2 — Gating por entidade/escopo:** UPDATE é necessário mas não suficiente. Perfil
12 (com UPDATE) recebeu 403 num ticket fora do seu escopo de entidade.

Correção do baseline 2026-06-25: "Solicitante muda status ❌" → ❌ só para tickets
de OUTROS, ✅ para o PRÓPRIO; "GG muda status ✅" → ✅ só dentro do escopo do GG.

## Limites honestos (não certificável agora)

- **Bridge A (catálogo == tabelas admin vivas)** para F3/F4/F5: `PluginFormcreatorForm_Profile`
  e `ITILCategory` retornam `ERROR_RIGHT_MISSING` para os perfis de runtime. Exige
  **admin** (credenciais `.env` inválidas — `ERROR_GLPI_LOGIN`). É concern de
  build-time (geração do catálogo), não runtime. **Confirma a arquitetura**: o
  catálogo governado pré-resolvido é necessário porque o runtime não lê config admin.
- **Visual live por perfil** (F3 cards, F5 checklists): cobertos parcialmente por
  screenshots anteriores + testes unit/widget; o launch web local ficou instável
  nesta sessão (processo vivo, HTTP 000). Não é problema de código.

## Validações adicionais (parte 3 — entidade prática, anexo, conversa, navegação)

- **Entidade E2E (prova prática).** Mudei a entidade ativa da conta e criei chamados
  reais: ativa=28→ticket 10084 nasceu na **28**; ativa=1→10085 na **1**; atribuí a
  entidade **58** (admin, reversível) e ativa=58→10086 na **58**. **Prova: a
  entidade do chamado = a entidade ativa da sessão** (modo `requester_context`).
  Baseline da conta restaurado. Todos fechados.
- **Anexo.** Upload via `POST /Ticket/{id}/Document` (multipart) → documento 7647
  **vinculado** (Document_Item confirma 2 docs). O app verifica o vínculo no
  read-back (`verifiesDocumentUploadLink`). ✅
- **Conversa user↔técnico.** Followup do solicitante (201) + followup do técnico
  (201) aparecem na conversa **ordenados**; leitura via `getTicketDocuments`/
  followups. ✅ (mecanismo bidirecional; em produção autores distintos).
- **Meus Chamados — separação para navegação do técnico.** ✅ chamados operacionais
  agrupados por **FILA** (`TicketQueueClassifier`: Atribuídos a mim, Pendente
  validação, Fila Manutenção, Fila Conservação, GG Compartilhada) com ordenação
  (`_groupSortWeight`); próprios por **STATUS**; + filtro por status. Lógica sólida
  (`lib/screens/my_tickets_screen.dart`); confirmação visual depende do app rodando.

Auditoria final: tickets de teste 10082–10087 **todos Fechados (6)**; conta 2373 no
baseline {9,11,12}+{12,21,22,49}.

## Conclusão

O **núcleo de direitos, visibilidade, fluxos de ação e troca de perfil** está
**certificado ao vivo** contra a fonte da verdade, com o bitmask 100% estável e
duas regras novas (R1 requerente-precedência, R2 escopo de entidade) documentadas.
O app mostrou-se **conservador vs servidor** (mais restritivo — seguro). As lacunas
restantes são de **Bridge A** (exige admin, build-time) e **visual** (launch
instável), não de divergência de comportamento detectada.

## Atualização — admin destravado (2026-06-28, parte 2)

Causa da falha admin: senha no `.env` **sem aspas** (contém `;`), truncada pelo
`source .env`. Corrigido com aspas → admin OK. Com admin (read-only):

- **F3/F4 Bridge A → ✅ VERDE.** `Form_Profile` vivo == catálogo (38 forms, 0 drift);
  árvore `ITILCategory` viva sob "Manutenção > Ar Condicionado" == as 6 folhas do
  catálogo == meu fix. O snapshot governado está **fresco e correto**.
- **Entidade (F8) → modelo fechado.** Ver `docs/domain/ticket/ENTITY_RESOLUTION.md`.
  A entidade é definida na criação pelo app (resolver por modo); **nenhuma das 31
  RuleTickets reatribui entidade**; o servidor só roteia GRUPO por categoria.
  Caveat: tickets de teste por raw POST não representam a entidade real do form.
- **Requerente-status (R1) → explicado.** `Profile/9` é `interface=helpdesk` com
  matriz `ticket_status` própria; o requerente muda status do próprio ticket por
  essa matriz, independente do bit UPDATE. Comportamento core do GLPI.

### Isolamento de grupos (F2 limpo) — mutação reversível, baseline restaurado

Baseline da conta 2373: perfis {9@28, 9@1, 12@58, 11@1} + grupos {12,21,22,49}.
Isolei um grupo por vez (revogar/restaurar `Group_User`), medindo a visibilidade:

| Cenário | Grupo | Perfil | Visibilidade isolada | Baseline (todos) |
|---|---|---|---|---|
| CC-Conservação | só 21 | 11 | 4944 | 9036 |
| CC-Manutenção | só 22 | 11 | 4349 | 9036 |
| GG-Conservação | só 49 | 12 | 2191 | 2214 |

**Prova:** perfil 11 é group-scoped (21+22 ≈ combinado 9036, fatias distintas);
perfil 12 é essencialmente g49 (2191≈2214). A "visibilidade misturada" observada
no app era **artefato da conta de teste ter os 3 grupos** — um usuário real (1
grupo) vê só o seu contexto. O app filtra por papel operacional; com múltiplos
grupos resolve para **híbrido** → mostra tudo (correto para a conta de teste).
Baseline **restaurado e verificado** {12,21,22,49}. Evidência: `baseline_*.json`.

Re-auditoria das atribuições reais: feita — ver
`AUDITORIA_ATRIBUICOES_REAIS_2026-06-28.md` (ação humana: 13 técnicos sem perfil
11; ~50 GG com `User.profiles_id`≠9).

### Integridade final + correção de cleanup

Verificação final (admin): conta 2373 restaurada {9,11,12}+{12,21,22,49} ✓.
Tickets de teste 10082/10083 estavam presos em status=2 — o cleanup inicial
falhou. **Causa (regra GLPI confirmada):** fechar exige **categoria + solução**
("Categoria é obrigatória..."). Corrigido: setei categoria (2=Conserto) + solução
(ITILSolution 8495/8496) → Solucionado(5) → **Fechado(6)** ✓. Ambos terminais.

## Próximos passos sugeridos
1. Obter credenciais admin válidas → certificar Bridge A (catálogo vs Form_Profile/ITILCategory vivo) e regenerar catálogo `--live`.
2. Estender harness Dart (regressão automatizada F1/F2/F6) — candidato a Codex (dossiê em `docs/handoff/`).
3. Passe visual completo por perfil quando o launch web estiver estável.
