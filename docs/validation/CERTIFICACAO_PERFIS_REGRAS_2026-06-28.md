# Certificação de Perfis, Grupos e Regras vs Fonte da Verdade

Matriz mestre + metodologia. Objetivo: certificar, de forma **completa e
repetível**, que cada papel × cada superfície × cada família de regra do app SIS
Mobile bate com a **fonte da verdade** (GLPI vivo). Re-certificação total após
`changeActiveProfile`, Múltiplas Demandas agregado, fix de árvore e card limpo.

Relatório de resultados (PASS/FAIL por célula): `RELATORIO_CERTIFICACAO_2026-06-28.md`.

## Metodologia: 3 camadas, 2 pontes

| Camada | O que é | Como ler |
|---|---|---|
| **1. GLPI vivo (verdade)** | rights bitmask, visibilidade, estrutura FormCreator, árvore ITILCategory, resultado real de PUT/POST | `getFullSession`, `search/Ticket`, `PluginFormcreator*`, `ITILCategory` |
| **2. Contrato/catálogo** | snapshot pré-resolvido que o app consome | `assets/glpi_rules_sis.json`, `metadata_catalog.js`, `assets/sis_checklists_catalog.json` |
| **3. App** | o que cada perfil vê/pode em cada tela | telas + estado |

- **Ponte A (2 == 1):** o snapshot está fresco/correto? Falha = *staleness*.
- **Ponte B (3 == 2):** o app consome fielmente? Falha = a classe de bug recorrente.
- Toda célula valida a(s) ponte(s) relevante(s). Confundir camadas foi a raiz dos bugs.

## Papéis (conta 2373, simulados via changeActiveProfile)

| Papel | Perfil ativo | Grupo contexto | rights ticket | Resumo |
|---|---|---|---|---|
| R1 Solicitante | 9 | — | 5 | OWN_ONLY; cria, não muda status |
| R2 CC-Conservação | 11 | 21 | 260102 | técnico; muda status, soluciona |
| R3 CC-Manutenção | 11 | 22 | 260102 | técnico (idêntico a R2; difere domínio) |
| R4 GG-Conservação | 12 | 49 | 145411 | UPDATE sem CREATE; observador/validador |

⚠️ A conta está em 21 **e** 22 → como perfil 11, o papel operacional
(`OperationalRoleResolver`, `lib/models/operational_role.dart`) precisa ser
validado quanto à resolução com grupo ambíguo.

## Famílias de regra → fonte da verdade (Camada 1) → contrato (Camada 2)

| F | Família | Fonte da verdade (Camada 1) | Contrato (Camada 2) | App (Camada 3) |
|---|---|---|---|---|
| F1 | Direitos (bitmask) | `getFullSession.glpiactiveprofile['ticket']` | `glpi_rules_sis.json` | botões/ações habilitados |
| F2 | Visibilidade (scope) | `search/Ticket?...&totalcount` por perfil | `visibility` | lista Meus Chamados / fila |
| F3 | Catálogo/serviços | `PluginFormcreatorForm_Profile`/`Form_Group` | `metadata_catalog.js` `profile_visibility` | cards do Home |
| F4 | Forms + árvore | `PluginFormcreatorQuestion.values`, `ITILCategory` | `options_sample`+`selectable_tree_root` | dropdowns de tipo (só folhas) |
| F5 | Checklists | forms 48–52 vivo + conditions | `sis_checklists_catalog.json` | visibilidade/condições no app |
| F6 | Transições de status | resultado de `PUT /Ticket` por perfil | `status.transitions_by_profile` | botões + mutação |
| F7 | Actor fields | `search/Ticket` SearchOptions [4,22,66] | `search_options` | "Meus Chamados" |
| F8 | Entidade | entidades da sessão / destino | `_meta`/destino | contexto + destino submissão |
| F9 | Troca de perfil | `getMyProfiles`+`changeActiveProfile` | — | switcher + efeito em visibilidade/direitos |

## Matriz de validação (papel × superfície × família)

Legenda método: **A**=automatizado (harness Dart) · **V**=visual (browser) ·
mutação: **RO**=read-only · **MUT**=ticket marcado+cleanup.

### F1 Direitos × papel — `getFullSession`
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R1 | ticket=5 (READ+CREATE) | bitmask==5; app NÃO mostra ação de status | A+V | RO |
| R2/R3 | ticket=260102 (UPDATE) | bitmask==260102; app mostra ações técnicas | A+V | RO |
| R4 | ticket=145411 (UPDATE sem CREATE) | bitmask==145411; app bloqueia "abrir chamado", mostra status | A+V | RO |

### F2 Visibilidade × papel — `search/Ticket totalcount`
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R1 | OWN_ONLY | só tickets do próprio requerente; count menor | A | RO |
| R2/R3 | GROUP_OR_ASSIGNED | inclui do grupo/atribuídos; count maior | A | RO |
| R4 | GROUP_OR_ASSIGNED (GG) | inclui fila GG; count intermediário | A | RO |
| todos | ordenação | 9 < 12 < 11 | A | RO |

### F3 Catálogo × papel — Home Serviços
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R1 | vê forms de Solicitante | cards == forms com Form_Profile 9 (Ponte A) e app mostra (Ponte B) | A+V | RO |
| R4 | vê forms GG (4 forms + checklists) | cards == `profile_visibility` contendo 12 | A+V | RO |
| R2/R3 | catálogo técnico | conforme Form_Profile 11 | A+V | RO |

### F4 Forms+árvore × papel — Form single + agregado
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R1/R4 | tipo-árvore só folhas | Ar-Condicionado → 6 folhas, sem nó-pai (reusa `governed_question_tree_test`) | A+V | RO |
| R1/R4 | tipo-lista literal | Elevadores → Iluminação/Parado/… | A+V | RO |
| R4 | Múltiplas Demandas | multi-serviço + seções; cada serviço resolve tipo certo | V | RO |

### F5 Checklists × papel
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R4 | checklists GG visíveis | forms 48–52 conforme profile/group (OR); condições corretas | A+V | RO |
| R1 | sem checklists técnicos | não vê forms restritos a grupo técnico | V | RO |

### F6 Transições × papel — Detalhe/Conversa (MUTAÇÃO)
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R1 | sem UPDATE de status | `PUT` status = 400; app não oferece | A+V | MUT |
| R2/R3 | transições técnicas | `PUT` status OK; propor solução → Solucionado | A+V | MUT |
| R4 | muda status sem criar/solucionar | `PUT` status OK; `POST /Ticket`=400; solução=400; validar add_close OK | A+V | MUT |
| todos | Fechado terminal (I-1) | nenhuma ação muta ticket Fechado | A+V | MUT |

### F7 Actor fields × papel — Meus Chamados
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| todos | [4,22,66] requester/author/observer | lista "Meus Chamados" == search por SearchOptions; fallback de protocolo | A+V | RO |

### F8 Entidade × papel — submissão
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| R1/R4 | destino por entidade | entidade ativa coerente; destino do ticket conforme RuleTickets (server-side) | A+V | MUT (na Fase 2) |

### F9 Troca de perfil — switcher (NOVO)
| Papel | Regra | PASS se | Método | Mut |
|---|---|---|---|---|
| — | `changeActiveProfile` muda sessão | após trocar, getFullSession reflete novo perfil; tickets visíveis e direitos mudam | A+V | RO |
| — | UI do switcher | app lista perfis (getMyProfiles) e troca o ativo | V | RO |

## Política de mutação (Fase 2)

Só conta 2373, só tickets que ela criou, prefixo
`[TESTE-AUTOMATIZADO SIS] [CERTIFICACAO-2026-06-28]`, cleanup (fechar/cancelar) +
registro de IDs. GG (perfil 12) não cria → criar sob perfil 9, depois trocar para
agir. Nunca tocar ticket de usuário real; nunca `DELETE`.

## Staleness conhecida (Ponte A) a confirmar/registrar
- Elevadores (form 40 target-220): categoria sem opções no catálogo (tipo real é lista `select` na questão).
- Target 369 "HIDRÁULICO 951" existia ao vivo e faltava no catálogo (auditoria 2026-06-27).
- Forms "Multiplas Demandas" duplicados ao vivo (37 e 40; app usa 40).

## Estado de execução
- **Fase 0 PASS** — F1 (bitmask 5/260102/145411 idêntico) + F2 (ordenação 9<12<11). Evidência: `output/playwright/certificacao-2026-06-28/FASE0_PREFLIGHT.md`.
- Fases 1–3: pendentes.
