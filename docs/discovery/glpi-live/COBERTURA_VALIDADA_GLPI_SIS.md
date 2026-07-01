# Cobertura Validada — GLPI SIS (evidência ao vivo)

> **O que é:** o resultado de uma validação **empírica, read-only**, contra o GLPI SIS real
> (não pesquisa de doc). Cada domínio aqui foi **batido na API da instância** e tem
> evidência salva em `evidence/`. Substitui "achamos que cobre" por "medimos e provamos".
>
> **Data:** 2026-06-27 · **Instância:** GLPI **10.0.2** (`<host-interno>/sis`, via VPN)
> · **Conta:** conta de teste admin, perfil ativo **Super-Admin (id 4)** via `changeActiveProfile`.
> **Reauditável:** `tool/glpi-discovery/*.sh` (read-only) regenera tudo para SIS/DTIC/novos.

---

## 1. Método de garantia (por que isto é prova, não opinião)

Três fontes independentes, reconciliadas:

1. **Régua externa (exaustividade):** schema oficial GLPI 10.0.x (`install/mysql/glpi-empty.sql`,
   baixado do GitHub) = **390 tabelas**. Define o universo; ninguém de nós o inventou. A linha
   10.0.x é *superset* da 10.0.2 (patches não removem tabelas) → a régua nunca subestima.
2. **Validação empírica (disponibilidade):** `GET /:itemtype?range=0-0` na instância real.
   `206`=com dados · `200 []`=existe, 0 registros nesta instância · `403`=sem right no perfil.
3. **Delimitação (fronteira):** o menu **Administração + Configuração** do GLPI web define o que
   conta como "config" relevante ao app.

---

## 2. Achado central — a tese do projeto, provada ao vivo

Varrendo com o **perfil padrão** da conta (id 11, *Manutenção e Conservação* — técnico),
**todo** itemtype de Administração retornou **`403 ERROR_RIGHT_MISSING`**. Após
`changeActiveProfile` para **Super-Admin (id 4)**, **tudo abriu**.

> A visibilidade **não é regra a codar** — é o **rights do perfil ativo**. O mesmo usuário vê
> universos diferentes conforme o perfil. O app só precisa **ler o bitmask de `getFullSession`
> e o seletor `getMyProfiles`/`changeActiveProfile`**, e projetar. Confirmado empiricamente,
> não inferido. Evidência: `evidence/Profile.json` (403 no perfil 11) vs varredura no perfil 4.

A conta de teste possui os perfis: 4 Super-Admin, 6 Técnico, 9 Solicitante, 11 Manut.&Conserv.,
28 DTI — é o "ator universal de validação" descrito no `CLAUDE.md`.

---

## 3. Cobertura por domínio de Administração/Configuração (validado)

| Domínio | itemtype(s) | Status | Registros (instância) |
|---|---|---|---|
| **Perfis & Rights** | `Profile`, `ProfileRight`, `Profile_User` | ✅ 206 | 11 / **1166** / 1445 |
| **Usuários/Grupos/Entidades** | `User`, `Group`, `Group_User`, `Entity` | ✅ 206 | 1421 / 99 / 1262 / 85 |
| **Regras de negócio** | `Rule`, `RuleCriteria`, `RuleAction` | ✅ 206 | **171** / 262 / 297 |
| **Categorias ITIL** | `ITILCategory`, `TaskCategory` | ✅ 206/200 | 109 / 1 |
| **Localizações** | `Location` | ✅ 206 | **422** (← "limitar sub-níveis") |
| **Dropdowns** | `RequestType`,`SolutionType`,`State`,`Calendar`,`Holiday`,`Manufacturer` | ✅ 206/200 | 9 / vazios |
| **Templates de Ticket** | `TicketTemplate` + Mandatory/Predefined/Hidden | ✅ 206 | 4 / 3 / — / 15 |
| **SLA/OLA** | `SLM`,`SLA`,`OLA` | ✅ 200 `[]` | 0 (não configurado) |
| **Notificações** | `Notification`,`NotificationTemplate` | ✅ 206 | 85 / 40 |
| **Automação/Docs** | `CronTask`,`Document`,`DocumentType` | ✅ 206 | 44 / 7565 / 73 |
| **Config global** | `Config` | ✅ 206 | **230** (context/name/value) |
| **API/Auth/Mail/Listas** | `APIClient`,`AuthLDAP`,`MailCollector`,`Blacklist` | ✅ 206/200 | 6 / 1 / 1 / 71 |
| **FormCreator** | `Form`,`Section`,`Question`,`Condition`,`TargetTicket`,`Form_Profile`,`Category` | ✅ 206 | 41 / 250 / **7011** / **6598** / 242 / 52 / 3 |
| **Preferências de exibição** | `DisplayPreference` | 🔴 **403** | bloqueado p/ admin (config de UI por usuário) |

**Veredito:** dos domínios de Administração/Configuração visados, **todos exceto
`DisplayPreference` são legíveis dinamicamente via API**, com evidência salva. A tese "o app
pode refletir 100% do GLPI" está **empiricamente sustentada** para a camada de configuração.

---

## 4. Limitação honesta (o que isto NÃO prova)

O cross-check derivou itemtype das 390 tabelas por **singularização heurística** e bateu cada
um. Resultado: 19×`206`, 39×`200`, 11×`403`, **321×`400`**. Os `400` **não** provam ausência —
a heurística erra nomes irregulares (`calendarsegments`→`CalendarSegment`,
`changetemplates`→`ChangeTemplate` são itemtypes **reais** não nomeados pela heurística). Logo:

- **Provado (presença):** todo `206`/`200` é endpoint real confirmado.
- **Não provado (ausência):** a varredura ampla não garante que nenhum domínio escapou, porque
  os `400` misturam relações N:N, tabelas internas **e** falsos-negativos de nomenclatura.

**Para fechar 100%:** obter a **lista canônica de itemtypes** (mapeamento real
`getItemTypeForTable` do GLPI, não heurística). Mitigação atual: o cross-check **capturou** os
domínios de config não-óbvios (`Config`,`Blacklist`,`APIClient`,`AuthLDAP`,`MailCollector`),
então nenhum domínio de Administração relevante ficou de fora com confiança razoável.

---

## 5. Como reauditar (SIS, DTIC, próximos)

```bash
tool/glpi-discovery/probe_version.sh      # detecta versão da instância
tool/glpi-discovery/collect_coverage.sh   # bate a lista curada + salva evidence/ + coverage.csv
tool/glpi-discovery/crosscheck.sh         # varre as 390 tabelas (rede de segurança)
```
Tudo read-only. Para DTIC/novo GLPI: apontar `.env` para a instância e rodar. A lista curada é
ponto de partida; ajustar à versão (GLPI 11 troca FormCreator por `Glpi\Form\*`).

## 6. Próximo passo (decisão de código — não delegável)

Com a config provada como dinâmica, o débito técnico fica explícito: o app hardcoda o que a API
entrega. Priorização vem da `coverage_matrix_endpoints` (memória) + `MAPA_FONTE_DA_VERDADE`.
