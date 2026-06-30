# Handoff: Harness de certificação por papel (regressão automatizada F1/F2/F6)

## Leia primeiro
- `AGENTS.md` (seção "Regras compartilhadas de consumo do GLPI")
- `docs/validation/CERTIFICACAO_PERFIS_REGRAS_2026-06-28.md` (matriz mestre)
- `docs/validation/RELATORIO_CERTIFICACAO_2026-06-28.md` (resultados + regras R1/R2)
- `test/validation/sis_mutable_validation_test.dart` (harness existente a estender)

## Contexto
A certificação de perfis/regras foi feita ao vivo (read-only + mutação marcada) e
documentada. Falta torná-la **regressão automatizada**: um teste Dart parametrizado
por papel que reexecute F1 (direitos), F2 (visibilidade) e F6 (transições) contra o
GLPI vivo, para detectar drift no futuro. Já existe `initSession`+`changeActiveProfile`
no harness atual — ESTENDER, não recriar.

## Causa-raiz / decisão já tomada (com evidência — não re-investigar)
- Conta 2373 tem perfis {9,11,12} + grupos {21,22,49} → simula os 4 papéis sem admin.
- F1 bitmask esperado: 9=5, 11=260102, 12=145411 (estável, idêntico a 2026-06-25).
- F2: ordenação de scope 9 < 12 < 11 (counts driftam — asserir ORDENAÇÃO, não número).
- F6 governado por bitmask UPDATE **E** (R1 requerente-precedência OU R2 escopo de
  entidade). Ver `output/playwright/certificacao-2026-06-28/FASE2_MUTACAO_F6.md`.

## Escopo da implementação
- `test/validation/sis_mutable_validation_test.dart`:
  - Teste read-only parametrizado por perfil [9,11,12]: `initSession` →
    `changeActiveProfile(pid)` → `getFullSession` → asserir
    `glpiactiveprofile['ticket']` == {9:5, 11:260102, 12:145411}.
  - Teste read-only de visibilidade: capturar `search/Ticket totalcount` por perfil
    e asserir a ORDENAÇÃO (count[9] < count[12] < count[11]).
  - Teste de mutação FLAG-GATED (só roda com `SIS_ALLOW_MUTATION=true`): criar ticket
    marcado `[TESTE-AUTOMATIZADO SIS] [CERTIFICACAO-<data>]` como perfil 9; asserir
    POST=201; asserir POST /Ticket como perfil 12 == 400 (sem CREATE); cleanup
    (fechar status=6) + `print` do ID criado para auditoria.
  - Documentar R1/R2 em comentário no teste (não tentar asserir status cross-perfil
    sem controlar escopo de entidade — o ticket precisa estar no escopo do perfil
    que age, senão dá 403 por R2).

## Fora de escopo
- Bridge A (catálogo vs Form_Profile/ITILCategory) — exige admin; não automatizar agora.
- Validação visual (browser) — fica com o Claude.
- Não tocar lógica de produção em `lib/`.

## Critério de aceite (verificável)
- [ ] `flutter analyze` limpo
- [ ] `flutter test test/validation/sis_mutable_validation_test.dart` passa em modo
      read-only (sem `SIS_ALLOW_MUTATION`)
- [ ] Os asserts de bitmask por perfil batem com {5, 260102, 145411}
- [ ] Mutação só roda sob flag explícita, com prefixo de marcação e cleanup
- [ ] Sem hardcode de regra GLPI fora do contrato; segue AGENTS.md

## O que DEIXAR para o Claude (não fazer no Codex)
- Certificação Bridge A (precisa de admin) e validação visual por perfil
- Commit final (após revisão do Claude)
