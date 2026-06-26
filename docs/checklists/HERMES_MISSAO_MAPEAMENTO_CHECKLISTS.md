# Missão Hermes — Mapeamento Profundo de Checklists SIS no GLPI

> **Natureza desta missão:** coleta, mapeamento e documentação read-only.
> Nenhuma mutação no GLPI. Nenhum formulário enviado. Nenhuma conta criada ou
> modificada. Apenas navegação, leitura e extração de dados.

## Contexto

O app Flutter SIS implementou (em 2026-06-21) um fluxo especializado de
checklists baseado em FormCreator. A implementação usa um snapshot local
capturado em 2026-06-10 (`/home/jonathan/.brain/glpi-governance/2026-06-10-api/`).

O snapshot já cobre os forms 48-52, ~6992 questões, conditions, 17 targets
ativos e as RuleTickets principais. Mas há lacunas:

- O snapshot pode estar desatualizado (11 dias passados).
- `PluginGenericobjectConservacao` não está mapeado em detalhe (itens,
  campos, volume de registros usáveis).
- O perfil real de operação de checklist (quem usa no dia a dia) não está
  confirmado — o gate atual usa apenas `Super-Admin` (profiles_id=4) porque
  foi o único encontrado em `formcreator_forms_profiles`.
- Nenhuma submissão sintética foi executada — a forma real do ticket criado
  pelo FormCreator não foi verificada ao vivo.
- Comportamento web do FormCreator para esses forms não foi observado
  (quantas seções aparecem, quais condições disparam, fluxo de navegação).

## Objetivo da missão

Acessar o GLPI SIS diretamente pela web (interface administrativa e helpdesk)
e coletar o mapeamento mais completo possível dos checklists:

1. Estado atual dos forms 48-52 (e verificar se existem outros checklists).
2. Estrutura de seções e perguntas (fieldtypes, required, valores, condições).
3. Targets de cada form (categoria, entidade, atores FormCreator).
4. Perfis que enxergam cada form (`formcreator_forms_profiles`).
5. `PluginGenericobjectConservacao`: campos, registros ativos, uso nos forms.
6. RuleTickets que disparam sobre tickets criados por estes forms.
7. Comportamento observado ao navegar o formulário web (seções visíveis,
   condições, campos obrigatórios).
8. Comparar tudo com o snapshot local 2026-06-10 e registrar divergências.

## Fontes de acesso (read-only)

### GLPI SIS — interface web de administração

URL base: acessar via rede interna ou VPN conforme configurado.
Login: conta de teste dedicada (`SIS_TEST_USER`/`SIS_TEST_PASSWORD` no `.env`).

Se a conta de teste não tiver acesso ao painel de administração FormCreator,
alternar para o perfil `Super-Admin` via `changeActiveProfile` (GLPI direto
— o Worker não expõe essa rota). Não usar usuário real de produção.

### API REST GLPI (read-only)

Endpoint base: conforme `GLPI_BASE_URL` no `.env`.

Rotas úteis (todas GET, sem mutação):

```
GET /PluginFormcreatorForm?range=0-999
GET /PluginFormcreatorForm/<id>
GET /PluginFormcreatorSection?searchText[plugin_formcreator_forms_id]=<id>&range=0-999
GET /PluginFormcreatorQuestion?searchText[plugin_formcreator_sections_id]=<id>&range=0-999
GET /PluginFormcreatorCondition?range=0-999
GET /PluginFormcreatorTargetTicket?searchText[plugin_formcreator_forms_id]=<id>&range=0-999
GET /PluginFormcreatorFormAnswer?searchText[plugin_formcreator_forms_id]=<id>&range=0-50
GET /Profile?range=0-999
GET /PluginFormcreatorForm_Profile?range=0-999
GET /PluginGenericobjectConservacao?range=0-100
GET /search/PluginGenericobjectConservacao?forcedisplay[0]=1&forcedisplay[1]=2&range=0-100
GET /Rule?sub_type=RuleTicket&range=0-999
GET /RuleAction?searchText[rules_id]=<id>&range=0-999
GET /RuleCriteria?searchText[rules_id]=<id>&range=0-999
GET /ITILCategory?range=0-999
GET /Group?range=0-999
```

### Snapshot local (referência)

```
/home/jonathan/.brain/glpi-governance/2026-06-10-api/sis-snapshot-api-2026-06-10.json
/home/jonathan/.brain/glpi-governance/2026-06-10-api/questions_full.json
/home/jonathan/.brain/glpi-governance/2026-06-10-api/conditions_full.json
/home/jonathan/.brain/glpi-governance/2026-06-10-api/target_actors.json
```

E também o catálogo gerado pelo app:

```
/home/jonathan/projects/work/mobile/sis-mobile-flutter/assets/sis_checklists_catalog.json
```

## O que mapear — ponto a ponto

### 1. Inventário atual dos forms de checklist

Para cada form com "CHECKLIST" no nome ou que contenha targets de manutenção:

| Campo | O que coletar |
|---|---|
| id | ID numérico |
| name | Nome completo |
| is_active | Ativo? |
| is_visible | Visível no helpdesk? |
| helpdesk_home | Na home do helpdesk? |
| profile_ids | Quais perfis enxergam (formcreator_forms_profiles) |
| section_count | Quantas seções |
| question_count | Quantas perguntas no total |
| required_count | Quantas obrigatórias |
| target_count | Quantos targets |
| last_modification | Data de última modificação se disponível |

Verificar se existem forms além de 48-52 com checklists ativos. O snapshot
registra forms 41-52 com conteúdo de checklist, mas apenas 48-52 como ativos.
Confirmar se os forms 41-47 estão realmente inativos ou foram removidos.

### 2. Seções de cada form ativo

Para cada form em {48, 49, 50, 51, 52}:

- Listar todas as seções com id, nome, order.
- Registrar quais seções têm `show_rule != 1` (condicionais).
- Identificar a seção "Dados Gerais" (presente em todos) vs seções específicas
  por localização/área (condicionais).

Comparar com o snapshot: seção nova? seção removida? nome alterado?

### 3. Perguntas de cada form — análise profunda

Para cada form, coletar (se ainda não estiver no snapshot ou houver dúvida):

- Total de perguntas por fieldtype (select, radios, multiselect, textarea,
  file, glpiselect, text, checkboxes, etc.).
- Perguntas do tipo `glpiselect`: qual `itemtype` referenciam? Mapear todos
  os itemtypes distintos encontrados.
- Perguntas com `required=1`: listar ids e nomes.
- Perguntas com `show_rule != 1` (condicionais): quantas, em que seção.
- Para perguntas do tipo select/radios/multiselect: confirmar que `values`
  está populado e registrar as opções (exemplo de cada form).

Especialmente para o form 52 (Iluminação, 819 perguntas, 684 obrigatórias):
confirmar se as 684 obrigatórias são mesmo obrigatórias ou se são
condicionalmente obrigatórias (campo `required` + condições de visibilidade).

### 4. Targets de cada form

Para cada target nos 17 ativos (316, 325, 326, 337, 341, 342, 343, 344,
350, 359, 362, 363, 364, 365, 366, 367, 368):

- id, name, form_id
- destination_entity_value (esperado: 58 para todos)
- category_rule e category_question (esperado: rule=2, question=148-152)
- Atores FormCreator (`PluginFormcreatorTarget_Actor` ou similar):
  - tipo (grupo, usuário, validador, etc.)
  - role (requester, assigned, observer, validator)
  - id do grupo
- show_rule e condições de visibilidade do target

Comparar com `target_actors.json` do snapshot.

### 5. PluginGenericobjectConservacao — mapeamento completo

Este itemtype aparece em perguntas `glpiselect` nos forms de checklist.
Hermes deve mapear:

- Campos/atributos disponíveis (via `GET /PluginGenericobjectConservacao?range=0-1`).
- Volume de registros ativos (via `GET /search/PluginGenericobjectConservacao`).
- Campos de busca disponíveis (searchoptions): nome, id, tipo, localização.
- Como a pergunta `glpiselect` usa esse itemtype no contexto de cada form:
  qual pergunta, qual label, se é required.
- Exemplos de registros (5-10) para entender o que o campo representa
  operacionalmente (equipamento, item de conservação, localização).
- Verificar se há outros GenericObjects além de `Conservacao` referenciados
  nos forms 48-52.

### 6. Perfis e visibilidade

Confirmar `formcreator_forms_profiles` para os forms 48-52:

- Quais profiles_id têm acesso a cada form?
- O perfil `Manutencao e Conservacao` (profiles_id=11, conforme o snapshot)
  tem acesso? O snapshot atual indica que NÃO, apenas `Super-Admin` (id=4).
  Confirmar se isso mudou.
- Existe algum perfil dedicado de "operador de checklist" que não aparece no
  snapshot?

Para cada perfil encontrado:
- id, name, interface (central/helpdesk)

### 7. RuleTickets que afetam checklists

O snapshot 2026-06-10 registra 4 RuleTickets principais:

| ID | Critério | Ação |
|---|---|---|
| 156 | categoria contém "Manutenção" | _groups_id_assign=22 |
| 155 | categoria contém "Conservação" | _groups_id_assign=21 |
| 149 | status novo + categoria "Manutenção" | append task_templates 1,3,2 |
| 157 | entidade=58 | _groups_id_observer=49 |

Verificar:
- Essas regras ainda existem e estão ativas?
- Alguma regra nova foi adicionada que afeta categorias 148-152?
- As categorias usadas nos critérios correspondem às mesmas categorias dos
  targets (148=Manutenção X, 149=Manutenção Y, 150=Conservação X, etc.)?
- Os grupos 21, 22, 49 ainda existem com os mesmos nomes?
- Os task templates 1, 2, 3 ainda existem? Quais são seus nomes?

### 8. Observação do formulário web (comportamento ao vivo)

Navegar o FormCreator SIS como usuário com acesso:

Para pelo menos 2 forms (recomendado: form 49 Calhas e Pluviais por ser menor,
e form 52 Iluminação por ser o maior):

- Acessar o formulário via helpdesk (portal SIS).
- Registrar quantas seções aparecem inicialmente.
- Selecionar diferentes opções de `Local` ou equivalente e observar quais
  seções/perguntas aparecem (condições sendo disparadas).
- Registrar o fluxo: quantas páginas/steps tem o form, tem paginação?
- Identificar a pergunta de "Checklist" (CORRETIVA/PREVENTIVA) e "Checklist
  Programada" (referência a ticket existente).
- NÃO submeter. Parar antes de qualquer botão de envio.

### 9. FormAnswers existentes (histórico de submissões)

Via API:

```
GET /PluginFormcreatorFormAnswer?searchText[plugin_formcreator_forms_id]=48&range=0-10
```

Para os forms 48-52:
- Existem respostas (FormAnswers) históricas? Quantas?
- Se existirem, capturar estrutura de uma resposta (sem dados pessoais):
  - quais campos foram preenchidos?
  - qual ticket foi criado (`generated_target`)?
  - qual categoria e entidade o ticket recebeu?

Isso confirma que o fluxo FormCreator real funciona (ou não) e qual é a forma
exata do ticket criado.

## Formato de saída esperado

### Arquivo principal de descoberta

Criar ou atualizar:

```
/home/jonathan/.brain/glpi-governance/checklists-discovery-2026-06-21.md
```

Estrutura:

```markdown
# Descoberta Checklists SIS — 2026-06-21

## Sumário executivo
[3-5 linhas: o que mudou desde 2026-06-10, o que foi confirmado, o que foi descoberto de novo]

## Forms ativos (confirmação)
[Tabela: id, nome, perfis, seções, perguntas, targets]

## Alterações vs snapshot 2026-06-10
[Lista de divergências encontradas: novo, removido, modificado]

## PluginGenericobjectConservacao
[Campos, volume, exemplos de registros, como aparece nos forms]

## Perfis e gate de visibilidade
[Confirmação ou correção do gate atual]

## RuleTickets — estado atual
[Tabela de regras confirmadas, alteradas ou novas]

## FormAnswers históricos
[Se existirem: estrutura de uma resposta, ticket criado, categoria, entidade]

## Comportamento web observado
[Navegação nos forms 49 e 52: seções, condições, fluxo]

## Lacunas remanescentes
[O que ainda não foi possível verificar e por quê]

## Impacto no app Flutter
[O que o app precisa ajustar com base na descoberta — sem implementar aqui]
```

### Arquivos de dados brutos (se relevante)

Se houver dados estruturados novos (ex: lista de registros de
`PluginGenericobjectConservacao`, lista de fields não mapeados):

```
/home/jonathan/.brain/glpi-governance/conservacao-objects-sample-2026-06-21.json
/home/jonathan/.brain/glpi-governance/checklist-form-answers-sample-2026-06-21.json
```

### Atualização do doc de conhecimento do repo

Após a descoberta, atualizar:

```
/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/CHECKLISTS_SIS_CONHECIMENTO.md
```

Adicionar uma seção "Verificação ao vivo — 2026-06-21" com:
- Resultado da confirmação de cada lacuna listada em "Perguntas remanescentes".
- Divergências do snapshot.
- Recomendações para o app (perfil correto, ajuste de catalog, etc.).

## Regras desta missão

- **Read-only absoluto.** Nenhum POST, PUT ou DELETE. Só GET.
- **Sem dados pessoais.** Ao capturar FormAnswers, omitir nomes, emails ou
  identificadores de usuários reais. Registrar apenas a estrutura e IDs.
- **Parar antes de submeter.** Ao navegar formulários web, não clicar em
  Enviar, Salvar, Confirmar ou equivalente.
- **Não alterar nenhuma configuração.** Não modificar perfis, regras,
  formulários, atores, entidades ou qualquer item do GLPI.
- **Documentar lacunas.** Se algum dado não for acessível com a conta de
  teste (permissão negada), registrar o que não foi possível verificar e
  por quê — não tentar escalar permissão.

## Checkpoint final

Ao terminar, responder a estas perguntas no doc de descoberta:

1. Forms 48-52 ainda estão ativos e sem alterações relevantes desde 2026-06-10?
2. O perfil `Super-Admin` (id=4) é realmente o único que enxerga os forms?
   Existe perfil operacional dedicado?
3. `PluginGenericobjectConservacao`: quantos registros existem? O campo é
   pesquisável por nome?
4. Os 17 targets mapeados ainda existem com o mesmo entity=58 e category_id?
5. As 4 RuleTickets (149, 155, 156, 157) ainda existem e estão ativas?
6. Existem FormAnswers históricos que provam que o fluxo funciona ao vivo?
7. O form 52 (Iluminação, 684 obrigatórias) é realmente navegável ou é
   complexo demais para uso prático? (Observação web.)

> Documento criado em 2026-06-21. Contexto: app Flutter SIS implementou
> render/preview read-only dos checklists. Esta missão valida o mapa atual
> antes de habilitar a submissão real (Fase 9 do plano end-to-end).
