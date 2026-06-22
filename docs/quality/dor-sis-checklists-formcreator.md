# DoR - SIS Checklists FormCreator

## 1. Tipo

- [x] Feature
- [ ] Correcao de bug
- [x] Evolucao de fluxo existente
- [x] Ajuste operacional/runtime

## 2. Fato ou objetivo

Implementar fluxo especializado de checklist SIS para forms 48-52 sem expor mutacao GLPI real antes de perfil, Worker e sandbox estarem confirmados.

## 3. Entidades envolvidas

- Primaria: GLPI Ticket criado via FormCreator
- Secundarias: PluginFormcreatorForm, PluginFormcreatorQuestion, PluginFormcreatorCondition, PluginFormcreatorTargetTicket, Document, Document_Item, RuleTicket, Group_Ticket

## 4. Estados tocados

- Le: catalogo FormCreator, perguntas, condicoes, perfis, categorias, grupos e read-back de ticket
- Altera: apenas depois do gate de submissao, cria FormAnswer/Ticket em ambiente autorizado
- Estados invalidos que precisam ser bloqueados: usuario sem perfil operacional, Worker sem allowlist, app flag off, campos obrigatorios ausentes, target ambiguo, ticket real nao sintetico

## 5. Papeis envolvidos

- Quem dispara: perfil que o GLPI atribui ao form (hoje somente Super-Admin, profiles_id 4, por `formcreator_forms_profiles`)
- Quem e afetado: equipes de manutencao/conservacao e usuarios observadores configurados pelo GLPI
- Existe caso tecnico-solicitante? Sim, deve ser separado de Solicitante comum
- Existe sessao expirada ou usuario sem permissao? Sim, deve bloquear antes de submissao

## 6. Fonte de verdade

- Origem remota: GLPI SIS FormCreator e RuleTicket
- Origem local: catalogo Worker gerado do snapshot 2026-06-10
- Quando reidrata: login, troca de perfil, refresh manual do catalogo e retorno ao app
- Quem vence em divergencia: GLPI/Worker; cache local e apenas fallback read-only

## 7. Invariantes aplicaveis

- Nao mutar ticket real de usuario sem aprovacao humana explicita.
- Nao usar POST /Ticket nativo para simular FormCreator de checklist.
- Nao permitir checklist para perfil que o GLPI nao atribui ao form (gate derivado de `formcreator_forms_profiles`, sem nomes hardcoded).
- Nao enviar grupo/tecnico direto por perfil sem permissao.

## 8. Cenarios de borda obrigatorios

1. Perfil sem atribuicao no GLPI tenta abrir checklist.
2. Campo obrigatorio condicional aparece depois de resposta e bloqueia revisao.
3. Worker sem ALLOW_FORMCREATOR_SUBMISSION recebe tentativa de envio.
4. FormCreator cria ticket mas read-back nao confirma grupo/task template.
5. Usuario perde sessao antes do envio.

## 9. Fora de escopo

- Redesenhar o catalogo SIS inteiro.
- Separar fisicamente SIS e DTIC.
- Liberar submissao contra tickets reais de usuarios.

## 10. Validacao planejada

- Teste unitario: parser, condicoes, validacao, payload, flags
- Teste Widgetbook/visual: entrada de catalogo e formulario checklist
- Teste Android/emulador: smoke read-only antes de mutacao
- Teste API/GLPI: somente sandbox/ticket sintetico, com aprovacao
- Evidencia manual: README de execucao com hashes, screenshots e ticket sintetico

## 11. Criterio de pronto preliminar

Checklist fica visivel somente para perfil que o GLPI atribui ao form, renderiza e valida forms 48-52 em modo read-only, e submissao so cria ticket FormCreator em ambiente autorizado com read-back consistente.
