export const MOBILE_METADATA_CATALOG = {
  "schema_version": "2.0-readonly-draft",
  "consumer_id": "sis-mobile-flutter",
  "instance": "sis",
  "generated_at": "2026-06-03T05:33:58.758442+00:00",
  "source_snapshot": {
    "path": "/home/jonathan/.brain/glpi-governance/2026-05-29-full-map/sis-snapshot-2026-05-29.json",
    "snapshot_hash": "fbd252e50e23660e8bdd9d86aa99dba7b08808eab52b4640d6ed7ac159a2d269",
    "sha256": "33881ae7ba9e63520d1856d90921b34c1c635a85a785dbdf80a041a0b03f22bc"
  },
  "source_counts": {
    "formcreator_forms": 41,
    "formcreator_forms_profiles": 44,
    "formcreator_questions": 3004,
    "formcreator_conditions": 6582,
    "formcreator_targettickets": 159,
    "rule_ticket_criteria": 25,
    "rule_ticket_actions": 26,
    "categories": 149,
    "locations": 422,
    "entities": 86
  },
  "governance_rules": {
    "assignment": [
      {
        "rule_id": 155,
        "criteria": "itilcategories_id contains Conservação",
        "action": "assign CC-CONSERVACÃO",
        "group_id": 21
      },
      {
        "rule_id": 156,
        "criteria": "itilcategories_id contains Manutenção",
        "action": "assign CC-MANUTENCAO",
        "group_id": 22
      }
    ],
    "task_templates": [
      {
        "rule_id": 149,
        "criteria": "status novo + itilcategories_id contains Manutenção",
        "append_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ]
      },
      {
        "rule_ids": [
          158,
          159,
          160,
          161,
          162,
          163,
          164,
          165,
          166,
          167,
          168,
          169,
          170,
          171,
          172,
          173,
          174,
          175,
          176,
          177
        ],
        "criteria": "locations_id contains mapped location patterns",
        "append_task_templates": "map/location templates 6-21"
      }
    ]
  },
  "known_enum_semantics": {
    "destination_entity": {
      "1": "fixed_or_direct; validate per target",
      "2": "Solicitante para mim / requester context",
      "7": "Manutenção e Conservação para mim / operational context",
      "8": "para terceiro / beneficiary question"
    },
    "category_rule": {
      "3": "from category question; normal service path",
      "1": "fixed/default",
      "2": "atypical/legacy; validate before use"
    },
    "location_rule": {
      "3": "from location question; normal service path",
      "2": "atypical/legacy; validate before use"
    },
    "type_rule": {
      "1": "fixed type in this snapshot"
    },
    "urgency_rule": {
      "3": "from question",
      "1": "fixed/default"
    }
  },
  "warnings": [
    {
      "record": "sis:checklist-calhas-e-pluviais:form-49:target-337",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-calhas-e-pluviais:form-49:target-337",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-341",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-341",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-342",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-342",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-343",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-343",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-344",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-344",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-350",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-hidraulico:form-50:target-350",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-362",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-362",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-363",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-363",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-364",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-364",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-365",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-365",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-366",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-366",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-367",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-367",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-368",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-iluminacao:form-52:target-368",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-pedras-portuguesas:form-51:target-359",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-pedras-portuguesas:form-51:target-359",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-refrigeracao:form-48:target-316",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-refrigeracao:form-48:target-316",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-refrigeracao:form-48:target-325",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-refrigeracao:form-48:target-325",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:checklist-refrigeracao:form-48:target-326",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:checklist-refrigeracao:form-48:target-326",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:diversos:form-18:target-40",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:diversos:form-18:target-43",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:diversos:form-18:target-44",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:elevadores:form-2:target-2",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:elevadores:form-2:target-2",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:elevadores:form-2:target-21",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:elevadores:form-2:target-21",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:elevadores:form-25:target-137",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:elevadores:form-25:target-137",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:elevadores:form-25:target-138",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:elevadores:form-25:target-138",
      "warning": "location_rule atypical; require live validation",
      "location_rule": 2
    },
    {
      "record": "sis:manutencao:form-39:target-203",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:multiplas-demandas:form-40:target-218",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:multiplas-demandas:form-40:target-220",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    },
    {
      "record": "sis:projeto:form-36:target-246",
      "warning": "category_rule not normal/fixed; require live validation",
      "category_rule": 2
    }
  ],
  "validation_evidence": [
    {
      "ticket_id": 9412,
      "source": "mcp_glpi_search_tickets + get_ticket(include_tasks=True)",
      "requesttype": "Formcreator",
      "category": "Manutenção > Marcenaria > Conserto de Mobiliário",
      "entity": "Origem > PIRATINI > CASA CIVIL > Secretaria-Executiva > Subchefia Juridica > Departamento de Informações Especiais",
      "group": "CC-MANUTENCAO",
      "location": "Locais > Casa Civil 1005 > Subsolo 1",
      "task_templates_observed": [
        "EQUIPE EXECUTORA",
        "MATERIAIS UTILIZADOS",
        "SERVIÇO REALIZADO",
        "Mapa Casa Civil 1005- Subsolo 01"
      ],
      "notes": "FormCreator Manutenção com categoria governada e task de mapa por localização."
    },
    {
      "ticket_id": 9416,
      "source": "mcp_glpi_search_tickets + get_ticket(include_tasks=True)",
      "requesttype": "Formcreator",
      "category": "Manutenção > Elétrica > Troca",
      "entity": "Origem > PIRATINI > GG > Secretaria Executiva de Gestão do Palácio Piratini > Departamento de Conservação e Memória do Patrimônio Cultural do Complexo do Palácio Piratini",
      "group": "CC-MANUTENCAO",
      "location": "Locais > Palacio Piratini -Ala Residencial > 1° Pavimento > ARS106",
      "task_templates_observed": [
        "EQUIPE EXECUTORA",
        "MATERIAIS UTILIZADOS",
        "SERVIÇO REALIZADO"
      ],
      "notes": "FormCreator Manutenção com anexo textual \"Documento anexado\" no conteúdo; anexos reais exigem Document/Document_Item."
    },
    {
      "ticket_id": 9400,
      "source": "mcp_glpi_search_tickets + get_ticket(include_tasks=True)",
      "requesttype": "Formcreator",
      "category": "Conservação > Limpeza > Limpeza geral",
      "entity": "Origem > PIRATINI > CASA CIVIL > Secretaria-Executiva > Subchefia Administrativa > Divisão de Protocolo e Gerenciamento de Arquivo",
      "group": "CC-CONSERVACÃO",
      "location": "Limpeza > Casa Civil 1005 > Subsolo",
      "task_templates_observed": [],
      "notes": "FormCreator Conservação: grupo aplicado; tasks não retornadas."
    },
    {
      "ticket_id": 9407,
      "source": "mcp_glpi_search_tickets + get_ticket(include_tasks=True)",
      "requesttype": "Helpdesk/app atual",
      "category": "Conservação > Limpeza",
      "entity": "Origem > PIRATINI",
      "group": "CC-CONSERVACÃO",
      "location": "Limpeza > Palácio Piratini",
      "task_templates_observed": [],
      "notes": "Criado pelo app atual com marcador FORMULARIO DO APP; aceita fila, mas não prova paridade FormCreator."
    },
    {
      "ticket_id": 9422,
      "source": "mcp_glpi_search_tickets + Document_Item by Document.id",
      "requesttype": "synthetic Hermes/app-like",
      "category": "Manutenção > Pintura > Outros",
      "entity": "Origem > PIRATINI",
      "group": "CC-MANUTENCAO",
      "location": null,
      "task_templates_observed": [],
      "document_id": 7024,
      "document_item_id": 9052,
      "notes": "Anexo real comprovado por Document + Document_Item; requester não lê Document_Item por direito."
    }
  ],
  "validations": [
    {
      "check": "non_empty_records",
      "ok": true,
      "value": 133
    },
    {
      "check": "all_records_have_profile_visibility",
      "ok": true,
      "failures": []
    },
    {
      "check": "normal_services_have_category_question",
      "ok": true,
      "failures": []
    },
    {
      "check": "normal_services_have_location_question",
      "ok": true,
      "failures": []
    },
    {
      "check": "ticket_9412_category_group",
      "ok": true,
      "expected_group": "CC-MANUTENCAO",
      "actual_group": "CC-MANUTENCAO",
      "category": "Manutenção > Marcenaria > Conserto de Mobiliário"
    },
    {
      "check": "ticket_9416_category_group",
      "ok": true,
      "expected_group": "CC-MANUTENCAO",
      "actual_group": "CC-MANUTENCAO",
      "category": "Manutenção > Elétrica > Troca"
    },
    {
      "check": "ticket_9400_category_group",
      "ok": true,
      "expected_group": "CC-CONSERVACÃO",
      "actual_group": "CC-CONSERVACÃO",
      "category": "Conservação > Limpeza > Limpeza geral"
    },
    {
      "check": "ticket_9407_category_group",
      "ok": true,
      "expected_group": "CC-CONSERVACÃO",
      "actual_group": "CC-CONSERVACÃO",
      "category": "Conservação > Limpeza"
    },
    {
      "check": "ticket_9422_category_group",
      "ok": true,
      "expected_group": "CC-MANUTENCAO",
      "actual_group": "CC-MANUTENCAO",
      "category": "Manutenção > Pintura > Outros"
    }
  ],
  "validation_ok": true,
  "records": [
    {
      "catalog_record_id": "sis:ar-condicionado:form-1:target-1",
      "service_id": "ar-condicionado",
      "service_label": "Ar-Condicionado",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 1,
        "name": "Ar-Condicionado",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          1,
          21
        ]
      },
      "targetticket": {
        "id": 1,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 7,
        "location_rule": 3,
        "location_question_id": 3,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 7,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 3,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:ar-condicionado:form-1:target-17",
      "service_id": "ar-condicionado",
      "service_label": "Ar-Condicionado",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 1,
        "name": "Ar-Condicionado",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          1,
          21
        ]
      },
      "targetticket": {
        "id": 17,
        "name": "Ar Condicionado para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 2,
        "category_rule": 3,
        "category_question_id": 7,
        "location_rule": 3,
        "location_question_id": 3,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 7,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 3,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:ar-condicionado:form-21:target-129",
      "service_id": "ar-condicionado",
      "service_label": "Ar-Condicionado",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 21,
        "name": "Ar-Condicionado",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          1,
          21
        ]
      },
      "targetticket": {
        "id": 129,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 375,
        "location_rule": 3,
        "location_question_id": 372,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 375,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 372,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:ar-condicionado:form-21:target-130",
      "service_id": "ar-condicionado",
      "service_label": "Ar-Condicionado",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 21,
        "name": "Ar-Condicionado",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          1,
          21
        ]
      },
      "targetticket": {
        "id": 130,
        "name": "Ar Condicionado para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 371,
        "category_rule": 3,
        "category_question_id": 375,
        "location_rule": 3,
        "location_question_id": 372,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 375,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 372,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-calhas-e-pluviais:form-49:target-337",
      "service_id": "checklist-calhas-e-pluviais",
      "service_label": "CHECKLIST CALHAS E PLUVIAIS",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 49,
        "name": "CHECKLIST CALHAS E PLUVIAIS",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          49
        ]
      },
      "targetticket": {
        "id": 337,
        "name": "CHECKLIST CALHAS E PLUVIAIS",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 149,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 1
      },
      "questions": {
        "category": null,
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-hidraulico:form-50:target-341",
      "service_id": "checklist-hidraulico",
      "service_label": "CHECKLIST HIDRÁULICO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 50,
        "name": "CHECKLIST HIDRÁULICO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          50
        ]
      },
      "targetticket": {
        "id": 341,
        "name": "HIDRÁULICO ALA RESIDÊNCIAL",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 151,
        "location_rule": 2,
        "location_question_id": 74,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": null
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-hidraulico:form-50:target-342",
      "service_id": "checklist-hidraulico",
      "service_label": "CHECKLIST HIDRÁULICO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 50,
        "name": "CHECKLIST HIDRÁULICO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          50
        ]
      },
      "targetticket": {
        "id": 342,
        "name": "HIDRÁULICO ALA GOVERNAMENTAL",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 151,
        "location_rule": 2,
        "location_question_id": 73,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 73,
          "name": "Urgência",
          "fieldtype": "urgency",
          "required": false,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-hidraulico:form-50:target-343",
      "service_id": "checklist-hidraulico",
      "service_label": "CHECKLIST HIDRÁULICO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 50,
        "name": "CHECKLIST HIDRÁULICO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          50
        ]
      },
      "targetticket": {
        "id": 343,
        "name": "HIDRÁULICO GALPÃO",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 151,
        "location_rule": 2,
        "location_question_id": 73,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 73,
          "name": "Urgência",
          "fieldtype": "urgency",
          "required": false,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-hidraulico:form-50:target-344",
      "service_id": "checklist-hidraulico",
      "service_label": "CHECKLIST HIDRÁULICO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 50,
        "name": "CHECKLIST HIDRÁULICO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          50
        ]
      },
      "targetticket": {
        "id": 344,
        "name": "HIDRÁULICO GARAGEM",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 151,
        "location_rule": 2,
        "location_question_id": 84,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 84,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-hidraulico:form-50:target-350",
      "service_id": "checklist-hidraulico",
      "service_label": "CHECKLIST HIDRÁULICO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 50,
        "name": "CHECKLIST HIDRÁULICO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          50
        ]
      },
      "targetticket": {
        "id": 350,
        "name": "HIDRÁULICO Casa Civil 1005",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 151,
        "location_rule": 2,
        "location_question_id": 71,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 71,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-362",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 362,
        "name": "ILUMINAÇÂO ALA RESIDENCIAL 3º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 330,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": null
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-363",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 363,
        "name": "ILUMINAÇÂO ALA GOVERNAMENTAL - 1º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 144,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 144,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-364",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 364,
        "name": "ILUMINAÇÂO ALA RESIDENCIAL - 2º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 328,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": null
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-365",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 365,
        "name": "ILUMINAÇÂO ALA RESIDENCIAL 1º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 329,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": null
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-366",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 366,
        "name": "ILUMINAÇÂO ALA GOVERNAMENTAL - 2º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 80,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 80,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-367",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 367,
        "name": "ILUMINAÇÂO ALA GOVERNAMENTAL - 3º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 146,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 146,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-iluminacao:form-52:target-368",
      "service_id": "checklist-iluminacao",
      "service_label": "CHECKLIST ILUMINAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 52,
        "name": "CHECKLIST ILUMINAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          52
        ]
      },
      "targetticket": {
        "id": 368,
        "name": "ILUMINAÇÂO ALA GOVERNAMENTAL - 4º Pavimento",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 148,
        "location_rule": 2,
        "location_question_id": 161,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": null
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-pedras-portuguesas:form-51:target-359",
      "service_id": "checklist-pedras-portuguesas",
      "service_label": "CHECKLIST PEDRAS PORTUGUESAS\t",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 51,
        "name": "CHECKLIST PEDRAS PORTUGUESAS\t",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          51
        ]
      },
      "targetticket": {
        "id": 359,
        "name": "PEDRAS PORTUGUESAS",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 150,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 1
      },
      "questions": {
        "category": null,
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-refrigeracao:form-48:target-316",
      "service_id": "checklist-refrigeracao",
      "service_label": "CHECKLIST REFRIGERAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 48,
        "name": "CHECKLIST REFRIGERAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          48
        ]
      },
      "targetticket": {
        "id": 316,
        "name": "REFRIGERAÇÃO AR CENTRAL",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 152,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-refrigeracao:form-48:target-325",
      "service_id": "checklist-refrigeracao",
      "service_label": "CHECKLIST REFRIGERAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 48,
        "name": "CHECKLIST REFRIGERAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          48
        ]
      },
      "targetticket": {
        "id": 325,
        "name": "REFRIGERAÇÃO 1005",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 152,
        "location_rule": 2,
        "location_question_id": 37,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 37,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:checklist-refrigeracao:form-48:target-326",
      "service_id": "checklist-refrigeracao",
      "service_label": "CHECKLIST REFRIGERAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        }
      ],
      "form": {
        "id": 48,
        "name": "CHECKLIST REFRIGERAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          48
        ]
      },
      "targetticket": {
        "id": 326,
        "name": "REFRIGERAÇÃO 951",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 152,
        "location_rule": 2,
        "location_question_id": 83,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 83,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:conservacao:form-38:target-197",
      "service_id": "conservacao",
      "service_label": "CONSERVAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 38,
        "name": "CONSERVAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          38
        ]
      },
      "targetticket": {
        "id": 197,
        "name": "Carregadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 613,
        "location_rule": 3,
        "location_question_id": 573,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 613,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 573,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:conservacao:form-38:target-198",
      "service_id": "conservacao",
      "service_label": "CONSERVAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 38,
        "name": "CONSERVAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          38
        ]
      },
      "targetticket": {
        "id": 198,
        "name": "Copa",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 617,
        "location_rule": 3,
        "location_question_id": 573,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 617,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 573,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:conservacao:form-38:target-199",
      "service_id": "conservacao",
      "service_label": "CONSERVAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 38,
        "name": "CONSERVAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          38
        ]
      },
      "targetticket": {
        "id": 199,
        "name": "Jardinagem",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 621,
        "location_rule": 3,
        "location_question_id": 573,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 621,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 573,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:conservacao:form-38:target-200",
      "service_id": "conservacao",
      "service_label": "CONSERVAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 38,
        "name": "CONSERVAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          38
        ]
      },
      "targetticket": {
        "id": 200,
        "name": "Limpeza",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 625,
        "location_rule": 3,
        "location_question_id": 573,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 625,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 573,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:conservacao:form-38:target-201",
      "service_id": "conservacao",
      "service_label": "CONSERVAÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 38,
        "name": "CONSERVAÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          38
        ]
      },
      "targetticket": {
        "id": 201,
        "name": "Mensageria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 629,
        "location_rule": 3,
        "location_question_id": 573,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 629,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 573,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:carregadores:form-3:target-3",
      "service_id": "carregadores",
      "service_label": "Carregadores",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 3,
        "name": "Carregadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          3,
          22
        ]
      },
      "targetticket": {
        "id": 3,
        "name": "Carregadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 24,
        "location_rule": 3,
        "location_question_id": 20,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 24,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 20,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:carregadores:form-3:target-18",
      "service_id": "carregadores",
      "service_label": "Carregadores",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 3,
        "name": "Carregadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          3,
          22
        ]
      },
      "targetticket": {
        "id": 18,
        "name": "Carregadores para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 19,
        "category_rule": 3,
        "category_question_id": 24,
        "location_rule": 3,
        "location_question_id": 20,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 24,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 20,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:carregadores:form-22:target-131",
      "service_id": "carregadores",
      "service_label": "Carregadores",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 22,
        "name": "Carregadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          3,
          22
        ]
      },
      "targetticket": {
        "id": 131,
        "name": "Carregadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 384,
        "location_rule": 3,
        "location_question_id": 381,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 384,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 381,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:carregadores:form-22:target-132",
      "service_id": "carregadores",
      "service_label": "Carregadores",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 22,
        "name": "Carregadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          3,
          22
        ]
      },
      "targetticket": {
        "id": 132,
        "name": "Carregadores para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 380,
        "category_rule": 3,
        "category_question_id": 384,
        "location_rule": 3,
        "location_question_id": 381,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 384,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 381,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:copa:form-4:target-4",
      "service_id": "copa",
      "service_label": "Copa",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 4,
        "name": "Copa",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          4,
          23
        ]
      },
      "targetticket": {
        "id": 4,
        "name": "Copa",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 32,
        "location_rule": 3,
        "location_question_id": 29,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 32,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 29,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:copa:form-4:target-19",
      "service_id": "copa",
      "service_label": "Copa",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 4,
        "name": "Copa",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          4,
          23
        ]
      },
      "targetticket": {
        "id": 19,
        "name": "Copa Para Terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 28,
        "category_rule": 3,
        "category_question_id": 32,
        "location_rule": 3,
        "location_question_id": 29,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 32,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 29,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:copa:form-23:target-133",
      "service_id": "copa",
      "service_label": "Copa",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 23,
        "name": "Copa",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          4,
          23
        ]
      },
      "targetticket": {
        "id": 133,
        "name": "Copa",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 392,
        "location_rule": 3,
        "location_question_id": 390,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 392,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 390,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:copa:form-23:target-134",
      "service_id": "copa",
      "service_label": "Copa",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 23,
        "name": "Copa",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          4,
          23
        ]
      },
      "targetticket": {
        "id": 134,
        "name": "Copa Para Terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 389,
        "category_rule": 3,
        "category_question_id": 392,
        "location_rule": 3,
        "location_question_id": 390,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 392,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 390,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-38",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 38,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 188,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 188,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-39",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 39,
        "name": "Ar Condicionado para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 188,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 188,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-40",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 40,
        "name": "Diversos",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 2,
        "category_question_id": 0,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-41",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 41,
        "name": "Diversos  para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 1,
        "category_question_id": 0,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": null,
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-43",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 43,
        "name": "Elevadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 2,
        "category_question_id": 146,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 146,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-44",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 44,
        "name": "Elevadores  para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 2,
        "category_question_id": 146,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 1
      },
      "questions": {
        "category": {
          "id": 146,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-45",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 45,
        "name": "Elétrica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 197,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 197,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-46",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 46,
        "name": "Elétrica para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 197,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 197,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-47",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 47,
        "name": "Hidráulica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 201,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 201,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-48",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 48,
        "name": "Hidráulica para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 201,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 201,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-49",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 49,
        "name": "Marcenaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 205,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 205,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-50",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 50,
        "name": "Marcenaria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 205,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 205,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-51",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 51,
        "name": "Pedreiro para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 209,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 209,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-52",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 52,
        "name": "Pedreiro",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 209,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 209,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-53",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 53,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 213,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 213,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-54",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 54,
        "name": "Pintura para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 213,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 213,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-55",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 55,
        "name": "Técnico de Redes",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 217,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 217,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-56",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 56,
        "name": "Técnico de Redes para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 217,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 217,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-57",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 57,
        "name": "Vidraçaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 221,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 221,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 94,
              "label": "Vidraçaria",
              "full_label": "Manutenção > Vidraçaria"
            },
            {
              "id": 139,
              "label": "Vidro",
              "full_label": "Manutenção > Vidraçaria > Vidro"
            },
            {
              "id": 140,
              "label": "Janelas",
              "full_label": "Manutenção > Vidraçaria > Janelas"
            },
            {
              "id": 141,
              "label": "Divisórias de vidro",
              "full_label": "Manutenção > Vidraçaria > Divisórias de vidro"
            },
            {
              "id": 142,
              "label": "Outros",
              "full_label": "Manutenção > Vidraçaria > Outros"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-58",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 58,
        "name": "Vidraçaria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 221,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 221,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 94,
              "label": "Vidraçaria",
              "full_label": "Manutenção > Vidraçaria"
            },
            {
              "id": 139,
              "label": "Vidro",
              "full_label": "Manutenção > Vidraçaria > Vidro"
            },
            {
              "id": 140,
              "label": "Janelas",
              "full_label": "Manutenção > Vidraçaria > Janelas"
            },
            {
              "id": 141,
              "label": "Divisórias de vidro",
              "full_label": "Manutenção > Vidraçaria > Divisórias de vidro"
            },
            {
              "id": 142,
              "label": "Outros",
              "full_label": "Manutenção > Vidraçaria > Outros"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-59",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 59,
        "name": "Carregadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 225,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 225,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-60",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 60,
        "name": "Carregadores para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 225,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 225,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-61",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 61,
        "name": "Copa",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 229,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 229,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-62",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 62,
        "name": "Copa Para Terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 229,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 229,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-63",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 63,
        "name": "Jardinagem",
        "audience": "para_mim",
        "destination_entity": {
          "code": 1,
          "mode": "fixed_or_direct",
          "note": "Minority mode; destination_entity_value may be final entity id."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 233,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 233,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-64",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 64,
        "name": "Jardinagem Para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 233,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 233,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-65",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 65,
        "name": "Limpeza",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 237,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 237,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-66",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 66,
        "name": "Limpeza Para Terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 237,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 237,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-67",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 67,
        "name": "Mensageria Para Terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 184,
        "category_rule": 3,
        "category_question_id": 241,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 241,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:diversos:form-18:target-68",
      "service_id": "diversos",
      "service_label": "Diversos",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 18,
        "name": "Diversos",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          18
        ]
      },
      "targetticket": {
        "id": 68,
        "name": "Mensageria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 241,
        "location_rule": 3,
        "location_question_id": 185,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 241,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 185,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:elevadores:form-2:target-2",
      "service_id": "elevadores",
      "service_label": "Elevadores",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 2,
        "name": "Elevadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          2,
          25
        ]
      },
      "targetticket": {
        "id": 2,
        "name": "Elevadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 2,
        "category_question_id": 17,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 1
      },
      "questions": {
        "category": {
          "id": 17,
          "name": "Anexar Arquivo",
          "fieldtype": "file",
          "required": false,
          "raw_values": {}
        },
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:elevadores:form-2:target-21",
      "service_id": "elevadores",
      "service_label": "Elevadores",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 2,
        "name": "Elevadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          2,
          25
        ]
      },
      "targetticket": {
        "id": 21,
        "name": "Elevadores  para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 11,
        "category_rule": 2,
        "category_question_id": 17,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 1
      },
      "questions": {
        "category": {
          "id": 17,
          "name": "Anexar Arquivo",
          "fieldtype": "file",
          "required": false,
          "raw_values": {}
        },
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:elevadores:form-25:target-137",
      "service_id": "elevadores",
      "service_label": "Elevadores",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 25,
        "name": "Elevadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          2,
          25
        ]
      },
      "targetticket": {
        "id": 137,
        "name": "Elevadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 2,
        "category_question_id": 17,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 1
      },
      "questions": {
        "category": {
          "id": 17,
          "name": "Anexar Arquivo",
          "fieldtype": "file",
          "required": false,
          "raw_values": {}
        },
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:elevadores:form-25:target-138",
      "service_id": "elevadores",
      "service_label": "Elevadores",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 25,
        "name": "Elevadores",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          2,
          25
        ]
      },
      "targetticket": {
        "id": 138,
        "name": "Elevadores  para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 406,
        "category_rule": 2,
        "category_question_id": 17,
        "location_rule": 2,
        "location_question_id": 72,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 1
      },
      "questions": {
        "category": {
          "id": 17,
          "name": "Anexar Arquivo",
          "fieldtype": "file",
          "required": false,
          "raw_values": {}
        },
        "location": {
          "id": 72,
          "name": "Telefone de Contato",
          "fieldtype": "integer",
          "required": true,
          "raw_values": {}
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:eletrica:form-5:target-5",
      "service_id": "eletrica",
      "service_label": "Elétrica",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 5,
        "name": "Elétrica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          5,
          24
        ]
      },
      "targetticket": {
        "id": 5,
        "name": "Elétrica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 41,
        "location_rule": 3,
        "location_question_id": 37,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 41,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 37,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:eletrica:form-5:target-20",
      "service_id": "eletrica",
      "service_label": "Elétrica",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 5,
        "name": "Elétrica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          5,
          24
        ]
      },
      "targetticket": {
        "id": 20,
        "name": "Elétrica para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 36,
        "category_rule": 3,
        "category_question_id": 41,
        "location_rule": 3,
        "location_question_id": 37,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 41,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 37,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:eletrica:form-24:target-135",
      "service_id": "eletrica",
      "service_label": "Elétrica",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 24,
        "name": "Elétrica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          5,
          24
        ]
      },
      "targetticket": {
        "id": 135,
        "name": "Elétrica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 401,
        "location_rule": 3,
        "location_question_id": 398,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 401,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 398,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:eletrica:form-24:target-136",
      "service_id": "eletrica",
      "service_label": "Elétrica",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 24,
        "name": "Elétrica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          5,
          24
        ]
      },
      "targetticket": {
        "id": 136,
        "name": "Elétrica para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 397,
        "category_rule": 3,
        "category_question_id": 401,
        "location_rule": 3,
        "location_question_id": 398,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 401,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 398,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:hidraulica:form-6:target-6",
      "service_id": "hidraulica",
      "service_label": "Hidráulica",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 6,
        "name": "Hidráulica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          6,
          26
        ]
      },
      "targetticket": {
        "id": 6,
        "name": "Hidráulica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 50,
        "location_rule": 3,
        "location_question_id": 46,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 50,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 46,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:hidraulica:form-6:target-22",
      "service_id": "hidraulica",
      "service_label": "Hidráulica",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 6,
        "name": "Hidráulica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          6,
          26
        ]
      },
      "targetticket": {
        "id": 22,
        "name": "Hidráulica para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 45,
        "category_rule": 3,
        "category_question_id": 50,
        "location_rule": 3,
        "location_question_id": 46,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 50,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 46,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:hidraulica:form-26:target-139",
      "service_id": "hidraulica",
      "service_label": "Hidráulica",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 26,
        "name": "Hidráulica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          6,
          26
        ]
      },
      "targetticket": {
        "id": 139,
        "name": "Hidráulica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 418,
        "location_rule": 3,
        "location_question_id": 415,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 418,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 415,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:hidraulica:form-26:target-140",
      "service_id": "hidraulica",
      "service_label": "Hidráulica",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 26,
        "name": "Hidráulica",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          6,
          26
        ]
      },
      "targetticket": {
        "id": 140,
        "name": "Hidráulica para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 414,
        "category_rule": 3,
        "category_question_id": 418,
        "location_rule": 3,
        "location_question_id": 415,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 418,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 415,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:jardinagem:form-7:target-14",
      "service_id": "jardinagem",
      "service_label": "Jardinagem",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 7,
        "name": "Jardinagem",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          7,
          27
        ]
      },
      "targetticket": {
        "id": 14,
        "name": "Jardinagem - ##answer_55##",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 58,
        "location_rule": 3,
        "location_question_id": 55,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 58,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 55,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "31",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 31,
          "option_source": "locations",
          "options_count": 11,
          "options_sample": [
            {
              "id": 31,
              "label": "Jardinagem",
              "full_label": "Jardinagem"
            },
            {
              "id": 32,
              "label": "Duque de Caxias 951 (Banrisul)",
              "full_label": "Jardinagem > Duque de Caxias 951 (Banrisul)"
            },
            {
              "id": 33,
              "label": "Casa Civil 1005",
              "full_label": "Jardinagem > Casa Civil 1005"
            },
            {
              "id": 34,
              "label": "Palácio Piratini",
              "full_label": "Jardinagem > Palácio Piratini"
            },
            {
              "id": 54,
              "label": "Jardim Central",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Central"
            },
            {
              "id": 55,
              "label": "Jardim Egípcia",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Egípcia"
            },
            {
              "id": 56,
              "label": "Jardim Galpão",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Galpão"
            },
            {
              "id": 57,
              "label": "Jardim Particular",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Particular"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:jardinagem:form-7:target-23",
      "service_id": "jardinagem",
      "service_label": "Jardinagem",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 7,
        "name": "Jardinagem",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          7,
          27
        ]
      },
      "targetticket": {
        "id": 23,
        "name": "Jardinagem - para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 54,
        "category_rule": 3,
        "category_question_id": 58,
        "location_rule": 3,
        "location_question_id": 55,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 58,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 55,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "31",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 31,
          "option_source": "locations",
          "options_count": 11,
          "options_sample": [
            {
              "id": 31,
              "label": "Jardinagem",
              "full_label": "Jardinagem"
            },
            {
              "id": 32,
              "label": "Duque de Caxias 951 (Banrisul)",
              "full_label": "Jardinagem > Duque de Caxias 951 (Banrisul)"
            },
            {
              "id": 33,
              "label": "Casa Civil 1005",
              "full_label": "Jardinagem > Casa Civil 1005"
            },
            {
              "id": 34,
              "label": "Palácio Piratini",
              "full_label": "Jardinagem > Palácio Piratini"
            },
            {
              "id": 54,
              "label": "Jardim Central",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Central"
            },
            {
              "id": 55,
              "label": "Jardim Egípcia",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Egípcia"
            },
            {
              "id": 56,
              "label": "Jardim Galpão",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Galpão"
            },
            {
              "id": 57,
              "label": "Jardim Particular",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Particular"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:jardinagem:form-27:target-141",
      "service_id": "jardinagem",
      "service_label": "Jardinagem",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 27,
        "name": "Jardinagem",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          7,
          27
        ]
      },
      "targetticket": {
        "id": 141,
        "name": "Jardinagem - ##answer_55##",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 426,
        "location_rule": 3,
        "location_question_id": 424,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 426,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 424,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "31",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 31,
          "option_source": "locations",
          "options_count": 11,
          "options_sample": [
            {
              "id": 31,
              "label": "Jardinagem",
              "full_label": "Jardinagem"
            },
            {
              "id": 32,
              "label": "Duque de Caxias 951 (Banrisul)",
              "full_label": "Jardinagem > Duque de Caxias 951 (Banrisul)"
            },
            {
              "id": 33,
              "label": "Casa Civil 1005",
              "full_label": "Jardinagem > Casa Civil 1005"
            },
            {
              "id": 34,
              "label": "Palácio Piratini",
              "full_label": "Jardinagem > Palácio Piratini"
            },
            {
              "id": 54,
              "label": "Jardim Central",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Central"
            },
            {
              "id": 55,
              "label": "Jardim Egípcia",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Egípcia"
            },
            {
              "id": 56,
              "label": "Jardim Galpão",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Galpão"
            },
            {
              "id": 57,
              "label": "Jardim Particular",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Particular"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:jardinagem:form-27:target-142",
      "service_id": "jardinagem",
      "service_label": "Jardinagem",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 27,
        "name": "Jardinagem",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          7,
          27
        ]
      },
      "targetticket": {
        "id": 142,
        "name": "Jardinagem - para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 423,
        "category_rule": 3,
        "category_question_id": 426,
        "location_rule": 3,
        "location_question_id": 424,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 426,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 424,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "31",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 31,
          "option_source": "locations",
          "options_count": 11,
          "options_sample": [
            {
              "id": 31,
              "label": "Jardinagem",
              "full_label": "Jardinagem"
            },
            {
              "id": 32,
              "label": "Duque de Caxias 951 (Banrisul)",
              "full_label": "Jardinagem > Duque de Caxias 951 (Banrisul)"
            },
            {
              "id": 33,
              "label": "Casa Civil 1005",
              "full_label": "Jardinagem > Casa Civil 1005"
            },
            {
              "id": 34,
              "label": "Palácio Piratini",
              "full_label": "Jardinagem > Palácio Piratini"
            },
            {
              "id": 54,
              "label": "Jardim Central",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Central"
            },
            {
              "id": 55,
              "label": "Jardim Egípcia",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Egípcia"
            },
            {
              "id": 56,
              "label": "Jardim Galpão",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Galpão"
            },
            {
              "id": 57,
              "label": "Jardim Particular",
              "full_label": "Jardinagem > Palácio Piratini > Jardim Particular"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:limpeza:form-8:target-7",
      "service_id": "limpeza",
      "service_label": "Limpeza",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 8,
        "name": "Limpeza",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          8,
          28
        ]
      },
      "targetticket": {
        "id": 7,
        "name": "Limpeza",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 66,
        "location_rule": 3,
        "location_question_id": 63,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 66,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 63,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:limpeza:form-8:target-24",
      "service_id": "limpeza",
      "service_label": "Limpeza",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 8,
        "name": "Limpeza",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          8,
          28
        ]
      },
      "targetticket": {
        "id": 24,
        "name": "Limpezapara terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 62,
        "category_rule": 3,
        "category_question_id": 66,
        "location_rule": 3,
        "location_question_id": 63,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 66,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 63,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:limpeza:form-28:target-143",
      "service_id": "limpeza",
      "service_label": "Limpeza",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 28,
        "name": "Limpeza",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          8,
          28
        ]
      },
      "targetticket": {
        "id": 143,
        "name": "Limpeza",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 434,
        "location_rule": 3,
        "location_question_id": 432,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 434,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 432,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:limpeza:form-28:target-144",
      "service_id": "limpeza",
      "service_label": "Limpeza",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 28,
        "name": "Limpeza",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          8,
          28
        ]
      },
      "targetticket": {
        "id": 144,
        "name": "Limpezapara terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 431,
        "category_rule": 3,
        "category_question_id": 434,
        "location_rule": 3,
        "location_question_id": 432,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 434,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 432,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "-3",
            "show_tree_root": "27",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 27,
          "option_source": "locations",
          "options_count": 23,
          "options_sample": [
            {
              "id": 27,
              "label": "Limpeza",
              "full_label": "Limpeza"
            },
            {
              "id": 1,
              "label": "Casa Civil 1005",
              "full_label": "Limpeza > Casa Civil 1005"
            },
            {
              "id": 60,
              "label": "1° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 61,
              "label": "2° Andar",
              "full_label": "Limpeza > Casa Civil 1005 > 2° Andar"
            },
            {
              "id": 62,
              "label": "Subsolo",
              "full_label": "Limpeza > Casa Civil 1005 > Subsolo"
            },
            {
              "id": 96,
              "label": "Torreão",
              "full_label": "Limpeza > Casa Civil 1005 > Torreão"
            },
            {
              "id": 8,
              "label": "Palácio Piratini",
              "full_label": "Limpeza > Palácio Piratini"
            },
            {
              "id": 63,
              "label": "1° Andar",
              "full_label": "Limpeza > Palácio Piratini > 1° Andar"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-202",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 202,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 639,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 639,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-203",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 203,
        "name": "Elevadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 146,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 146,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-204",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 204,
        "name": "Elétrica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 647,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 647,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-205",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 205,
        "name": "Hidráulica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 651,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 651,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-206",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 206,
        "name": "Marcenaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 655,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 655,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-207",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 207,
        "name": "Pedreiro",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 659,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 659,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-208",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 208,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 663,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 663,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-209",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 209,
        "name": "Técnico de Redes",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 667,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 667,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:manutencao:form-39:target-210",
      "service_id": "manutencao",
      "service_label": "MANUTENÇÃO",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 39,
        "name": "MANUTENÇÃO",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          39
        ]
      },
      "targetticket": {
        "id": 210,
        "name": "Vidraçaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 671,
        "location_rule": 3,
        "location_question_id": 635,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 671,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 94,
              "label": "Vidraçaria",
              "full_label": "Manutenção > Vidraçaria"
            },
            {
              "id": 139,
              "label": "Vidro",
              "full_label": "Manutenção > Vidraçaria > Vidro"
            },
            {
              "id": 140,
              "label": "Janelas",
              "full_label": "Manutenção > Vidraçaria > Janelas"
            },
            {
              "id": 141,
              "label": "Divisórias de vidro",
              "full_label": "Manutenção > Vidraçaria > Divisórias de vidro"
            },
            {
              "id": 142,
              "label": "Outros",
              "full_label": "Manutenção > Vidraçaria > Outros"
            }
          ]
        },
        "location": {
          "id": 635,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:marcenaria:form-9:target-8",
      "service_id": "marcenaria",
      "service_label": "Marcenaria",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 9,
        "name": "Marcenaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          9,
          29
        ]
      },
      "targetticket": {
        "id": 8,
        "name": "Marcenaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 75,
        "location_rule": 3,
        "location_question_id": 71,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 75,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 71,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:marcenaria:form-9:target-25",
      "service_id": "marcenaria",
      "service_label": "Marcenaria",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 9,
        "name": "Marcenaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          9,
          29
        ]
      },
      "targetticket": {
        "id": 25,
        "name": "Marcenaria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 70,
        "category_rule": 3,
        "category_question_id": 75,
        "location_rule": 3,
        "location_question_id": 71,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 75,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 71,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:marcenaria:form-29:target-145",
      "service_id": "marcenaria",
      "service_label": "Marcenaria",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 29,
        "name": "Marcenaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          9,
          29
        ]
      },
      "targetticket": {
        "id": 145,
        "name": "Marcenaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 443,
        "location_rule": 3,
        "location_question_id": 440,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 443,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 440,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:marcenaria:form-29:target-146",
      "service_id": "marcenaria",
      "service_label": "Marcenaria",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 29,
        "name": "Marcenaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          9,
          29
        ]
      },
      "targetticket": {
        "id": 146,
        "name": "Marcenaria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 439,
        "category_rule": 3,
        "category_question_id": 443,
        "location_rule": 3,
        "location_question_id": 440,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 443,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 440,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:mensageria:form-10:target-9",
      "service_id": "mensageria",
      "service_label": "Mensageria",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 10,
        "name": "Mensageria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          10,
          30
        ]
      },
      "targetticket": {
        "id": 9,
        "name": "Mensageria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 84,
        "location_rule": 3,
        "location_question_id": 83,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 84,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 83,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:mensageria:form-10:target-26",
      "service_id": "mensageria",
      "service_label": "Mensageria",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 10,
        "name": "Mensageria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          10,
          30
        ]
      },
      "targetticket": {
        "id": 26,
        "name": "Mensageria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 79,
        "category_rule": 3,
        "category_question_id": 84,
        "location_rule": 3,
        "location_question_id": 83,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 84,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 83,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:mensageria:form-30:target-147",
      "service_id": "mensageria",
      "service_label": "Mensageria",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 30,
        "name": "Mensageria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          10,
          30
        ]
      },
      "targetticket": {
        "id": 147,
        "name": "Mensageria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 452,
        "location_rule": 3,
        "location_question_id": 451,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 452,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 451,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:mensageria:form-30:target-148",
      "service_id": "mensageria",
      "service_label": "Mensageria",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 30,
        "name": "Mensageria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          10,
          30
        ]
      },
      "targetticket": {
        "id": 148,
        "name": "Mensageria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 448,
        "category_rule": 3,
        "category_question_id": 452,
        "location_rule": 3,
        "location_question_id": 451,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 452,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 451,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "36",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 36,
          "option_source": "locations",
          "options_count": 28,
          "options_sample": [
            {
              "id": 36,
              "label": "Carregadores e Mensageiros",
              "full_label": "Carregadores e Mensageiros"
            },
            {
              "id": 19,
              "label": "Defesa Civil - Andrade Neves",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves"
            },
            {
              "id": 20,
              "label": "11° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 11° Andar"
            },
            {
              "id": 22,
              "label": "15° Andar",
              "full_label": "Carregadores e Mensageiros > Defesa Civil - Andrade Neves > 15° Andar"
            },
            {
              "id": 37,
              "label": "Casa Civil 1005",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005"
            },
            {
              "id": 38,
              "label": "1° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 39,
              "label": "2 ° Andar",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > 2 ° Andar"
            },
            {
              "id": 49,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Casa Civil 1005 > Subsolo"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-216",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 216,
        "name": "Ar Condicionado",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 701,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 701,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "1",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 1,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 1,
              "label": "Ar Condicionado",
              "full_label": "Manutenção > Ar Condicionado"
            },
            {
              "id": 2,
              "label": "Conserto",
              "full_label": "Manutenção > Ar Condicionado > Conserto"
            },
            {
              "id": 3,
              "label": "Desinstalação",
              "full_label": "Manutenção > Ar Condicionado > Desinstalação"
            },
            {
              "id": 4,
              "label": "Instalação",
              "full_label": "Manutenção > Ar Condicionado > Instalação"
            },
            {
              "id": 6,
              "label": "Remanejo",
              "full_label": "Manutenção > Ar Condicionado > Remanejo"
            },
            {
              "id": 7,
              "label": "Outras atividades",
              "full_label": "Manutenção > Ar Condicionado > Outras atividades"
            },
            {
              "id": 100,
              "label": "Higienização",
              "full_label": "Manutenção > Ar Condicionado > Higienização"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Ar Condicionado",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-218",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 218,
        "name": "Diversos",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 0,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 1
      },
      "questions": {
        "category": null,
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-220",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 220,
        "name": "Elevadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 146,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 146,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-222",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 222,
        "name": "Elétrica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 709,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 709,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "22",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 22,
          "option_source": "categories",
          "options_count": 8,
          "options_sample": [
            {
              "id": 22,
              "label": "Elétrica",
              "full_label": "Manutenção > Elétrica"
            },
            {
              "id": 23,
              "label": "Conserto",
              "full_label": "Manutenção > Elétrica > Conserto"
            },
            {
              "id": 24,
              "label": "Instalação",
              "full_label": "Manutenção > Elétrica > Instalação"
            },
            {
              "id": 25,
              "label": "Remoção",
              "full_label": "Manutenção > Elétrica > Remoção"
            },
            {
              "id": 26,
              "label": "Readequação",
              "full_label": "Manutenção > Elétrica > Readequação"
            },
            {
              "id": 27,
              "label": "Troca",
              "full_label": "Manutenção > Elétrica > Troca"
            },
            {
              "id": 28,
              "label": "Descarte",
              "full_label": "Manutenção > Elétrica > Descarte"
            },
            {
              "id": 29,
              "label": "Suporte",
              "full_label": "Manutenção > Elétrica > Suporte"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Elétrica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-224",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 224,
        "name": "Hidráulica",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 713,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 713,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "30",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 30,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 30,
              "label": "Hidráulica",
              "full_label": "Manutenção > Hidráulica"
            },
            {
              "id": 31,
              "label": "Reparo/Conserto",
              "full_label": "Manutenção > Hidráulica > Reparo/Conserto"
            },
            {
              "id": 32,
              "label": "Instalação",
              "full_label": "Manutenção > Hidráulica > Instalação"
            },
            {
              "id": 33,
              "label": "Remoção",
              "full_label": "Manutenção > Hidráulica > Remoção"
            },
            {
              "id": 34,
              "label": "Troca",
              "full_label": "Manutenção > Hidráulica > Troca"
            },
            {
              "id": 35,
              "label": "Desentupimento",
              "full_label": "Manutenção > Hidráulica > Desentupimento"
            },
            {
              "id": 111,
              "label": "Vazamento",
              "full_label": "Manutenção > Hidráulica > Vazamento"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Hidráulica",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-226",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 226,
        "name": "Marcenaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 717,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 717,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "50",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 50,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 50,
              "label": "Marcenaria",
              "full_label": "Manutenção > Marcenaria"
            },
            {
              "id": 51,
              "label": "Confecção de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Confecção de Mobiliário"
            },
            {
              "id": 52,
              "label": "Conserto de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Conserto de Mobiliário"
            },
            {
              "id": 53,
              "label": "Remanejo de Mobiliário",
              "full_label": "Manutenção > Marcenaria > Remanejo de Mobiliário"
            },
            {
              "id": 54,
              "label": "Outras Atividades",
              "full_label": "Manutenção > Marcenaria > Outras Atividades"
            },
            {
              "id": 127,
              "label": "Conserto de Aberturas",
              "full_label": "Manutenção > Marcenaria > Conserto de Aberturas"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Marcenaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-229",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 229,
        "name": "Pedreiro",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 721,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 721,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-230",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 230,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 725,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 725,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-232",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 232,
        "name": "Técnico de Redes",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 729,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 729,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-234",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 234,
        "name": "Vidraçaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 733,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 733,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 94,
              "label": "Vidraçaria",
              "full_label": "Manutenção > Vidraçaria"
            },
            {
              "id": 139,
              "label": "Vidro",
              "full_label": "Manutenção > Vidraçaria > Vidro"
            },
            {
              "id": 140,
              "label": "Janelas",
              "full_label": "Manutenção > Vidraçaria > Janelas"
            },
            {
              "id": 141,
              "label": "Divisórias de vidro",
              "full_label": "Manutenção > Vidraçaria > Divisórias de vidro"
            },
            {
              "id": 142,
              "label": "Outros",
              "full_label": "Manutenção > Vidraçaria > Outros"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-236",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 236,
        "name": "Carregadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 737,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 737,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "55",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 55,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 55,
              "label": "Carregadores",
              "full_label": "Conservação > Carregadores"
            },
            {
              "id": 56,
              "label": "Movimentação de Insumos",
              "full_label": "Conservação > Carregadores > Movimentação de Insumos"
            },
            {
              "id": 57,
              "label": "Recolhimento",
              "full_label": "Conservação > Carregadores > Recolhimento"
            },
            {
              "id": 58,
              "label": "Substituição",
              "full_label": "Conservação > Carregadores > Substituição"
            },
            {
              "id": 101,
              "label": "Descarte",
              "full_label": "Conservação > Carregadores > Descarte"
            },
            {
              "id": 102,
              "label": "Movimentação Equipamentos",
              "full_label": "Conservação > Carregadores > Movimentação Equipamentos"
            },
            {
              "id": 103,
              "label": "Movimentação Mobiliário",
              "full_label": "Conservação > Carregadores > Movimentação Mobiliário"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Carregadores",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-238",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 238,
        "name": "Copa",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 741,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 741,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "98",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 98,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 98,
              "label": "Copa",
              "full_label": "Conservação > Copa"
            },
            {
              "id": 105,
              "label": "Agua",
              "full_label": "Conservação > Copa > Agua"
            },
            {
              "id": 106,
              "label": "Café",
              "full_label": "Conservação > Copa > Café"
            },
            {
              "id": 107,
              "label": "Limpar louça de salas",
              "full_label": "Conservação > Copa > Limpar louça de salas"
            },
            {
              "id": 108,
              "label": "Recolher e Limpar Louças Sala de Reunião",
              "full_label": "Conservação > Copa > Recolher e Limpar Louças Sala de Reunião"
            },
            {
              "id": 109,
              "label": "Repor Café,Agua Sala de reunião",
              "full_label": "Conservação > Copa > Repor Café,Agua Sala de reunião"
            },
            {
              "id": 110,
              "label": "Repor Louça de salas",
              "full_label": "Conservação > Copa > Repor Louça de salas"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Copa",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-240",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 240,
        "name": "Jardinagem",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 745,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 745,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "37",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 37,
          "option_source": "categories",
          "options_count": 11,
          "options_sample": [
            {
              "id": 37,
              "label": "Jardinagem",
              "full_label": "Conservação > Jardinagem"
            },
            {
              "id": 36,
              "label": "Plantação",
              "full_label": "Conservação > Jardinagem > Plantação"
            },
            {
              "id": 38,
              "label": "Poda/Corte",
              "full_label": "Conservação > Jardinagem > Poda/Corte"
            },
            {
              "id": 39,
              "label": "Remoção",
              "full_label": "Conservação > Jardinagem > Remoção"
            },
            {
              "id": 40,
              "label": "Outras Atividades",
              "full_label": "Conservação > Jardinagem > Outras Atividades"
            },
            {
              "id": 112,
              "label": "Manutenção de folhagens internas",
              "full_label": "Conservação > Jardinagem > Manutenção de folhagens internas"
            },
            {
              "id": 113,
              "label": "Varrição",
              "full_label": "Conservação > Jardinagem > Varrição"
            },
            {
              "id": 114,
              "label": "Descarte",
              "full_label": "Conservação > Jardinagem > Descarte"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Jardinagem",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-242",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 242,
        "name": "Limpeza",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 749,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 749,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "45",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 45,
          "option_source": "categories",
          "options_count": 14,
          "options_sample": [
            {
              "id": 45,
              "label": "Limpeza",
              "full_label": "Conservação > Limpeza"
            },
            {
              "id": 46,
              "label": "Limpeza de banheiros",
              "full_label": "Conservação > Limpeza > Limpeza de banheiros"
            },
            {
              "id": 47,
              "label": "Limpeza geral",
              "full_label": "Conservação > Limpeza > Limpeza geral"
            },
            {
              "id": 48,
              "label": "Outras Atividades",
              "full_label": "Conservação > Limpeza > Outras Atividades"
            },
            {
              "id": 49,
              "label": "Recolher materiais recicláveis",
              "full_label": "Conservação > Limpeza > Recolher materiais recicláveis"
            },
            {
              "id": 118,
              "label": "Lava a Jato",
              "full_label": "Conservação > Limpeza > Lava a Jato"
            },
            {
              "id": 119,
              "label": "Bandeirante",
              "full_label": "Conservação > Limpeza > Bandeirante"
            },
            {
              "id": 120,
              "label": "Janelas e Portas",
              "full_label": "Conservação > Limpeza > Janelas e Portas"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Limpeza",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:multiplas-demandas:form-40:target-245",
      "service_id": "multiplas-demandas",
      "service_label": "Multiplas Demandas",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 40,
        "name": "Multiplas Demandas",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          40
        ]
      },
      "targetticket": {
        "id": 245,
        "name": "Mensageria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 3,
        "category_question_id": 753,
        "location_rule": 3,
        "location_question_id": 697,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 753,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "128",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 128,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 128,
              "label": "Mensageria",
              "full_label": "Conservação > Mensageria"
            },
            {
              "id": 129,
              "label": "Movimentação Documentos",
              "full_label": "Conservação > Mensageria > Movimentação Documentos"
            },
            {
              "id": 130,
              "label": "Movimentação Insumos até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Insumos até 5Kg"
            },
            {
              "id": 131,
              "label": "Movimentação Materiais até 5Kg",
              "full_label": "Conservação > Mensageria > Movimentação Materiais até 5Kg"
            },
            {
              "id": 132,
              "label": "Outras entregas e Movimentações até 5Kg",
              "full_label": "Conservação > Mensageria > Outras entregas e Movimentações até 5Kg"
            }
          ]
        },
        "location": {
          "id": 697,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Conservação > Mensageria",
        "domain": "Conservação",
        "assignment_group": {
          "id": 21,
          "label": "CC-CONSERVACÃO",
          "source_rule_id": 155
        },
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pedreiro:form-11:target-10",
      "service_id": "pedreiro",
      "service_label": "Pedreiro",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 11,
        "name": "Pedreiro",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          11,
          31
        ]
      },
      "targetticket": {
        "id": 10,
        "name": "Pedreiro",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 93,
        "location_rule": 3,
        "location_question_id": 89,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 93,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 89,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pedreiro:form-11:target-27",
      "service_id": "pedreiro",
      "service_label": "Pedreiro",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 11,
        "name": "Pedreiro",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          11,
          31
        ]
      },
      "targetticket": {
        "id": 27,
        "name": "Pedreiro para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 88,
        "category_rule": 3,
        "category_question_id": 93,
        "location_rule": 3,
        "location_question_id": 89,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 93,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 89,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pedreiro:form-31:target-149",
      "service_id": "pedreiro",
      "service_label": "Pedreiro",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 31,
        "name": "Pedreiro",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          11,
          31
        ]
      },
      "targetticket": {
        "id": 149,
        "name": "Pedreiro",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 461,
        "location_rule": 3,
        "location_question_id": 458,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 461,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 458,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pedreiro:form-31:target-150",
      "service_id": "pedreiro",
      "service_label": "Pedreiro",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 31,
        "name": "Pedreiro",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          11,
          31
        ]
      },
      "targetticket": {
        "id": 150,
        "name": "Pedreiro para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 457,
        "category_rule": 3,
        "category_question_id": 461,
        "location_rule": 3,
        "location_question_id": 458,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 461,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "81",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 81,
          "option_source": "categories",
          "options_count": 7,
          "options_sample": [
            {
              "id": 81,
              "label": "Pedreiro",
              "full_label": "Manutenção > Pedreiro"
            },
            {
              "id": 82,
              "label": "Instalação",
              "full_label": "Manutenção > Pedreiro > Instalação"
            },
            {
              "id": 83,
              "label": "Remoção",
              "full_label": "Manutenção > Pedreiro > Remoção"
            },
            {
              "id": 84,
              "label": "Perfuração/Escavação",
              "full_label": "Manutenção > Pedreiro > Perfuração/Escavação"
            },
            {
              "id": 133,
              "label": "Montagem/Desmontagem",
              "full_label": "Manutenção > Pedreiro > Montagem/Desmontagem"
            },
            {
              "id": 134,
              "label": "Reparo",
              "full_label": "Manutenção > Pedreiro > Reparo"
            },
            {
              "id": 135,
              "label": "Reparo de pedras portuguesas",
              "full_label": "Manutenção > Pedreiro > Reparo de pedras portuguesas"
            }
          ]
        },
        "location": {
          "id": 458,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pedreiro",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pintura:form-12:target-11",
      "service_id": "pintura",
      "service_label": "Pintura",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 12,
        "name": "Pintura",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          12,
          32
        ]
      },
      "targetticket": {
        "id": 11,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 102,
        "location_rule": 3,
        "location_question_id": 98,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 102,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 98,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pintura:form-12:target-28",
      "service_id": "pintura",
      "service_label": "Pintura",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 12,
        "name": "Pintura",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          12,
          32
        ]
      },
      "targetticket": {
        "id": 28,
        "name": "Pintura para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 97,
        "category_rule": 3,
        "category_question_id": 102,
        "location_rule": 3,
        "location_question_id": 98,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 102,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 98,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pintura:form-32:target-151",
      "service_id": "pintura",
      "service_label": "Pintura",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 32,
        "name": "Pintura",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          12,
          32
        ]
      },
      "targetticket": {
        "id": 151,
        "name": "Pintura",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 470,
        "location_rule": 3,
        "location_question_id": 467,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 470,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 467,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:pintura:form-32:target-152",
      "service_id": "pintura",
      "service_label": "Pintura",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 32,
        "name": "Pintura",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          12,
          32
        ]
      },
      "targetticket": {
        "id": 152,
        "name": "Pintura para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 466,
        "category_rule": 3,
        "category_question_id": 470,
        "location_rule": 3,
        "location_question_id": 467,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 470,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "85",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 85,
          "option_source": "categories",
          "options_count": 6,
          "options_sample": [
            {
              "id": 85,
              "label": "Pintura",
              "full_label": "Manutenção > Pintura"
            },
            {
              "id": 86,
              "label": "Parede",
              "full_label": "Manutenção > Pintura > Parede"
            },
            {
              "id": 87,
              "label": "Outros",
              "full_label": "Manutenção > Pintura > Outros"
            },
            {
              "id": 136,
              "label": "Aberturas",
              "full_label": "Manutenção > Pintura > Aberturas"
            },
            {
              "id": 137,
              "label": "Forro",
              "full_label": "Manutenção > Pintura > Forro"
            },
            {
              "id": 138,
              "label": "Mobiliário",
              "full_label": "Manutenção > Pintura > Mobiliário"
            }
          ]
        },
        "location": {
          "id": 467,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Pintura",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:projeto:form-36:target-246",
      "service_id": "projeto",
      "service_label": "Projeto",
      "profile_visibility": [
        {
          "id": 4,
          "name": "Super-Admin"
        },
        {
          "id": 12,
          "name": "Solicitante-GG-Conservação"
        }
      ],
      "form": {
        "id": 36,
        "name": "Projeto",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          15,
          36
        ]
      },
      "targetticket": {
        "id": 246,
        "name": "Chamado",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 58,
        "category_rule": 2,
        "category_question_id": 144,
        "location_rule": 3,
        "location_question_id": 501,
        "type_rule": 1,
        "urgency_rule": 1,
        "show_rule": 1
      },
      "questions": {
        "category": {
          "id": 144,
          "name": "Assunto",
          "fieldtype": "text",
          "required": true,
          "raw_values": {}
        },
        "location": {
          "id": 501,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "0",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": null,
        "domain": null,
        "assignment_group": null,
        "base_task_templates": [],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:tecnico-de-redes:form-13:target-12",
      "service_id": "tecnico-de-redes",
      "service_label": "Técnico de Redes",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 13,
        "name": "Técnico de Redes",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          13,
          34
        ]
      },
      "targetticket": {
        "id": 12,
        "name": "Rede Computadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 111,
        "location_rule": 3,
        "location_question_id": 107,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 111,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 107,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:tecnico-de-redes:form-13:target-29",
      "service_id": "tecnico-de-redes",
      "service_label": "Técnico de Redes",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 13,
        "name": "Técnico de Redes",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          13,
          34
        ]
      },
      "targetticket": {
        "id": 29,
        "name": "Rede Computadores para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 106,
        "category_rule": 3,
        "category_question_id": 111,
        "location_rule": 3,
        "location_question_id": 107,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 111,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 107,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:tecnico-de-redes:form-34:target-153",
      "service_id": "tecnico-de-redes",
      "service_label": "Técnico de Redes",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 34,
        "name": "Técnico de Redes",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          13,
          34
        ]
      },
      "targetticket": {
        "id": 153,
        "name": "Rede Computadores",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 487,
        "location_rule": 3,
        "location_question_id": 484,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 487,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 484,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:tecnico-de-redes:form-34:target-154",
      "service_id": "tecnico-de-redes",
      "service_label": "Técnico de Redes",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 34,
        "name": "Técnico de Redes",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          13,
          34
        ]
      },
      "targetticket": {
        "id": 154,
        "name": "Rede Computadores para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 483,
        "category_rule": 3,
        "category_question_id": 487,
        "location_rule": 3,
        "location_question_id": 484,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 487,
          "name": "Tipo",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "88",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 88,
          "option_source": "categories",
          "options_count": 5,
          "options_sample": [
            {
              "id": 88,
              "label": "Rede Computadores",
              "full_label": "Manutenção > Rede Computadores"
            },
            {
              "id": 89,
              "label": "Instalação de Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Instalação de Rede Lógica"
            },
            {
              "id": 90,
              "label": "Readequação Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Readequação Rede Lógica"
            },
            {
              "id": 91,
              "label": "Conserto Rede Lógica",
              "full_label": "Manutenção > Rede Computadores > Conserto Rede Lógica"
            },
            {
              "id": 92,
              "label": "Organização de Cabeamento",
              "full_label": "Manutenção > Rede Computadores > Organização de Cabeamento"
            }
          ]
        },
        "location": {
          "id": 484,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Rede Computadores",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:vidracaria:form-14:target-13",
      "service_id": "vidracaria",
      "service_label": "Vidraçaria",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 14,
        "name": "Vidraçaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          14,
          35
        ]
      },
      "targetticket": {
        "id": 13,
        "name": "Vidraçaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 2,
          "mode": "requester_context_para_mim",
          "note": "Observed on Solicitante para-mim targets; resolve entity from requester/session context."
        },
        "destination_entity_value": 0,
        "category_rule": 3,
        "category_question_id": 120,
        "location_rule": 3,
        "location_question_id": 116,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 120,
          "name": "Serviço",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "locations",
          "options_count": 1,
          "options_sample": [
            {
              "id": 94,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Palacio Piratini > Subsolo"
            }
          ]
        },
        "location": {
          "id": 116,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:vidracaria:form-14:target-30",
      "service_id": "vidracaria",
      "service_label": "Vidraçaria",
      "profile_visibility": [
        {
          "id": 9,
          "name": "Solicitante"
        }
      ],
      "form": {
        "id": 14,
        "name": "Vidraçaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          14,
          35
        ]
      },
      "targetticket": {
        "id": 30,
        "name": "Vidraçaria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 115,
        "category_rule": 3,
        "category_question_id": 120,
        "location_rule": 3,
        "location_question_id": 116,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 120,
          "name": "Serviço",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "locations",
          "options_count": 1,
          "options_sample": [
            {
              "id": 94,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Palacio Piratini > Subsolo"
            }
          ]
        },
        "location": {
          "id": 116,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:vidracaria:form-35:target-155",
      "service_id": "vidracaria",
      "service_label": "Vidraçaria",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 35,
        "name": "Vidraçaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          14,
          35
        ]
      },
      "targetticket": {
        "id": 155,
        "name": "Vidraçaria",
        "audience": "para_mim",
        "destination_entity": {
          "code": 7,
          "mode": "maintenance_context_para_mim",
          "note": "Observed on Manutenção e Conservação para-mim targets; departmental/operational mode."
        },
        "destination_entity_value": 24,
        "category_rule": 3,
        "category_question_id": 496,
        "location_rule": 3,
        "location_question_id": 493,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 496,
          "name": "Serviço",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "locations",
          "options_count": 1,
          "options_sample": [
            {
              "id": 94,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Palacio Piratini > Subsolo"
            }
          ]
        },
        "location": {
          "id": 493,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    },
    {
      "catalog_record_id": "sis:vidracaria:form-35:target-156",
      "service_id": "vidracaria",
      "service_label": "Vidraçaria",
      "profile_visibility": [
        {
          "id": 11,
          "name": "Manutenção e Conservação"
        }
      ],
      "form": {
        "id": 35,
        "name": "Vidraçaria",
        "active": true,
        "visible": true,
        "helpdesk_home": true,
        "duplicate_name_form_ids": [
          14,
          35
        ]
      },
      "targetticket": {
        "id": 156,
        "name": "Vidraçaria para terceiro",
        "audience": "para_terceiro",
        "destination_entity": {
          "code": 8,
          "mode": "third_party_question",
          "note": "Observed on para-terceiro targets; value usually references beneficiary/user question, not final entity."
        },
        "destination_entity_value": 492,
        "category_rule": 3,
        "category_question_id": 496,
        "location_rule": 3,
        "location_question_id": 493,
        "type_rule": 1,
        "urgency_rule": 3,
        "show_rule": 2
      },
      "questions": {
        "category": {
          "id": 496,
          "name": "Serviço",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_ticket_categories": "all",
            "show_tree_depth": "0",
            "show_tree_root": "94",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 94,
          "option_source": "locations",
          "options_count": 1,
          "options_sample": [
            {
              "id": 94,
              "label": "Subsolo",
              "full_label": "Carregadores e Mensageiros > Palacio Piratini > Subsolo"
            }
          ]
        },
        "location": {
          "id": 493,
          "name": "Localização",
          "fieldtype": "dropdown",
          "required": true,
          "raw_values": {
            "show_tree_depth": "2",
            "show_tree_root": "70",
            "selectable_tree_root": "0",
            "entity_restrict": "2"
          },
          "root_id": 70,
          "option_source": "locations",
          "options_count": 359,
          "options_sample": [
            {
              "id": 70,
              "label": "Locais",
              "full_label": "Locais"
            },
            {
              "id": 71,
              "label": "Casa Civil 1005",
              "full_label": "Locais > Casa Civil 1005"
            },
            {
              "id": 79,
              "label": "1° Andar",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar"
            },
            {
              "id": 276,
              "label": "P1S01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S01"
            },
            {
              "id": 277,
              "label": "P1S03",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S03"
            },
            {
              "id": 278,
              "label": "P1S02",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S02"
            },
            {
              "id": 279,
              "label": "P1S04",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1S04"
            },
            {
              "id": 280,
              "label": "P1C01",
              "full_label": "Locais > Casa Civil 1005 > 1° Andar > P1C01"
            }
          ]
        }
      },
      "expected_result": {
        "category_root": "Manutenção > Vidraçaria",
        "domain": "Manutenção",
        "assignment_group": {
          "id": 22,
          "label": "CC-MANUTENCAO",
          "source_rule_id": 156
        },
        "base_task_templates": [
          {
            "id": 1,
            "label": "EQUIPE EXECUTORA"
          },
          {
            "id": 3,
            "label": "MATERIAIS UTILIZADOS"
          },
          {
            "id": 2,
            "label": "SERVIÇO REALIZADO"
          }
        ],
        "location_map_task_rules": "Apply RuleTicket location rules 158-177 after GLPI read-back; map tasks are pattern-based, not precomputed for every option.",
        "attachment_policy": {
          "create_route": "POST /Ticket/{ticket_id}/Document",
          "upload_manifest_content_type": "application/json multipart part",
          "proof": "Document.id + Document_Item by Document.id or GLPI Web clickable attachment; ticket content text is not proof."
        },
        "readback_contract": [
          "GET/SEARCH Ticket: id, entity, category, group, status, requesttype",
          "GET Ticket include_tasks/admin-equivalent: task templates when permitted",
          "Document_Item by Document.id/admin-equivalent when attachment uploaded"
        ]
      }
    }
  ],
  "etag": "3a1efeb78d13472a100d9089359e68df22968583f602c41347fc836a8aaafbd3",
  "source_snapshot_hash": "33881ae7ba9e63520d1856d90921b34c1c635a85a785dbdf80a041a0b03f22bc"
};
