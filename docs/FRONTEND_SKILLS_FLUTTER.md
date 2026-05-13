# Skills Frontend Flutter

## Objetivo

Este documento define contratos de skills planejadas para o fluxo profissional de frontend do SIS Mobile.

Ele nao instala skills em `C:\Users\jonathan-moletta\.codex\skills` e nao altera configuracao persistente do usuario.

O objetivo aqui e manter um blueprint de projeto para futuras skills do Codex, alinhado aos documentos e scripts reais deste repo.

## Regra de promocao

Uma skill so deve virar artefato instalado quando houver uso recorrente comprovado.

Antes de criar uma skill real:

1. confirmar que o fluxo ja esta descrito neste repo
2. confirmar que o fluxo tem comandos ou artefatos estaveis
3. usar a skill `skill-creator`
4. decidir explicitamente se a skill sera global do usuario ou local de plugin/projeto
5. validar a skill com o validador recomendado pela `skill-creator`

## Contrato comum

Toda skill futura deste repo deve:

- ler `AGENTS.md`, `BOOTSTRAP.md`, `README.md`, `docs/README.md` e `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
- usar contexto cross-project apenas quando ele existir no filesystem atual e for relevante
- tratar o repo atual como fonte decisiva
- nao reintroduzir bridge USB/LAN, `adb reverse` ou proxy de notebook como solucao suportada
- nao promover redesign direto em `lib/` sem Widgetbook e baseline local
- reportar o que foi encontrado, criado e validado
- citar comandos realmente executados

## Sequencia recomendada

```text
frontend-director
  -> design-lab
  -> widgetbook-workbench
  -> visual-guard
  -> runtime-evidence
  -> service-content-governance quando a mudanca afetar linguagem, erro, vazio ou acessibilidade
```

## 1. sis-flutter-frontend-director

Uso:

- discovery antes de redesign
- tese visual
- classificacao de superficies criticas
- escolha entre direcoes de produto

Entradas obrigatorias:

- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- `docs/FRONTEND_PROFISSIONAL_FLUTTER.md`
- `docs/PLANO_LABORATORIO_E_GUARDA_VISUAL_FLUTTER.md`
- contexto cross-project local, quando disponivel

Saida esperada:

- tese visual curta
- superficies priorizadas
- riscos de produto e operacao
- decisao do que nao deve ser implementado ainda

Nao deve:

- editar UI de producao
- criar tokens definitivos sem validar no workbench
- aprovar runtime como laboratorio visual

## 2. sis-flutter-design-lab

Uso:

- transformar tese visual em exploracoes no Stitch ou Figma
- comparar 2 ou 3 direcoes visuais
- preparar handoff para componentes Flutter

Entradas obrigatorias:

- tese do `sis-flutter-frontend-director`
- restricoes de marca, acessibilidade e operacao
- superficies prioritarias

Saida esperada:

- direcoes comparadas por criterio
- recomendacao de linguagem visual
- lista de tokens, componentes e estados a validar

Nao deve:

- pular para `lib/`
- tratar imagem bonita como decisao de sistema
- ignorar loading, empty, error, disabled e offline

## 3. sis-flutter-widgetbook-workbench

Uso:

- criar ou atualizar use cases no `widgetbook/`
- modelar estados reais de componentes e superficies
- isolar fixtures antes do runtime

Entradas obrigatorias:

- `docs/WIDGETBOOK_WORKBENCH.md`
- `widgetbook/lib/`
- componente ou superficie real do produto

Saida esperada:

- use case no Widgetbook
- fixture controlada
- cobertura de estados relevantes

Gate:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

Nao deve:

- criar demos genericas sem relacao com o produto
- esconder estado vazio, loading ou erro
- depender de relogio da maquina quando houver tempo relativo

## 4. sis-flutter-visual-guard

Uso:

- proteger mudanca visual com Alchemist
- revisar baseline de golden
- decidir se um diff visual e intencional

Entradas obrigatorias:

- `widgetbook/test/visual/`
- `docs/WIDGETBOOK_WORKBENCH.md`
- superficie ou componente afetado

Saida esperada:

- baseline validada
- decisao explicita sobre snapshots
- risco residual documentado

Gate normal:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

Atualizacao intencional:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

Nao deve:

- aceitar screenshot de runtime como substituto de baseline
- atualizar golden sem revisar diff
- manter tooling experimental no caminho canonico

## 5. sis-flutter-runtime-evidence

Uso:

- provar que a UI validada localmente funciona no runtime real
- validar Android, `.env`, GLPI e distribuicao
- produzir evidencia de fluxo ponta a ponta

Entradas obrigatorias:

- `docs/RUNTIME_CANONICO_E_VALIDACAO.md`
- `docs/ACESSO_EXTERNO_CONTROLADO.md`, quando houver rede ou acesso externo
- `docs/android-distribution-playbook.md`, quando houver distribuicao

Saida esperada:

- comandos executados
- ambiente usado
- resultado de Android/web/release
- bloqueios de rede ou GLPI, quando existirem

Nao deve:

- usar bridge USB/LAN como solucao suportada
- considerar build web suficiente para release Android
- ignorar que o GLPI da SIS e interno

## 6. sis-flutter-service-content-governance

Uso:

- revisar labels, erros, hints, empty states e CTA
- endurecer linguagem institucional e operacional
- checar acessibilidade de conteudo

Entradas obrigatorias:

- superficie afetada
- estados reais da superficie
- `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`

Saida esperada:

- texto recomendado
- riscos de ambiguidade
- ajustes de hierarquia e acessibilidade

Nao deve:

- trocar regra de negocio
- transformar comunicacao operacional em linguagem promocional
- aceitar placeholder como unico label de campo

## Estado atual

Neste momento, estes contratos sao blueprint documental.

O caminho implementado no repo ja existe para:

- `widgetbook/`
- `tool/frontend/validate_widgetbook.ps1`
- goldens Alchemist em `widgetbook/test/visual/`

As skills reais devem ser criadas apenas se a equipe decidir promove-las para uso recorrente fora deste documento.
