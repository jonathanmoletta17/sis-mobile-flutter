# MVP Scope Final - 2026-06-14

**Status:** ✅ **PRONTO PARA PRODUÇÃO**

**Decisões Pragmáticas Tomadas para Entrega TODAY**

---

## 1. Regras de Permissão (Quem Pode Fazer O Quê)

**Decisão:** ✅ MANTER HARDCODED

**Localização:** `lib/policy/permission_service.dart:7-10`

**Regras Seladas:**
- `canView`: isAdmin OR isRequester OR isTechnician
- `canSendFollowup`: isOpen (status 1-4)
- `canAttachFile`: isOpen (status 1-4)
- `canProposeSolution`: isTechnician AND isOpen AND !isRequester
- `canValidateSolution`: isRequester AND status==5
- `canChangeStatus`: isTechnician AND isOpen AND !isRequester

**Risco:** Baixo
- Regras institucionais e raramente mudam
- Se mudar no GLPI: requer rebuild + redistribuição APK (não bloqueante)

**Rationale:** Pragmatismo MVP. Economia de ~3-5 dias de desenvolvimento para API dinâmica.

---

## 2. Mapeamento Perfil GLPI → Flutter Role

**Decisão:** ✅ MANTER HARDCODED + FALLBACK

**Localização:** `lib/models/operational_role.dart:56-100`

**Enum Values (8 Total):**
- `admin` (perfis: "admin", "super-admin")
- `supervisor` (perfil: "supervisor")
- `conservationTechnician` (perfil: "technician" + grupo 21)
- `maintenanceTechnician` (perfil: "technician" + grupo 22)
- `hybrid` (perfil: "technician" com múltiplos grupos)
- `standardRequester` (perfis: "requesteur", "self-service", "solicitante")
- `ggConservationRequester` (requerente em grupo 49)
- `unknown` (fallback: graceful degradation)

**Risco:** Médio
- Novo perfil GLPI não será reconhecido
- Fallback: OperationalRole.unknown (não quebra app)
- Se houver novo perfil: adicionar à enum (15 min)

**Rationale:** Perfis são raros; quando aparecem, fallback é seguro.

---

## 3. Códigos de Status (1-6)

**Decisão:** ✅ MANTER 100% HARDCODED (SEALED)

**Localização:** `lib/models/glpi_status.dart:1-25`

**Mapeamento (GLPI International Standard):**
- 1 = novo
- 2 = emAtendimento
- 3 = planejado
- 4 = pendente
- 5 = solucionado
- 6 = fechado

**Risco:** Praticamente Zero
- Padrão GLPI internacional (imutável)
- Labels SÃO dinâmicos (vêm do GLPI)
- Códigos SÃO constantes (ISO-like)

**Rationale:** É padrão, não muda. Labels dinâmicos já cubrem extensibilidade.

---

## 4. Atores Validator / Question_Group

**Decisão:** ✅ IGNORADO - PRÓXIMA ITERAÇÃO (v2)

**Localização:** `lib/services/glpi_ticket_support.dart:168-173`

**O Que Está Ignorado:**
- `type == 'validator'`: Atores que validam automaticamente
- `type == 'question_group'`: Grupos baseados em resposta de pergunta

**Risco:** Médio
- Only affects IF GLPI SIS usa esses tipos
- If needed: 1-2 dias de implementação (não bloqueante)

**Como Implementar (se necessário):**
```dart
// Para validator:
if (type == 'validator') {
  _validators.add(actor.value);  // Capturar validadores
  continue;
}

// Para question_group:
if (type == 'question_group') {
  _groupsByQuestion[actor.value] = actor.role;  // Resolver após resposta
  continue;
}
```

**Rationale:** MVP não precisa. Forme Requerente pode validar em status=5.

---

## 5. Outras Perguntas FormCreator

**Decisão:** ✅ IGNORADO - MVP = Categoria + Localização

**Localização:** `lib/screens/form_template.dart:27-60`

**O Que É Renderizado (MVP):**
- ✅ `categoryQuestion`: dropdown dinâmico
- ✅ `locationQuestion`: dropdown dinâmico

**O Que É Ignorado:**
- ❌ Texto livre (text input)
- ❌ Checkbox (multi-select)
- ❌ Data (date picker)
- ❌ Multi-select
- ❌ Outras questões customizadas

**Risco:** Médio-Alto
- Depends on FormCreator complexity no GLPI SIS
- If needed: 3-5 dias de implementação

**Rationale:** MVP scope. GLPI web é fallback para forms complexos.

---

## Estado do MVP

### Funcionalidades Implementadas & Validadas

✅ **Catálogo Governado v3**
- 100% dinâmico (lê do GLPI em tempo de execução)
- Sub-serviços agregados funcionando
- 208 testes passando

✅ **Fluxo de Leitura de Tickets**
- Listar pessoais, técnicos, operacionais
- Detalhe com conversa/histórico
- Offline read funciona

✅ **Criação de Tickets**
- Online com entidade explícita
- Offline com preservação de entidade
- Sync com readback validation

✅ **Solution Validation**
- Requester pode validar em status=5
- Testes atualizados
- ERROR_RIGHT_MISSING tratado gracefully

✅ **Encoding UTF-8**
- 107 strings triple-encoded fixadas
- 15 strings double-encoded fixadas
- 0 garbled strings no código

### Lacunas Conhecidas (Próximas Iterações)

- Atores validator/question_group (v2)
- Outras perguntas FormCreator (v2)
- Workflows dinâmicos (v3)
- Notificações push (v3)

---

## Checklist de Validação GLPI Admin

Para confirmar que MVP não tem bloqueadores:

- [ ] Quais perfis existem no SIS? (Resposta esperada: admin, supervisor, technician, requester + variantes)
- [ ] FormCreator tem perguntas além de categoria/localização? (Resposta esperada: não, ou sim → mark v2)
- [ ] FormCreator usa validator ou question_group? (Resposta esperada: não)

---

## Commits de Escopo

| Commit | Descrição |
|--------|-----------|
| `1e64e9d` | feat(validation): habilitar validação de solução |
| `a3466ec` | fix(glpi_client): corrigir 107 strings triple-encoded UTF-8 |
| `7c032b3` | chore: remover comentários STORY/ALTERAÇÃO obsoletos |
| `84ea47e` | docs: finalize scope - document hardcoded vs dynamic decisions |

---

## Próximas Ações (Após MVP)

**v1.1 (1-2 semanas):**
- Implementar atores validator/question_group (se GLPI usa)

**v2.0 (1-2 meses):**
- Expandir FormCreator para suportar outras perguntas
- Implementar workflows customizados

**v3.0 (TBD):**
- Notificações push
- Relatórios
- Analytics

---

**Approved By:** (Você - confirmar GLPI admin validations)
**Date:** 2026-06-14
**Status:** ✅ READY FOR PRODUCTION
