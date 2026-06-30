# Resolução de Entidade do Ticket (ponta a ponta)

Validado ao vivo com admin (2026-06-28). Responde: **quando a entidade vem do
formulário e quando vem do usuário?** Resposta curta: **o MODO do formulário
decide**, e o app implementa cada modo. Não há correção server-side de entidade.

## 1. A entidade é decidida na CRIAÇÃO, pelo app

O app cria via `POST /Ticket` nativo (não via FormCreator FormAnswer). A entidade
é resolvida por `GovernedEntityResolver` (`lib/catalog/governed_entity_resolver.dart`)
a partir do `destination_entity.mode` do target (catálogo governado):

| Modo (`destination_entity.mode`) | Candidatos (ordem) | Entidade final |
|---|---|---|
| `requester_context_para_mim` | [selecionada, **ativa do usuário**] | **entidade do USUÁRIO (sessão ativa)** |
| `maintenance_context_para_mim` | [**valor fixo do form**, selecionada, ativa] | **entidade FIXA do form** (ex.: 58), senão usuário |
| `third_party_question` | beneficiário | **entidade do BENEFICIÁRIO** (bloqueia se não resolver) |
| `fixed_or_direct` | [valor fixo, selecionada, ativa] | entidade fixa |
| desconhecido / ausente | — | **BLOQUEIA (fail-closed)** |

Distribuição no catálogo: **103 records com entidade FIXA** (`destination_entity_value≠0`,
ex.: 58 para checklists de hidráulica/iluminação), **30 com contexto** (value 0).

## 2. O servidor NÃO corrige a entidade

Validado ao vivo (admin): das **31 RuleTickets**, **NENHUMA reatribui `entities_id`**
do ticket (as ações `entities_id` pertencem a regras de import/auth de usuário, não
a RuleTicket) e **NENHUMA reatribui categoria**. Portanto:

> **A entidade definida na criação é a entidade final.** Não há rede de segurança
> server-side. Se o usuário estiver na entidade ativa errada num form de modo
> `requester_context`, o ticket fica na entidade errada — nada conserta depois.

O que as RuleTickets ativas fazem é **rotear o GRUPO por categoria**: `[155]`
"Adiciona Grupo por categoria", `[156]` "Adicionar grupo Manutenção", `[153]`
"GG-conservação", `[154]` "DTIC Observador". Ou seja, o roteamento ao time é por
**categoria → grupo** (server-side), não por entidade.

## 3. Precedência completa no app

`_stampEntityContext` (`lib/state/app_state.dart`) define o `entities_id` final:
`formData.entities_id` (vindo do resolver) → `_selectedTicketEntityId` →
`_defaultEntityId` (padrão do usuário) → `_activeEntityId` (sessão ativa).

## 4. Por que os tickets de teste 10082/10083 foram para PIRATINI (raiz)

Dois motivos somados, **nenhum é bug do app**:
1. Foram criados via `POST /Ticket` cru (fora do form) → não passaram pelo resolver
   → GLPI usou a entidade ativa da sessão = PIRATINI (raiz).
2. Mesmo pelo form de Solicitante "para mim" (modo `requester_context`), a entidade
   seria a **ativa do usuário** — e a conta de teste estava na raiz PIRATINI.

**Caveat de certificação:** a entidade desses tickets NÃO representa uma submissão
real pelo formulário. A certificação de entidade (F8) deve ser refeita pelo **fluxo
real do form**, e a conta de teste deve estar numa **entidade de departamento**, não
na raiz, para representar um solicitante real.

## 5. Implicação operacional

Como não há correção server-side, **a entidade ativa do usuário no momento da
submissão é determinante** para forms `requester_context`. Isso reforça a auditoria
de 2026-06-25: o `User.profiles_id` e a entidade padrão de cada usuário precisam
estar corretos, senão o chamado nasce na entidade errada. Ver
[[permission-matrix-by-profile]].
