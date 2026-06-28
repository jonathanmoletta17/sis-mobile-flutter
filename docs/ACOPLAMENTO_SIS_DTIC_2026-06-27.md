# Análise de acoplamento: SIS Mobile × DTIC

Data: 2026-06-27  
Branch: `fix/onda0-rede-seguranca`  
Contexto: refatoração para eliminar IDs hardcoded (21/22/49) do runtime e
preparar integração agnóstica de múltiplas instâncias GLPI. Fixtures de teste
podem continuar registrando IDs reais da SIS, mas não como regra de runtime.

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

### 1.2 Acoplamento problemático original (corrigido no runtime)

| Arquivo | Código | Problema | Impacto |
|---|---|---|---|
| `lib/models/ticket_domain.dart` | antes inferia domínio por `group.id in {21, 22, 49}` | IDs cravados da SIS | Corrigido: usa `GlpiGroupSemantics` por nome de grupo |
| `lib/models/operational_role.dart` | antes tinha constantes estáticas `21/22/49` | Mesmo problema | Corrigido: role técnico depende de semântica do nome do grupo |
| `lib/policy/permission_service.dart` | dependia da resolução acima | Transitivo | Corrigido junto com role/domain |
| Testes (`test/ticket_domain_test.dart`, etc.) | antes aceitavam `21`, `22`, `49` como prova suficiente | Não guiavam portabilidade | Corrigido: testes garantem que ID numérico isolado não classifica |

---

## 2. Por que isso importa

### 2.1 Risco original: o aplicativo parecia dinâmico, mas dependia de IDs

**Antes:**
```dart
final groupIds = groups.map((g) => g.id).toSet();
final hasConservation = groupIds.contains(21); // ← problema aqui
```

**Agora:**
```dart
final hasConservation = groups.any(GlpiGroupSemantics.isConservation);
```

**Decisão atual:** IDs SIS podem existir em fixtures de teste e documentação de
fonte da verdade da instância, mas não podem ser a regra de classificação do
runtime.

### 2.2 Efeito cascata original, agora evitado

1. DTIC herdaria `OperationalRole` com uma constante numerica da SIS.
2. Servidor DTIC retornaria `glpigroups = [id: 105, name: 'DTIC-Conservação']`.
3. App tentaria `groupIds.contains(21)` -> não acharia -> role = `unknown`.
4. Telas técnicas ficariam invisíveis.
5. Usuário DTIC veria só "Meus Chamados".

---

## 3. Refatoração — o que foi feito

### 3.1 Semântica de grupo no runtime

Foi criada a classe `GlpiGroupSemantics`, que classifica grupos por nome
normalizado:

- `CC-MANUTENCAO` -> manutenção;
- `CC-CONSERVACAO` -> conservação;
- `GG-CONSERVACAO` -> observador GG;
- nome vazio/desconhecido -> `unknown`.

Com isso, os IDs reais da SIS deixam de ser regra de runtime. Testes novos
garantem que `id=21`, `id=22` ou `id=49` sem nome de grupo não classificam
papel, domínio ou fila.

### 3.2 Fixtures dinâmicas (source of truth de teste)

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

**Uso correto:** fixtures registram os IDs reais da instância SIS para testes que
precisam representar dados GLPI vivos. Elas não são mais usadas como regra de
classificação do app.

### 3.3 Testes refatorados

Eliminamos 11 literais (`21`, `22`, `49`) de 4 arquivos de teste:

| Arquivo | Antes | Depois |
|---|---|---|
| `test/ticket_domain_test.dart` | `GlpiGroupRef(id: 21, ...)` | `GlpiGroupRef(id: sisConservationGroupId, ...)` |
| `test/ticket_queue_classifier_test.dart` | `21` em esperado | `sisConservationGroupId` em esperado |
| `test/ticket_queue_filter_test.dart` | `22` hardcoded | `sisMaintenanceGroupId` |
| `test/app_state_operational_new_queue_test.dart` | `49` hardcoded | `sisGgConservationGroupId` |

**Benefício:** intenção clara e cobertura contra regressão de ID fixo.

---

## 4. Proposta: InstanceConfig (Onda futura)

Para contratos que ainda sejam de instância, ainda pode fazer sentido injetar
configuração. Para grupos técnicos, a regra atual preferida é semântica por nome
de grupo, não ID numérico.

```dart
/// lib/config/instance_config.dart
abstract class InstanceConfig {
  String get baseUrl;
  // Ex.: flags, capacidades, manifests e contratos de catalogo.
}
```

**Vantagens:**
- Zero hardcodes de grupos no código de produção
- Ambas as instâncias usam a mesma lógica
- Testes usam configs mock (`MockInstanceConfig`)
- Fácil adicionar 3ª, 4ª instância

**Investimento:** depende dos demais contratos de instância; para grupos
operacionais, a refatoração já foi aplicada por `GlpiGroupSemantics`.

---

## 5. Decisão: próximos passos

### 5.1 Agora (2026-06-27)
✅ Fixtures criadas  
✅ 11 literais eliminados de testes  
✅ Intenção semântica clara  
✅ Runtime sem classificação por IDs fixos `21/22/49`

### 5.2 Onda futura
- [ ] Implementar `InstanceConfig` injetável para contratos que ainda forem de instância
- [ ] Mapear IDs da instância DTIC e popular `dtic_instance_groups.dart` apenas para testes de dados vivos
- [ ] Validar contra GLPI DTIC ao vivo

---

## 6. Resumo para manutenção

| Item | Ação |
|---|---|
| **IDs de grupo mudam** | Atualize fixtures/testes que representam a instância, mas o runtime deve continuar por nome/semântica |
| **DTIC ganha IDs** | Preencha `test/fixtures/dtic_instance_groups.dart` apenas para testes de dados vivos |
| **App continua agnóstico** | Sim — `TicketDomain.resolve()` e `OperationalRoleResolver` leem `groups` dinamicamente por nome/semântica |
| **Testes refletem mudanças** | Sim — fixtures são source of truth |
| **Novo app (3ª instância)** | Criar fixtures se houver testes com dados vivos, manter classificação por semântica de grupo e estender `InstanceConfig` só para contratos realmente de instância |

---

## Referências

- [[consolidacao-p1-p5-roadmap]] — princípios de governança GLPI
- [[dtic_conceptual_model]] — modelo conceitual extraído do SIS para DTIC
- `lib/models/glpi_group_semantics.dart` (semântica de grupo)
- `lib/models/operational_role.dart` (resolução de papel)
- `lib/models/ticket_domain.dart` (lógica de domínio)
- `test/fixtures/sis_instance_groups.dart` (nova fixture)
