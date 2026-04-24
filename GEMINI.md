# GEMINI

Contexto de projeto para Gemini CLI neste repositorio.

## Papel do Gemini aqui

- Gemini pode operar este repo como agente de implementacao e documentacao.
- Hoje o repo nao versiona configuracao Gemini propria nem extensao local.
- O papel principal deste arquivo e fornecer contexto de projeto, nao configurar runtime persistente do Gemini.

## O que consultar antes de mudar algo

1. `AGENTS.md`
2. `BOOTSTRAP.md`
3. `README.md`
4. `docs/README.md`
5. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
6. `docs/CONTROL_PLANE_LOCAL.md`

Consulte tambem conforme a mudanca:

- `docs/ACESSO_EXTERNO_CONTROLADO.md`
- `docs/android-distribution-playbook.md`
- `docs/entity-governance-and-android-testing.md`
- `docs/validation-and-testing-guide.md`

## Artefatos relevantes para Gemini

- `GEMINI.md`
- `AGENTS.md`
- `BOOTSTRAP.md`
- `docs/*.md`

Artefatos que NAO devem ser criados por inercia:

- `.gemini/settings.json`
- `gemini-extension.json`
- `.gemini/commands/*.toml`
- `.gemini/skills/*`

So materialize esses arquivos quando existir um workflow Gemini especifico deste repo que realmente precise deles.

## Validacao recomendada

- Documentacao pura: revisar coerencia dos docs operacionais.
- Mudanca de codigo: `flutter analyze` e `flutter test`.
- Mudanca em build ou runtime: revalidar tambem `tool/android/build_release.ps1` e a estrategia em `docs/ACESSO_EXTERNO_CONTROLADO.md`.

## Regras locais

- Nao misture contexto de projeto com settings persistentes de usuario.
- Se usar o Cerebro Central para busca semantica, trate o resultado como insumo de descoberta e confirme no repo atual.
- Se surgir ambiguidade entre o que pertence ao projeto e o que pertence ao runtime global do Gemini, prefira documentar primeiro o projeto.
- Nao trate bridge USB/LAN ou proxy de notebook como opcao valida de acesso externo.
