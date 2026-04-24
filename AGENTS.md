# AGENTS.md

## Objetivo

- Manter este repositorio operavel como app Flutter da SIS para chamados GLPI.
- Priorizar validacao real de runtime e distribuicao Android antes de refactors amplos.

## Pontos de entrada

Leia nesta ordem antes de mudancas substanciais:

1. `BOOTSTRAP.md`
2. `README.md`
3. `docs/README.md`
4. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`

Leia tambem conforme o tipo de mudanca:

- `docs/entity-governance-and-android-testing.md`
- `docs/validation-and-testing-guide.md`
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`
- `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md`
- `docs/FRONTEND_SURFACE_DISCOVERY_FLUTTER.md`
- `docs/FRONTEND_SKILLS_FLUTTER.md`
- `docs/WIDGETBOOK_WORKBENCH.md`
- `docs/ACESSO_EXTERNO_CONTROLADO.md`
- `docs/android-distribution-playbook.md`
- `docs/CONTROL_PLANE_LOCAL.md`
- `GEMINI.md`
- `CLAUDE.md`
- `HERMES.md`

## Contexto externo

- O Cerebro Central em `C:\Users\jonathan-moletta\code\inteligencia-md-local\cerebro_central` pode ser usado como contexto auxiliar para padroes e historico cross-project.
- Trate o Cerebro como fonte consultiva. A decisao final precisa bater com os arquivos e scripts deste repo.

## Protocolo Cerebro Central

- Para tarefas nao triviais, discovery, planejamento, governanca, desenho de runtime, modelagem para control plane ou duvidas cross-project, consulte o Cerebro Central antes de propor estrutura final.
- Use o Cerebro para:
  - encontrar docs analogos
  - recuperar decisoes e padroes ja usados
  - reduzir invencao desnecessaria de artefatos e formatos
- Se o Cerebro estiver indisponivel, registre isso explicitamente e siga pela alternativa mais conservadora.
- O Cerebro nao substitui a leitura do repo atual; ele entra cedo no fluxo para melhorar a descoberta e a idealizacao.

## Validacao obrigatoria

- Mudanca documental pura: revisar coerencia entre `README.md`, `docs/README.md` e `docs/RUNTIME_CANONICO_E_VALIDACAO.md`.
- Mudanca visual relevante: modelar ou atualizar o use case no `widgetbook/` e rodar `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1`.
- Atualizacao de baseline visual: usar `powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens` e registrar que a mudanca de golden foi intencional.
- Mudanca de codigo nao trivial: rodar `flutter analyze` e `flutter test`.
- Mudanca em build Android, acesso externo, `.env` ou runtime: revalidar tambem os scripts em `tool/`.
- Mudanca que afete distribuicao: usar `tool/android/build_release.ps1`.

## Regras de edicao

- Nao reverta mudancas do usuario sem pedido explicito.
- Nao invente arquivos de configuracao de CLI, MCP ou skill sem necessidade concreta confirmada neste repo.
- Separe contexto de projeto de configuracao persistente de usuario.
- Prefira artefatos pequenos, normativos e sustentaveis.
- Nao promova redesign ou mudanca visual importante direto em `lib/` sem laboratorio visual e baseline local.
- Nao reintroduza bridge USB/LAN, `adb reverse` ou proxy de notebook como solucao suportada para acesso externo.

## Formato de entrega

- Relatar o que foi encontrado, o que foi criado e o que foi validado.
- Citar caminhos exatos dos arquivos e comandos realmente executados.
- Se alguma validacao nao puder ser executada, dizer isso explicitamente.
