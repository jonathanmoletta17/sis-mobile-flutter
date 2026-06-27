# Runbook - Submissão sintética de checklist SIS (sandbox)

> **Gate manual. Não automatizado.** Esta é a única etapa mutável do projeto de
> checklists. Exige aprovação humana explícita e ambiente autorizado. Nada aqui
> roda sem decisão consciente de um operador humano. Ver `CLAUDE.md`.

## Pré-condições obrigatórias

1. Aprovação humana registrada para o teste mutável.
2. Ambiente alvo confirmado (homologação/sandbox ou ticket sintético em produção
   sob as regras de conta de teste do `CLAUDE.md`).
3. Conta de teste dedicada (QA/bot) — nunca usuário real, nunca a sessão de
   serviço elevada do Worker.
4. Perfil ativo da conta de teste = um perfil que o GLPI atribui ao form
   (hoje `Super-Admin`/`profiles_id=4`, conforme `formcreator_forms_profiles`).
5. Flags ligadas **somente durante o teste**:
   - app: `SIS_ENABLE_CHECKLISTS_SUBMISSION=true`
   - Worker: `ALLOW_FORMCREATOR_SUBMISSION=true`
6. Alvo de checklist sintético: um dos 18 targets ativos (forms 48-52).
7. Submissão **sem anexo** primeiro (o caminho com `file` permanece bloqueado no
   app até o contrato de arquivo ser validado).

## O que o GLPI faz na submissão (fidelidade — verificado no snapshot)

A submissão cria um Ticket via `PluginFormcreatorFormAnswer`. O comportamento
esperado, derivado das regras reais do GLPI SIS, é:

- categoria final do ticket = `category_question` do target (148-152);
- entidade destino = 58 (`destination_entity_value`);
- atores FormCreator do target: `observer:validator`, `assigned:group:22`
  (ou `21` em um target de iluminação), e `requester`/`observer` de grupo 49
  conforme o target;
- RuleTicket disparadas após a criação:
  - **156**: categoria contém "Manutenção" → `_groups_id_assign=22`;
  - **155**: categoria contém "Conservação" → `_groups_id_assign=21`;
  - **149**: status novo + categoria contém "Manutenção" → append task_template
    1 (EQUIPE EXECUTORA), 3 (MATERIAIS UTILIZADOS), 2 (SERVIÇO REALIZADO);
  - **157**: entidade 58 → `_groups_id_observer=49`.

## Read-back esperado (validar após criar)

- ticket id criado;
- entidade = 58;
- categoria ∈ {148,149,150,151,152};
- grupo de atribuição coerente com a RuleTicket (22, ou 21 quando aplicável);
- observadores/requester de grupo conforme target/regra;
- task templates presentes (ou documentado como não legível pelo perfil).

## Critério de parada

- 1 (uma) submissão sintética bem-sucedida com read-back consistente; ou
- primeira divergência de read-back não explicada → parar e registrar.

## Cleanup e auditoria

- Encerrar/cancelar o ticket sintético criado.
- Registrar: ticket id, ambiente, timestamp, resultado do read-back, responsável.
- **Desligar as duas flags imediatamente após o teste**
  (`SIS_ENABLE_CHECKLISTS_SUBMISSION=false`, `ALLOW_FORMCREATOR_SUBMISSION=false`).

## Proibições absolutas

- `DELETE /Ticket` e qualquer purge.
- Mutação em ticket cujo requerente não seja a conta de teste.
- Submissão com anexo antes de validar o contrato de arquivo.
- Uso da sessão de serviço elevada do Worker para mutação.

> Sem credenciais, tokens ou segredos neste documento.
