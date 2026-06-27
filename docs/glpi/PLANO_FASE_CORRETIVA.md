# Plano da Fase Corretiva — método anti-regressão e anti-alucinação

> **Objetivo:** corrigir o débito técnico (app hardcoda o que o GLPI entrega dinâmico) **sem
> regressão** e **sem decisões alucinadas**, consolidando consistência **com evidência após
> cada ação**. Este documento é a âncora: toda sessão de código relê isto antes de agir.

## 0. Estado de partida (medido, não suposto — 2026-06-27)

- **Baseline VERDE:** `flutter analyze` = 0 issues; `flutter test` = **215 passados**, 14 skip.
- **Evidência ao vivo do GLPI:** `tool/glpi-discovery/*.sh` + `docs/discovery/glpi-live/`
  (cobertura validada SIS 10.0.2; `show_tree_depth` real confirmado).
- **Governança ativa:** Princípio de Projeção Dinâmica no `CLAUDE.md` (carregado toda sessão).
- **Lacunas de teste nas áreas a tocar:** condition engine (**0 testes**), `show_tree_depth`
  (**0 testes**). 3 matchers de perfil duplicados (`operational_role`,
  `app_state_ticket_support`, `dtic_ticket_detail_screen`).

## 1. Os dois inimigos e como neutralizá-los

### Inimigo A — REGRESSÃO (quebrar o que funciona, ex.: anexos)
1. **Baseline verde documentado** (acima) — referência objetiva.
2. **Characterization test antes de mudar** qualquer área sem cobertura: primeiro um teste que
   captura o comportamento ATUAL, depois a mudança. A diferença fica visível, nunca silenciosa.
3. **Commit atômico:** 1 correção = 1 commit. Nunca empacotar.
4. **Proteção reforçada em anexos** (área que custou caro): teste de caracterização antes de
   tocar qualquer coisa no raio de anexos.

### Inimigo B — ALUCINAÇÃO (Claude decidir errado sobre o GLPI)
1. **Evidência é o árbitro, não a opinião:** toda decisão de código aponta para um JSON real
   (`docs/discovery/glpi-live/evidence/`) ou uma validação ao vivo via `tool/glpi-discovery`.
   Proibido "eu acho que o GLPI faz X".
2. **Governança carregada** toda sessão (Projeção Dinâmica) + **`.claude/rules/` path-scoped**
   (a criar) que dispara a premissa anti-hardcode ao editar `lib/policy/**`.
3. **Contrato da mudança** escrito antes de cada correção: qual evidência justifica, qual o
   comportamento esperado, qual endpoint/campo é a fonte.
4. **Revisão adversarial do diff** (subagente cético) antes do commit — procura regressão.

## 2. Gate de Consistência — "Definition of Done" por correção

Nenhuma correção é considerada fechada sem os **6 verdes**:
1. ✅ `flutter analyze` limpo
2. ✅ Suite completa verde (215 baseline + testes novos)
3. ✅ Teste novo cobrindo a mudança, **ancorado em evidência real**
4. ✅ (se toca GLPI) validação ao vivo read-only confirma **paridade app ↔ API**
5. ✅ Diff revisado adversarialmente (sem regressão)
6. ✅ Commit atômico próprio, mensagem citando a evidência

> Reporto os 6 verdes ao usuário **após cada correção**. Nunca sigo com algo vermelho.

## 3. Sequência (risco crescente, isolamento decrescente)

### Onda 0 — Rede de segurança (antes de qualquer mudança de comportamento)
- Characterization tests das áreas sem cobertura: condition engine, `show_tree_depth`.
- Reforço de teste em anexos (se a cobertura atual de 43 linhas não bastar).
- Criar `.claude/rules/no-hardcode-glpi.md` (path-scoped em `lib/policy/**`, `lib/models/*`).
- Branch de código a partir de `main` (código separado de docs/governança).

### Onda 1 — Correções locais, aditivas, baixo risco (não tocam permissões)
1.1 **`show_tree_depth`** — parsear `values` JSON da questão `Location` e podar a árvore.
    Evidência: id=3 depth=2/root=70 (já capturado). Aditivo: hoje é ignorado.
1.2 **9 operadores de `show_condition`** — engine hoje só trata `==1` (igual); cobrir 1–9.
1.3 **`show_rule` de seção** — aplicar visibilidade condicional de seção.

### Onda 2 — Consolidação de duplicação (refactor SEM mudar comportamento)
2.1 Unificar os 3 matchers de perfil num só ponto. Characterization tests garantem paridade
    byte-a-byte do comportamento antes/depois.

### Onda 3 — Refatoração sistêmica (alto risco, o cerne — máxima rede)
3.1 Worker expõe `changeActiveProfile` (infra; hoje não exposto).
3.2 Ler **rights (bitmask)** de `getFullSession` em vez de string-match de perfil + IDs de
    grupo hardcoded. **Migração com fallback paralelo:** novo caminho roda ao lado do antigo,
    compara resultados; só corta o hardcode após paridade provada.
3.3 Validação ao vivo com os **5 perfis reais** da conta de teste (4/6/9/11/28) via
    `changeActiveProfile` — cada perfil confirma a visibilidade esperada.
3.4 Remover o hardcode (IDs 21/22/49, nomes de perfil) **só** após 3.2/3.3 verdes.

## 4. Controle de processo (anti-viagem)
- **Aprovação por onda** antes de executar.
- Reportar os 6 verdes após **cada** correção; nunca empacotar; nunca seguir com vermelho.
- Evidência > opinião, sempre. Em dúvida sobre o GLPI: rodar `tool/glpi-discovery`, não supor.
- Cada onda referencia esta ordem; desvios exigem aprovação explícita do usuário.
