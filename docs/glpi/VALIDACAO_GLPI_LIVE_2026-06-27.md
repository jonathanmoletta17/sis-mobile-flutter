# Validação GLPI live — Web/Admin, API e limite BD

Data: 2026-06-27
Branch: `fix/onda0-rede-seguranca`
Escopo: validação read-only contra GLPI SIS vivo, usando credenciais do `.env`.

## Fronteira executada

Executado:

- autenticação API live no GLPI SIS interno via `SIS_TEST_BASE_URL`;
- autenticação Web GLPI com perfil admin;
- navegação real no menu `Administração > Formulários`;
- inspeção Web dos forms FormCreator 48-52;
- inspeção Web dos tabs `Questões`, `Alvos` e `Pré-visualização` do form 48;
- comparação API live contra asset/fixture/Worker locais.

Não executado:

- mutação de ticket real;
- criação/edição/salvamento de formulário;
- clique em botão `Salvar`;
- uso de Worker pass-through destrutivo;
- consulta direta ao banco MariaDB/MySQL.

Motivo do bloqueio BD direto:

- `.env` não contém credenciais DB;
- neste WSL não há `mysql`/`mariadb` CLI disponível;
- só existe `sqlite3`, que não consulta o banco GLPI vivo.

Portanto, Web/Admin e API live foram validados; BD live direto segue pendente até existir credencial/cliente DB ou outro canal read-only autorizado.

## API live

Autenticação:

- `GET /initSession` com Basic Auth e `App-Token`;
- session criada e encerrada com `killSession`;
- tokens e credenciais não foram impressos.

Contagens live:

| Entidade API | Linhas live |
| --- | ---: |
| `PluginFormcreatorForm` | 41 |
| `PluginFormcreatorSection` | 250 |
| `PluginFormcreatorQuestion` | 7011 |
| `PluginFormcreatorCondition` | 6598 |
| `PluginFormcreatorTargetTicket` | 242 |
| `PluginFormcreatorForm_Profile` | 52 |
| `ITILCategory` | 109 |
| `Location` | 422 |
| `RuleCriteria` | 262 |
| `RuleAction` | 297 |
| `Profile` | 11 |
| `ProfileRight` | 1166 |
| `Entity` | 85 |
| `Group` | 99 |

Distribuição global live:

| Campo | Distribuição |
| --- | --- |
| forms active/visible/helpdesk | `(1,1,1)=39`, `(0,1,1)=2` |
| `PluginFormcreatorCondition.show_condition` | `1=5006`, `2=1444`, `7=125`, `8=23` |
| condition `itemtype` | `Question=6074`, `TargetTicket=352`, `Section=172` |
| `PluginFormcreatorSection.show_rule` | `1=166`, `2=84` |
| `PluginFormcreatorQuestion.show_rule` | `1=1759`, `2=5252` |
| `PluginFormcreatorTargetTicket.show_rule` | `1=15`, `2=227` |

Diferença contra snapshots/Worker antigos:

| Métrica | Snapshot/Worker antigo | API live 2026-06-27 | Diferença |
| --- | ---: | ---: | ---: |
| forms | 41 | 41 | 0 |
| sections | 249 | 250 | +1 |
| questions | 6992 | 7011 | +19 |
| conditions | 6582 | 6598 | +16 |
| targettickets | 241 | 242 | +1 |
| categories | 109 | 109 | 0 |
| locations | 422 | 422 | 0 |
| rule criteria | 262 | 262 | 0 |
| rule actions | 297 | 297 | 0 |
| entities | 85 | 85 | 0 |

## Checklists ativos 48-52 — API live

Totais live:

| Item | Live API | Asset/fixture local | Diferença |
| --- | ---: | ---: | ---: |
| forms | 5 | 5 | 0 |
| sections | 25 | 24 | +1 |
| questions | 1271 | 1252 | +19 |
| targets | 18 | 17 | +1 |
| conditions | 1191 | 1175 | +16 |

Target novo no GLPI vivo:

- `PluginFormcreatorTargetTicket.id=369`
- form `50`
- nome `HIDRÁULICO 951`
- `show_rule=2`
- `category_rule=2`
- `location_rule=2`
- `location_question=83`

Esse target não existe em:

- `assets/sis_checklists_catalog.json`;
- `test/fixtures/sis_checklists_catalog.json`;
- `tool/external-access/workers-vpc/src/checklist_catalog.js`;
- `tool/external-access/workers-vpc/src/metadata_catalog.js`.

Target ids live:

```text
316, 325, 326, 337, 341, 342, 343, 344, 350, 359, 362, 363, 364, 365, 366, 367, 368, 369
```

Target ids locais/Worker:

```text
316, 325, 326, 337, 341, 342, 343, 344, 350, 359, 362, 363, 364, 365, 366, 367, 368
```

Conclusão: o catálogo embarcado está stale em relação ao GLPI vivo.

## Checklists ativos por form — API live

### Form 48 — CHECKLIST REFRIGERAÇÃO

- sections: 4 (`show_rule`: `1=1`, `2=3`)
- questions: 111 (`show_rule`: `1=30`, `2=81`)
- targets: 316, 325, 326
- conditions: 83 (`show_condition`: `1=6`, `2=77`)
- section conditions: 3
- question conditions: 77
- target conditions: 3

### Form 49 — CHECKLIST CALHAS E PLUVIAIS

- sections: 2 (`show_rule`: `1=2`)
- questions: 67 (`show_rule`: `1=3`, `2=64`)
- targets: 337
- conditions: 64 (`show_condition`: `1=37`, `2=27`)
- question conditions: 64

### Form 50 — CHECKLIST HIDRÁULICO

- sections: 7 (`show_rule`: `1=1`, `2=6`)
- questions: 254 (`show_rule`: `1=66`, `2=188`)
- targets: 341, 342, 343, 344, 350, 369
- conditions: 200 (`show_condition`: `1=12`, `2=188`)
- section conditions: 6
- question conditions: 188
- target conditions: 6

### Form 51 — CHECKLIST PEDRAS PORTUGUESAS

- sections: 2 (`show_rule`: `1=2`)
- questions: 20 (`show_rule`: `1=8`, `2=12`)
- targets: 359
- conditions: 12 (`show_condition`: `2=12`)
- question conditions: 12

### Form 52 — CHECKLIST ILUMINAÇÃO

- sections: 10 (`show_rule`: `1=1`, `2=9`)
- questions: 819 (`show_rule`: `1=138`, `2=681`)
- targets: 362, 363, 364, 365, 366, 367, 368
- conditions: 832 (`show_condition`: `1=717`, `2=115`)
- section conditions: 16
- question conditions: 802
- target conditions: 14

## Operadores 7/8 no escopo ativo

Resultado live para checklists 48-52:

- `show_condition=1`: presente;
- `show_condition=2`: presente;
- `show_condition=7`: ausente;
- `show_condition=8`: ausente;
- `show_condition=3/4/5/6/9`: ausente.

Conclusão:

- operadores 7/8 existem globalmente no GLPI vivo (`125` e `23`);
- operadores 7/8 não aparecem nos checklists ativos 48-52 nesta validação live;
- dossiê 1.2 continua não comprovado como bug ativo dos checklists 48-52;
- pode ser hardening futuro, não correção urgente comprovada desse fluxo.

## `show_rule` de sections no escopo ativo

Resultado live:

- sections ativas 48-52: 25;
- `show_rule=1`: 7;
- `show_rule=2`: 18;
- conditions de section: 25;
- todas as conditions de section estão em sections `show_rule=2`;
- nenhuma section ativa `show_rule=1` tem condition.

Conclusão:

- o GLPI vivo confirma que section tem `show_rule`;
- o catálogo local está incompleto porque não preserva esse campo;
- o hardcode local `showRule: 2` não foi provado como quebra atual de section `show_rule=1` com condition, porque esse caso não existe nos checklists vivos validados;
- dossiê 1.3 deve ser reescrito como atualização de modelo/builder/fixture, não como one-line fix.

## GLPI Web/Admin

Validação Web executada com Playwright headless e Chrome do sistema (`/usr/bin/google-chrome`).

Autenticação:

- login no GLPI Web bem-sucedido;
- URL após login: `/sis/front/central.php`;
- perfil visível: `Super-Admin`;
- menu lateral contém `Administração`.

Menu Administração:

- link `Administração > Formulários` encontrado;
- URL administrativa: `/sis/plugins/formcreator/front/form.php`;
- página abriu com título `Form Creator - GLPI`.

Lista administrativa confirmou:

| ID | Nome | Categoria | Página inicial | Acesso |
| ---: | --- | --- | --- | --- |
| 48 | CHECKLIST REFRIGERAÇÃO | DMCPP | Sim | Acesso restrito |
| 49 | CHECKLIST CALHAS E PLUVIAIS | DMCPP | Sim | Acesso restrito |
| 50 | CHECKLIST HIDRÁULICO | DMCPP | Sim | Acesso restrito |
| 51 | CHECKLIST PEDRAS PORTUGUESAS | DMCPP | Sim | Acesso restrito |
| 52 | CHECKLIST ILUMINAÇÃO | DMCPP | Sim | Acesso restrito |

Tabs Web por form:

| Form | Nome | Questões | Alvos | Respostas |
| ---: | --- | ---: | ---: | ---: |
| 48 | CHECKLIST REFRIGERAÇÃO | 111 | 3 | 4 |
| 49 | CHECKLIST CALHAS E PLUVIAIS | 67 | 1 | 13 |
| 50 | CHECKLIST HIDRÁULICO | 254 | 6 | 8 |
| 51 | CHECKLIST PEDRAS PORTUGUESAS | 20 | 1 | 5 |
| 52 | CHECKLIST ILUMINAÇÃO | 819 | 7 | 14 |

Targets Web por form:

| Form | Targets |
| ---: | --- |
| 48 | 316 `REFRIGERAÇÃO AR CENTRAL`; 325 `REFRIGERAÇÃO 1005`; 326 `REFRIGERAÇÃO 951` |
| 49 | 337 `CHECKLIST CALHAS E PLUVIAIS` |
| 50 | 341 `HIDRÁULICO ALA RESIDÊNCIAL`; 342 `HIDRÁULICO ALA GOVERNAMENTAL`; 343 `HIDRÁULICO GALPÃO`; 344 `HIDRÁULICO GARAGEM`; 350 `HIDRÁULICO Casa Civil 1005`; 369 `HIDRÁULICO 951` |
| 51 | 359 `PEDRAS PORTUGUESAS` |
| 52 | 362 `ILUMINAÇÂO ALA RESIDENCIAL 3º Pavimento`; 363 `ILUMINAÇÂO ALA GOVERNAMENTAL - 1º Pavimento`; 364 `ILUMINAÇÂO ALA RESIDENCIAL - 2º Pavimento`; 365 `ILUMINAÇÂO ALA RESIDENCIAL 1º Pavimento`; 366 `ILUMINAÇÂO ALA GOVERNAMENTAL - 2º Pavimento`; 367 `ILUMINAÇÂO ALA GOVERNAMENTAL - 3º Pavimento`; 368 `ILUMINAÇÂO ALA GOVERNAMENTAL - 4º Pavimento` |

O tab `Pré-visualização` do form 48 abriu e renderizou o checklist, confirmando que a UI FormCreator Web está operacional para esse form. Nenhum envio foi feito.

## Impacto sobre os dossiês

### Dossiê 1.2

Status após live:

- semântica upstream 7/8 continua correta;
- API live global confirma 7/8 no GLPI;
- API live dos checklists 48-52 confirma zero 7/8;
- não é bug ativo comprovado no catálogo de checklists atual;
- se implementado, deve ser tratado como hardening defensivo com escopo explícito.

### Dossiê 1.3

Status após live:

- Web/API confirmam que sections vivas têm `show_rule`;
- o app/fixture/asset local não preserva o campo;
- existe divergência live vs local;
- porém nenhuma section `show_rule=1` ativa tem condition, então o hardcode não quebrou esse caso específico agora;
- a correção deve começar por discovery/builder/model/fixture, não por troca isolada no engine.

### `show_tree_depth`

Status após live:

- API live confirma perguntas com `itemtype=Location` e `values` contendo `show_tree_depth`, `show_tree_root`, `selectable_tree_root`;
- exemplo live: questão `3`, `Localização`, `show_tree_depth=2`, `show_tree_root=70`;
- a decisão continua sendo de contrato: ou o Worker poda e o Flutter consome opções prontas, ou o Flutter passa a preservar/aplicar esse metadado.

## Próximo passo obrigatório

Status de execução após esta validação: o catálogo especializado foi
regenerado a partir do GLPI vivo, incluindo o target `369`, e agora deve
reconciliar com:

- 5 forms;
- 25 sections;
- 1271 questions;
- 18 targets;
- 1191 conditions.

Antes de implementar qualquer dossiê antigo:

1. confirmar que asset/fixture/Worker especializado ainda carregam:
   - 5 forms;
   - 25 sections;
   - 1271 questions;
   - 18 targets;
   - 1191 conditions;
2. reavaliar testes e implementação.

BD direto continua pendente e deve ser tratado como gate separado, não como já validado.
