# Auditoria de Atribuições Reais dos Usuários (2026-06-28)

Read-only, admin, conta `jonathan-moletta`. Fonte da verdade: `Group_User`,
`Profile_User`, `User.profiles_id` ao vivo. Evidência: `audit_usuarios_reais.json`.

> **AÇÃO HUMANA NECESSÁRIA.** O CLAUDE.md proíbe agentes de alterar perfis/grupos/
> entidades de usuários reais. Esta auditoria **diagnostica**; a correção é do admin.

## Membros: g21=15, g22=19, g49=56 (87 usuários únicos)

## Técnicos (grupos 21/22) — 32 ativos
- **13 SEM perfil 11** (só abrem como Solicitante; não executam ação técnica):
  IDs `1248, 1320, 1362, 1459, 1492, 1513, 1518, 1722, 1747, 1776, 1807, 2056, 2159`.
  → **Ação:** conceder perfil 11 aos que forem realmente técnicos.
- **5 com perfil 11 mas `User.profiles_id` ≠ 11** (abrem no perfil errado):
  `1272, 1608, 1780, 1932, 2373`. (2373 é a conta de teste — default 9 é proposital.)
  → **Ação:** setar `profiles_id=11` para os técnicos reais.

## GG-Conservação (grupo 49) — 55 ativos
- Breakdown de `User.profiles_id`: **vazio(0)=29, 12=21, 9=3, 4=1, 11=1**.
- **21 com default=12** (perfil GG SEM CREATE) → abrem o app e **NÃO conseguem criar
  chamado** (`POST /Ticket`=400). **29 com default vazio** → GLPI escolhe no login
  (imprevisível). Só **3 com default=9** (correto).
  → **Ação:** setar `User.profiles_id=9` para os solicitantes GG (o 9 tem CREATE; o
  12 é handler/observador adicional).
- 1 sem perfil 9: `2266` (conta de teste gg-conservacao, só perfil 12 — proposital).

## Por que isto importa (liga com entidade)
Como **não há correção server-side de entidade** (ver `ENTITY_RESOLUTION.md`), o
`User.profiles_id` e a entidade padrão errados fazem o chamado nascer no perfil/
entidade errados. Corrigir as atribuições é pré-requisito para o app funcionar
certo para esses usuários — independente do código do app.

## Resumo da ação humana
1. Conceder perfil 11 aos 13 técnicos reais de g21/g22.
2. `profiles_id=11` para técnicos; `profiles_id=9` para os ~50 solicitantes GG.
3. Revalidar com este mesmo script após a correção.
