# CLAUDE

**Este é o projeto SIS Mobile, um aplicativo Flutter. Siga rigorosamente a arquitetura descrita no HERMES.md e AGENTS.md.**

Contexto de projeto para Claude neste repositório.

## Papel do Claude aqui

- Claude pode operar este repo como agente geral de codigo e documentacao.
- Este repositorio nao versiona hoje configuracoes locais do Claude nem manifesto MCP proprio.
- O valor deste arquivo e orientar a operacao no escopo de projeto.

## O que consultar antes de mudar algo

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
6. `docs/CONTROL_PLANE_LOCAL.md`

## Artefatos relevantes para Claude

- `CLAUDE.md`
- `AGENTS.md`
- `BOOTSTRAP.md`
- `docs/*.md`

Artefatos que nao devem ser criados sem caso de uso concreto:

- `.claude/settings.json`
- `.claude/settings.local.json`
- `.mcp.json`

## Validacao recomendada

- Mudanca documental: revisar consistencia entre os docs principais.
- Mudanca de codigo: `flutter analyze` e `flutter test`.
- Mudanca de build ou distribuicao: usar os scripts oficiais em `tool/android/`.

## Regras locais

- Nao promova configuracao global do Claude para dentro do repo sem necessidade real.
- O projeto depende de rede interna ou VPN para validacao plena contra o GLPI real.
- Use este arquivo como contexto de projeto; trate qualquer configuracao persistente do Claude como user-scope.
