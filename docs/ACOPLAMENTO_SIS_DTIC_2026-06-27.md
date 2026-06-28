# Análise de acoplamento: SIS Mobile × DTIC

Data: 2026-06-27  
Branch: `fix/onda0-rede-seguranca`  
Contexto: refatoração de testes para eliminar IDs hardcoded (21/22/49) e preparar para integração agnóstica de múltiplas instâncias GLPI.

---

## 1. Estado atual do acoplamento

O repositório `sis-mobile-flutter` serve **duas instâncias GLPI** simultaneamente:
- **SIS** (instância nativa, grupos 21/22/49, perfis 9/11/12)
- **DTIC** (nova instância, grupos/perfis TBD)

Estrutura:
```
lib/
  ├── ... (código SIS)
  ├── dtic/
  │   ├── dtic_app.dart (entry point DTIC)
  │   ├── config/dtic_config.dart (DTIC_GLPI_BASE_URL)
  │   ├── services/dtic_glpi_client.dart
  │   ├── state/dtic_app_state.dart
  │   └── ... (telas, models, utils espelhados de SIS)
```

### 1.1 Acoplamento fino (aceitável)

| Componente | Consumido por | Razão | Risco |
|---|---|---|---|
| `lib/theme/app_theme.dart` | SIS + DTIC | Tema genérico (cores, tipografia) | Baixo — mudanças futuras apenas estéticas |
| `lib/models/glpi_status.dart` | SIS + DTIC | Protocolo GLPI (status 1-6) | Zero — definido pelo GLPI core |
| `lib/utils/glpi_name_formatter.dart` | SIS + DTIC | Parse de labels GLPI genéricos | Baixo — regex reusável |
| `lib/models/glpi_identity.dart` | SIS + DTIC | Tipos de sessão (userId, etc.) | Zero — tipos primitivos |

→ **Conclusão:** esses componentes são reutilizáveis porque não assumem IDs/perfis específicos.

### 1.2 Acoplamento problemático (documentado)

| Arquivo | Código | Problema | Impacto |
|---|---|---|---|
| `lib/models/ticket_domain.dart` | `resolve()` usa `group.id in {21, 22, 49}` | IDs cravados da SIS | DTIC falha se grupos tiverem IDs diferentes |
| `lib/models/operational_role.dart` | `OperationalRoleResolver.conservationGroupId = 21` | Constantes estáticas | Mesmo problema |
| `lib/policy/permission_service.dart` | Usa `OperationalRoleResolver` | Depende de OperationalRole.resolve() | Transitivo |
| Testes (`test/ticket_domain_test.dart`, etc.) | Hardcodam `21`, `22`, `49` | Não refletem dinâmica | Falham em DTIC; não guiam refatoração |

---

## 2. Por que isso importa

### 2.1 O aplicativo é agnóstico, mas os testes não

**App:**
```dart
// lib/models/ticket_domain.dart — resolve() lê grupos dinamicamente
final groupIds = groups.map((g) => g.id).toSet();
final hasConservation = groupIds.contains(21); // ← problema aqui
```

**Testes (antes):**
```dart
// test/ticket_domain_test.dart
final groups = [GlpiGroupRef(id: 21, name: 'CC-Conservação')]; // ← hardcoded
expect(TicketDomain.resolve(...groups...), equals(TicketDomain.conservation));
```

**Problema:** testes passam na SIS (grupo 21 existe), falham em DTIC (grupo 21 não existe).

### 2.2 Efeito cascata

1. DTIC herda `OperationalRole` com `conservationGroupId = 21`
2. Servidor DTIC retorna `glpigroups = [id: 105, name: 'DTIC-Conservação']`
3. App tenta `groupIds.contains(21)` → não acha → role = `unknown`
4. Telas técnicas ficam invisíveis
5. Usuário DTIC vê só "Meus Chamados"

---

## 3. Refatoração — o que foi feito

### 3.1 Fixtures dinâmicas (source of truth)

Criamos **`test/fixtures/sis_instance_groups.dart`** e **`test/fixtures/dtic_instance_groups.dart`**:

```dart
// test/fixtures/sis_instance_groups.dart
const int sisConservationGroupId = 21;
const int sisMaintenanceGroupId = 22;
const int sisGgConservationGroupId = 49;
```

```dart
// test/fixtures/dtic_instance_groups.dart
// TODO(dtic): Mapear IDs da instância DTIC
// const int dticConservationGroupId = ???;
```

**Benefício:** um lugar para atualizar IDs. Quando SIS muda (grupo 21 → 23), atualizamos a fixture e todos os testes refletem.

### 3.2 Testes refatorados

Eliminamos 11 literais (`21`, `22`, `49`) de 4 arquivos de teste:

| Arquivo | Antes | Depois |
|---|---|---|
| `test/ticket_domain_test.dart` | `GlpiGroupRef(id: 21, ...)` | `GlpiGroupRef(id: sisConservationGroupId, ...)` |
| `test/ticket_queue_classifier_test.dart` | `21` em esperado | `sisConservationGroupId` em esperado |
| `test/ticket_queue_filter_test.dart` | `22` hardcoded | `sisMaintenanceGroupId` |
| `test/app_state_operational_new_queue_test.dart` | `49` hardcoded | `sisGgConservationGroupId` |

**Benefício:** intenção clara (semântica, não número) + centralizado + fácil de refatorar para DTIC.

---

## 4. Proposta: InstanceConfig (Onda futura)

Para eliminar completamente o acoplamento, propõe-se **injetar a configuração da instância**:

```dart
/// lib/config/instance_config.dart
abstract class InstanceConfig {
  String get baseUrl;
  int get conservationGroupId;
  int get maintenanceGroupId;
  int get ggConservationGroupId;
  // ... outros configs
}

/// lib/config/sis_instance_config.dart
class SisInstanceConfig implements InstanceConfig {
  @override
  int get conservationGroupId => 21;
  // ...
}

/// lib/config/dtic_instance_config.dart
class DticInstanceConfig implements InstanceConfig {
  @override
  int get conservationGroupId => 105; // diferente!
  // ...
}

/// lib/main.dart ou lib/dtic/dtic_main.dart
void main() {
  final config = Environment.isDtic ? DticInstanceConfig() : SisInstanceConfig();
  runApp(MyApp(instanceConfig: config));
}
```

**Vantagens:**
- Zero hardcodes no código de produção
- Ambas as instâncias usam a mesma lógica
- Testes usam configs mock (`MockInstanceConfig`)
- Fácil adicionar 3ª, 4ª instância

**Investimento:** médio (refatorar `TicketDomain`, `OperationalRole`, `PermissionService` para receber injeção).

---

## 5. Decisão: próximos passos

### 5.1 Agora (2026-06-27)
✅ Fixtures criadas  
✅ 11 literais eliminados de testes  
✅ Intenção semântica clara  

### 5.2 Onda futura
- [ ] Implementar `InstanceConfig` injetável
- [ ] Remover constantes estáticas de `OperationalRole` / `TicketDomain`
- [ ] Mapear IDs da instância DTIC e popular `dtic_instance_groups.dart`
- [ ] Validar contra GLPI DTIC ao vivo

---

## 6. Resumo para manutenção

| Item | Ação |
|---|---|
| **IDs de grupo mudam** | Atualize `test/fixtures/sis_instance_groups.dart` (um arquivo, criptografia central) |
| **DTIC ganha IDs** | Preencha `test/fixtures/dtic_instance_groups.dart` e implemente `InstanceConfig` |
| **App continua agnóstico** | Sim — `TicketDomain.resolve()` lê `groups` dinamicamente, nunca hardcoda |
| **Testes refletem mudanças** | Sim — fixtures são source of truth |
| **Novo app (3ª instância)** | Criar `novo_instance_groups.dart`, estender `InstanceConfig`, pronto |

---

## Referências

- [[consolidacao-p1-p5-roadmap]] — princípios de governança GLPI
- [[dtic_conceptual_model]] — modelo conceitual extraído do SIS para DTIC
- `lib/models/operational_role.dart` (constantes a refatorar)
- `lib/models/ticket_domain.dart` (lógica de domínio)
- `test/fixtures/sis_instance_groups.dart` (nova fixture)
