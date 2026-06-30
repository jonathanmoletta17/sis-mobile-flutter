# Divisão de Trabalho entre Agentes (Codex × Claude Code)

Objetivo: economizar tokens do Claude Code usando o **Codex** (`gpt-5.5 / xhigh`,
já instalado) para o que ele faz bem, reservando o Claude Code para o que só ele
faz com segurança neste projeto. Este doc é normativo e referenciado pelo
`AGENTS.md`.

## Princípio

> Claude **diagnostica e valida ao vivo** → escreve um **dossiê** → Codex
> **implementa** a partir do dossiê → Claude **revisa e valida** antes do commit.

Implementação delegada parte SEMPRE de um dossiê escrito. Nunca de suposição.

## Quem faz o quê

### Codex (`codex` no terminal) — barato, alta capacidade de implementação
- Implementação mecânica a partir de um dossiê fechado (passos claros, arquivos
  nomeados, critério de aceite).
- Refactors repetitivos e padronizados (renomear, extrair helper, propagar um
  padrão por N arquivos).
- Scaffolding de testes a partir de uma especificação dada.
- Rodar gates locais: `flutter analyze`, `flutter test`, `flutter pub get`,
  `flutter build web` (já liberados em `~/.codex/rules/default.rules`).
- Ajustes de documentação e comentários.

### Claude Code — reservar para o que exige julgamento ou acesso especial
- Diagnóstico de causa-raiz e classificação de bug (protocolo do `AGENTS.md`).
- **Validação ao vivo contra o GLPI real**: probes read-only via `curl` com as
  credenciais do `.env`, e validação visual no app via browser (Chrome MCP).
- Decisões de arquitetura, contratos de fonte-da-verdade, modelagem de domínio.
- Revisão crítica do que o Codex produziu antes do commit.
- Qualquer coisa que toque permissão/visibilidade/regra GLPI sem evidência prévia.

### Nunca delegar sem aprovação humana explícita (qualquer agente)
- Mutação contra tickets reais de usuários; `DELETE`/purge; método destrutivo via
  Worker pass-through. Ver `AGENTS.md` e `CLAUDE.md`.

## Pré-requisito de segurança (já configurado)

Antes de delegar implementação que toque GLPI/FormCreator, o Codex precisa
respeitar as **regras compartilhadas** — ver seção "Regras compartilhadas de
consumo do GLPI" no `AGENTS.md` (aponta para `.claude/rules/no-hardcode-glpi.md`
e o contrato FormCreator do `docs/quality/DOR.md`). Sem isso o Codex repete a
classe de erro de árvore/bitmask.

## Como invocar o Codex

```bash
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter
codex            # sessão interativa (projeto já é trusted)
# ou com um prompt direto / dossiê:
codex "Implemente o dossiê em docs/handoff/<arquivo>.md. Leia AGENTS.md primeiro."
```

## Template de dossiê de handoff (Claude → Codex)

Copie para `docs/handoff/<data>-<tema>.md` e preencha. Quanto mais fechado, menos
ida-e-volta.

```markdown
# Handoff: <título>

## Leia primeiro
- AGENTS.md (secao "Regras compartilhadas de consumo do GLPI")
- <docs/arquivos especificos relevantes>

## Contexto (1 paragrafo)
<por que esta mudança existe; o problema observado>

## Causa-raiz / decisao ja tomada (com evidencia)
<o que o Claude ja diagnosticou e validou ao vivo; não re-investigar>

## Escopo da implementacao (arquivos + mudança esperada)
- `lib/...`: <o que muda>
- `test/...`: <teste a criar/atualizar>

## Fora de escopo
- <o que NÃO tocar>

## Criterio de aceite (verificavel)
- [ ] `flutter analyze` limpo
- [ ] `flutter test` passa (inclui <teste novo>)
- [ ] <comportamento observavel concreto>
- [ ] Sem hardcode de regra GLPI; segue AGENTS.md

## O que DEIXAR para o Claude (nao fazer no Codex)
- Validacao ao vivo contra GLPI / validacao visual no app
- Commit final (apos revisao)
```

## Fluxo recomendado por tipo de tarefa

| Tarefa | Quem |
|---|---|
| "Por que X está errado no GLPI?" | Claude (diagnóstico + live) |
| "Implemente este dossiê fechado" | Codex |
| "Refatore Y em todos os N arquivos" | Codex |
| "Valide visualmente que Z funciona no app" | Claude (browser) |
| "Rode analyze/test e me diga o que quebrou" | Codex |
| "Decida a arquitetura de W" | Claude |
| "Revise o diff antes do commit" | Claude |

## Referências
- `AGENTS.md` — governança compartilhada e regras GLPI
- `docs/QUICK_BUILD_REFERENCE.md` — comandos de build/test/validação
- `docs/quality/DOR.md` / `docs/quality/DOD.md` — gates de qualidade
- `.claude/rules/no-hardcode-glpi.md` — regra normativa anti-hardcode GLPI
