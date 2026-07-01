# Portabilidade: subir o app sobre uma nova instância GLPI

> **O que é:** o checklist para colocar o app em pé sobre **outro** GLPI (DTIC e os dois
> novos departamentos) **sem reescrever código** — porque a configuração de instância
> passa a ser *buscada*, não *hardcoded*.
>
> Pré-requisito conceitual:
> [`METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md`](METODOLOGIA_DESCOBERTA_REGRAS_GLPI.md) e
> [`MAPA_FONTE_DA_VERDADE_GLPI.md`](MAPA_FONTE_DA_VERDADE_GLPI.md).

---

## 1. Por que isto é necessário

Cada instância GLPI tem **nomes de perfil, IDs de grupo, IDs de categoria, templates,
regras e formulários diferentes**. Tudo isso é **configuração de instância** (classe I).
Se o app os trata como constantes, cada novo GLPI exige um garfo de código. O objetivo da
portabilidade é que **a única diferença entre instâncias seja dados buscados por API**.

A prova de que o caminho certo é viável já existe no repo: o cliente DTIC
(`lib/dtic/services/dtic_glpi_client.dart`) **busca o catálogo FormCreator por API e
renderiza dinamicamente**, filtrando por perfil ativo via `PluginFormcreatorForm_Profile`.
Esse é o padrão a generalizar; o catálogo **estático** do SIS
(`lib/data/service_data.dart`) é o anti-padrão a aposentar.

---

## 2. O que descobrir por instância (read-only)

Para cada novo GLPI, rodar a descoberta **somente-leitura** (conta de teste, sem mutação)
e obter, por endpoint:

| Descobrir | Endpoint | Vira no app |
|---|---|---|
| Versão do GLPI | `GET /getGlpiConfig` | decide se FormCreator (10) ou Forms nativo (11) |
| Perfis do usuário + rights | `GET /getMyProfiles`, `GET /getFullSession` | visibilidade/ações por bitmask |
| Entidades acessíveis | `GET /getMyEntities`, `GET /getActiveEntities` | seletor de entidade |
| Categorias | `GET /ITILCategory` | catálogo de abertura |
| Grupos | `GET /Group` | filas/atribuição |
| Templates | `GET /TicketTemplate/:id` (+ campos) | campos obrigatórios/ocultos do form |
| Regras | `GET /Rule?searchText[sub_type]=RuleTicket` (+ Criteria/Action) | previsão de atribuição |
| Formulários | `GET /PluginFormcreatorForm` (+ Section/Question/Condition/Target/Form_Profile) | forms dinâmicos por perfil |

Tudo isso está detalhado, com tabela e classe, no
[`MAPA_FONTE_DA_VERDADE_GLPI.md`](MAPA_FONTE_DA_VERDADE_GLPI.md).

---

## 3. O que pode ser constante (classe P) e o que não pode (classe I)

**Permitido como constante (protocolo, verificar por versão):** nomes de itemtype; os 6
status do ticket; valores de bitmask de rights (`READMY=1`...); enums de
urgência/impacto/prioridade; field-IDs de search; formato de `getFullSession`.

**Proibido hardcodar (instância — sempre buscar):** nomes de perfil; IDs e nomes de
grupo; IDs e nomes de categoria; localizações; templates e seus campos; RuleTicket;
parâmetros de questão de formulário (incl. "limitar sub-níveis"); quais perfis veem quais
formulários.

**Regra de revisão (vale para qualquer agente/PR):** antes de introduzir uma constante
ligada a perfil/grupo/categoria/status/regra, classifique-a. Se for **I**, ela tem que
vir de um endpoint. Sem exceção silenciosa.

---

## 4. Mapa de débito técnico — estado atual vs. alvo

Levantamento dos hardcodes de **instância** hoje no código e de qual endpoint cada um
*deveria* vir. **Isto é registro de débito, não execução** (refactor é rodada futura).

| Hardcode atual | Onde | Classe | Deveria vir de |
|---|---|---|---|
| Papel por **nome** do perfil (`"tecnico"`, `"solicitante"`...) | `lib/models/operational_role.dart:56-105` | I | rights do `getFullSession` (bitmask), não o nome |
| IDs de grupo 21/22/49 | `lib/models/ticket_domain.dart:33-35`, `lib/policy/permission_service.dart` | I | `GET /Group` + atribuição da regra/sessão |
| IDs de categoria (~20) | `lib/data/service_data.dart` | I | `GET /ITILCategory` |
| Catálogo de formulário estático | `lib/data/service_data.dart` | I | FormCreator por API (padrão do `dtic_glpi_client.dart`) |
| Campos obrigatórios fixos do form | `lib/services/glpi_ticket_support.dart` | I | `TicketTemplate` (mandatory/hidden/predefined) |
| Visibilidade/transições por perfil | `assets/glpi_rules_sis.json` (snapshot) | I | rights + regras vivas (ver §5) |
| Status 1–6, enums | `lib/models/glpi_status.dart` | **P** | OK manter como constante rotulada |
| Field-IDs de search (1,2,4,5,12,15,65,66...) | `lib/services/glpi_client.dart` | **P** | OK; confirmar via `listSearchOptions` |

> Não corrigir nada disto agora. O alvo é que cada linha **I** seja substituída por leitura
> de endpoint, numa rodada de refatoração planejada à parte, habilitada por esta base.

---

## 5. Decisão a registrar: snapshot vs. busca viva

Existe hoje um meio-termo: `assets/glpi_rules_sis.json` (transições/visibilidade/search
por perfil) é um **snapshot de build-time**, gerado por um script externo a este checkout
(`glpi-arch-investigation/bin/build_app_contract.py`, conforme
[`docs/MODELO_CONCEITUAL_GLPI_SIS_PARA_DTIC.md`](../MODELO_CONCEITUAL_GLPI_SIS_PARA_DTIC.md)).
Isso é melhor que hardcode espalhado, mas ainda é **estático e por instância**.

Duas estratégias de alvo (decisão a tomar conscientemente, não agora):

- **Snapshot versionado por instância:** um contrato JSON gerado por instância, validado
  contra o GLPI real e versionado. Simples, offline-friendly, mas precisa de regeneração
  quando o admin muda config.
- **Busca viva:** o app consulta os endpoints em runtime (login + cache com invalidação).
  Reflete mudanças automaticamente; exige cache e tratamento offline.

Recomendação inicial: **híbrido** — busca viva para estado de sessão (perfis/rights/
entidades, que mudam por login) + snapshot versionado para catálogo pesado (categorias/
formulários), com invalidação. Registrar a escolha final aqui quando decidida.

---

## 6. Checklist de bring-up de um GLPI novo

1. [ ] Confirmar versão (`getGlpiConfig`) → escolher trilha FormCreator (10) vs. Forms (11).
2. [ ] Configurar `.env` da instância (base URL `/apirest.php`, App-Token, conta de teste).
3. [ ] Rodar descoberta read-only (§2) e preencher um mapa fonte-da-verdade da instância.
4. [ ] Conferir que nenhum dado da §4 (classe I) está hardcoded para esta instância.
5. [ ] Validar visibilidade pela leitura de rights, não por nome de perfil.
6. [ ] Validar read-back de um `POST /Ticket` de teste (templates podem não aplicar via API
       — GLPI #15225, relato não confirmado; comportamento de RuleTicket a confirmar
       empiricamente, não presumir).
7. [ ] Registrar IDs/nomes descobertos como **dados da instância**, nunca no código.
