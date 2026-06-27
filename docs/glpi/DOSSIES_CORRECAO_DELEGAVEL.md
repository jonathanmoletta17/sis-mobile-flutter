# Dossiês de Correção Delegáveis — fase corretiva FormCreator

> **Para quem executa (Codex / Antigravity / outro agente):** cada dossiê abaixo é
> **auto-contido**. Implemente exatamente o especificado. NÃO improvise além do escopo.
> NÃO invente operadores/campos sem evidência — os números aqui vieram da API real do SIS
> (GLPI 10.0.2), registrados em `docs/discovery/glpi-live/`.
>
> **Status Codex 2026-06-27:** a validação Web/Admin + API live foi executada
> em modo read-only com credenciais do `.env`. O catálogo especializado foi
> regenerado para 25 sections, 1271 questions, 18 targets e 1191 conditions.
> O dossiê 1.3 foi aplicado. O dossiê 1.2 não foi aplicado nesta rodada porque
> os checklists ativos 48-52 validados ao vivo usam apenas `show_condition`
> 1/2; operadores 7/8 continuam como hardening futuro, não bug ativo
> comprovado nesse catálogo especializado.
>
> **Base de código:** branch `fix/onda0-rede-seguranca` (a partir do código vivo `1b94b12`).
> Baseline verde esperado: `flutter analyze` limpo e `flutter test` com todos
> os testes do repo, incluindo os testes novos do dossiê aplicado.

## Gate de aceite (comum a todos) — os 6 verdes

1. `/opt/flutter/bin/flutter analyze` → **No issues found**
2. `/opt/flutter/bin/flutter test` → todos verdes, incluindo os testes novos do dossiê
3. Teste novo cobrindo a mudança, com os casos especificados
4. (quando aplicável) validação ao vivo: `tool/glpi-discovery/` confirma os números citados
5. Diff revisado — sem tocar nada fora do escopo do dossiê
6. Commit atômico próprio, mensagem citando o dossiê e a evidência

---

## DOSSIÊ 1.2 — Operadores `show_condition` 7 (visível) e 8 (invisível)  ⭐ HARDENING FUTURO

Status 2026-06-27: não aplicado. A contagem 7/8 existe no universo
FormCreator/API global, mas a validação live dos checklists ativos 48-52
encontrou apenas operadores 1/2. Não tratar como correção de bug ativo sem
novo checklist vivo ou novo escopo explícito.

### Problema (com evidência)
Os formulários SIS usam estes operadores de condição (amostra de 800 condições reais):
`show_condition` **1 (igual)=626, 7 (visível)=125, 2 (diferente)=27, 8 (invisível)=23**;
operadores 3,4,5,6,9 = **ZERO**. Hoje o app trata só 1 e 2; **7 e 8 caem no `_ => false`**,
então **148 condições reais nunca casam** → visibilidade condicional quebrada nesses formulários.

### Insight técnico decisivo
Operadores 7/8 **NÃO comparam o valor da resposta** — eles checam se a **questão-fonte está
visível**. Logo, a correção **NÃO é em `SisChecklistCondition.matches(value)`** (que só enxerga
o valor) — é no **engine** `SisChecklistConditionEngine`, que tem acesso a `isQuestionVisible`.

### Arquivo e ponto exato
`lib/checklists/checklist_condition_engine.dart` → método `_conditionsMatch` (linha ~91-111),
hoje:
```dart
final matches = condition.matches(answers[condition.sourceQuestionId]);
```

### Mudança especificada
Antes de chamar `condition.matches(...)`, tratar 7/8 avaliando a visibilidade da questão-fonte:

```dart
bool _evalCondition(SisChecklistCondition c, Map<int, dynamic> answers, Set<int> visiting) {
  // show_condition 7 = fonte visível ; 8 = fonte invisível (validado SIS 10.0.2)
  if (c.showCondition == 7 || c.showCondition == 8) {
    final source = _questionById(c.sourceQuestionId);
    if (source == null) return c.showCondition == 8; // fonte ausente = "invisível"
    final sourceVisible = _isQuestionVisibleSafe(source, answers, visiting);
    return c.showCondition == 7 ? sourceVisible : !sourceVisible;
  }
  return c.matches(answers[c.sourceQuestionId]); // 1,2 como hoje; 3..9 não-usados => false
}
```
- Adicionar helper `_questionById(int id)` → `catalog.questions.firstWhere((q)=>q.id==id, orElse: ()=>null-equivalente)`.
- **Proteção anti-ciclo OBRIGATÓRIA:** propagar um `Set<int> visiting` por `isQuestionVisible`/
  `_isItemVisible`/`_conditionsMatch`. Ao entrar na questão `id`, se `visiting.contains(id)`
  retornar `true` (corta o ciclo de forma segura) e logar; senão `visiting.add(id)` antes de
  recursar e remover ao sair. Sem isso, A→visível(B)→visível(A) trava em loop infinito.
- **NÃO implementar** 3,4,5,6,9 (zero uso). Deixar caindo em `matches` (→ false), com comentário.

### Teste a escrever (`test/checklist_condition_visibility_test.dart`)
Montar um `SisChecklistCatalog` com 2 questões (fonte e dependente) e uma condição:
- fonte visível + condição op 7 → dependente **visível**;
- fonte visível + condição op 8 → dependente **oculta**;
- fonte oculta (por sua própria condição) + op 7 → dependente **oculta**; op 8 → **visível**;
- ciclo A↔B → não trava (test com timeout implícito) e resolve determinístico.
**Atualizar** `test/characterization/checklist_condition_operators_test.dart`: o teste de
`matches()` para op 7/8 **permanece** (matches não muda; o tratamento foi para o engine) — só
ajustar o comentário explicando que 7/8 agora são resolvidos pelo engine, não por `matches`.

### Riscos de regressão a vigiar
- Não alterar a semântica de 1/2 nem de `show_logic` (AND/OR) — só adicionar o ramo 7/8.
- Recursão sem guarda = travamento. O `Set visiting` é inegociável.
- `isSectionVisible` também chama `_conditionsMatch` → garantir que a assinatura nova
  (com `visiting`) seja propagada em todos os call sites.

---

## DOSSIÊ 1.3 — Seção respeita o próprio `show_rule`  ✅ APLICADO EM 2026-06-27

### Problema original (com evidência)
`PluginFormcreatorSection.show_rule` real no SIS: **1 (sempre)=166, 2 (condicional)=84**.
O engine ignorava esse campo: em `isSectionVisible` o `showRule` era **hardcoded como `2`**.
Efeito: uma seção `show_rule=1`
(sempre visível) que tenha condições configuradas seria avaliada como condicional e poderia
sumir. Caso raro hoje, mas é hardcode de algo que o GLPI entrega.

### Arquivo e ponto corrigido
`lib/checklists/checklist_condition_engine.dart`, método `isSectionVisible`:
```dart
showRule: section.showRule,
```

### Mudança executada
- `tool/checklists/build_sis_checklists_catalog.mjs` exporta `show_rule` de sections.
- `SisChecklistSection` expõe `showRule` (catalog `final int showRule;`, lido de `show_rule`).
- `_isItemVisible` já trata `showRule==1 → true` e `==3 → !match`.
- `isSectionVisible` deixou de forçar `2` e passou a usar `section.showRule`.

### Testes escritos
- seção `show_rule=1` **com** condição que não casaria → continua **visível**;
- seção `show_rule=2` com condição que casa → visível; que não casa → oculta;
- seção `show_rule=1` sem condição → visível (não regredir).

### Riscos de regressão
- O caso dominante hoje (show_rule=2 com condição, e show_rule=1 sem condição) **não pode
  mudar** de comportamento. Os testes acima travam isso.

---

## 1.1 — `show_tree_depth` (Localização)  ❌ NÃO delegar como correção pontual

**Por quê:** investigação provou que o app **não renderiza os formulários FormCreator do GLPI**
na criação de ticket — usa catálogo próprio (`service_catalog_repository`,
`service_data.dart`). O `SisChecklistOptionClient` só suporta `Ticket` e
`PluginGenericobjectConservacao` — **não `Location`**. Logo, **não existe ponto onde aplicar
`show_tree_depth`** sem antes tornar a Localização um campo renderizado a partir da questão
FormCreator. Adicionar um parser de `show_tree_depth` agora = código morto.

**Encaminhamento correto:** tratar como parte da refatoração maior *"app reflete os formulários
FormCreator do GLPI dinamicamente"* (relacionada ao cerne: catálogo próprio vs. projeção do
GLPI). Exige investigação dedicada + validação ao vivo — **não** é delegável por prompt estático.

---

## Correções NÃO investigadas — NÃO delegar ainda

Onda 2 (unificar 3 matchers de perfil) e Onda 3 (ler rights bitmask em vez de hardcode) **não
foram investigadas com a profundidade acima**. Como as 1.1/1.2 mostraram, cada uma revela
complexidade só ao ser investigada + validada ao vivo. Delegar um dossiê especulativo dessas a
um agente **sem acesso ao GLPI** (Codex/Antigravity na nuvem não alcançam a VPN interna)
reintroduz o risco de alucinação. Precisam de investigação com acesso ao GLPI antes de virarem
dossiê.
