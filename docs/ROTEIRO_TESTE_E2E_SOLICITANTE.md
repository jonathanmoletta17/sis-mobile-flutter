# Roteiro de Teste E2E — Fluxo do Solicitante via APK (caminho Worker)

> Objetivo: validar pelo **APK real** (caminho de produção, via Worker `workers.dev`)
> todos os fluxos do perfil **Solicitante**, usando a **CONTA DE TESTE dedicada**
> — que reproduz com fidelidade o cenário de qualquer Solicitante (ex.: o do
> incidente original). Não é necessário usar a conta de nenhum usuário real.

## Por que a conta de teste basta

O direito e o comportamento são definidos pelo **perfil** (Solicitante = perfil 9),
não pela pessoa. A conta de teste tem o perfil Solicitante; logada por ele, ela é
funcionalmente idêntica a qualquer outro Solicitante. Assim validamos o caminho
completo sem tocar dados de usuários reais.

## Pré-requisitos

1. **APK atualizado** com o fix (PR mergeado: criação por payload mínimo +
   aprovar/recusar solução via followup).
2. **Direito `CREATE`** concedido ao perfil Solicitante no GLPI (já feito:
   Configurar → Perfis → Solicitante → Assistência → Chamados → "Criar").
3. **Perfil padrão da conta de teste = Solicitante.** Crítico: o APK acessa via
   Worker, que **não** expõe `changeActiveProfile`; a sessão usa o **perfil
   padrão** da conta. Se a conta de teste tem mais de um perfil (ex.: também
   técnico), defina o padrão como Solicitante em: Administração → Usuários →
   `<conta de teste>` → aba Autorizações → marcar o perfil Solicitante como
   **padrão**. (Reverter ao fim, se desejado.)
4. **GLPI web aberto em paralelo** (admin ou a própria conta) para validação
   cruzada das evidências.
5. **Um ator técnico** para propor solução nos cenários C6/C7: pode ser a mesma
   conta de teste alternando para o perfil técnico **no GLPI web** (não no app),
   ou outra conta técnica de teste.

## Convenções

- Todo chamado de teste: título inicia com **`[TESTE-AUTOMATIZADO SIS]`**.
- Anote o **ID** de cada chamado criado (coluna na matriz).
- Capture **screenshot** de cada tela-chave (resultado de envio, conversa, etc.).
- Ao final, **feche** todos os chamados de teste (ver seção Limpeza).

---

## Cenários

### C1 — Login e perfil
- **Passos:** abrir o APK → login com a conta de teste.
- **Esperado:** login ok; app abre o catálogo de serviços do **Solicitante**.
- **Evidência:** screenshot da tela inicial; confirmar que aparecem os serviços
  esperados do perfil (Conservação/Manutenção conforme catálogo).

### C2 — Criar chamado "Para mim" (Conservação → Limpeza)
- **Passos:** selecionar **Limpeza** → preencher assunto/descrição/localização →
  enviar.
- **Esperado:** mensagem **"✅ Chamado enviado com sucesso! ID: XXXX"**. **Sem**
  erro `400`/`ERROR_GLPI_ADD`.
- **Validação cruzada (GLPI web), chamado XXXX:**
  - Requerente = conta de teste.
  - Categoria = Conservação → Limpeza (ou a escolhida).
  - **Grupo atribuído = CC-CONSERVAÇÃO** (atribuído pela RuleTicket, não pelo app).
  - Status = Novo.

### C3 — Criar chamado "Para outra pessoa"
- **Passos:** novo chamado → opção **"Para outra Pessoa"** → buscar e selecionar
  um beneficiário (use outra **conta de teste** ou colega de QA, não usuário real
  de produção) → enviar.
- **Esperado:** criado com sucesso.
- **Validação cruzada:** **Requerente = beneficiário**; **Observador = conta de
  teste** (quem abriu). Entidade conforme a do beneficiário.

### C4 — Anexar arquivo
- **Passos:** novo chamado → anexar uma imagem/PDF pequeno → enviar.
- **Esperado:** chamado criado; app indica sucesso (sem aviso de falha de anexo).
- **Validação cruzada:** no chamado, o **documento aparece anexado** (aba
  Documentos / clipe de anexo).

### C5 — Enviar mensagem (acompanhamento)
- **Passos:** abrir um chamado próprio aberto → escrever e enviar uma mensagem.
- **Esperado:** a mensagem aparece na conversa.
- **Validação cruzada:** **followup** registrado no chamado, autor = conta de teste.

### C6 — Aprovar solução
- **Pré-condição:** um técnico (no GLPI web) **propõe uma solução** no chamado →
  status vai a **Solucionado**.
- **Passos (APK):** abrir o chamado solucionado → **Aprovar solução**.
- **Esperado:** app confirma; o chamado **fecha**.
- **Validação cruzada:** status do chamado = **Fechado**; followup de aprovação
  registrado.

### C7 — Recusar solução
- **Pré-condição:** técnico propõe solução → status **Solucionado**.
- **Passos (APK):** abrir o chamado → **Recusar solução** + justificativa.
- **Esperado:** app confirma; o chamado **reabre**.
- **Validação cruzada:** status volta a **Novo/Em atendimento**; followup com a
  **justificativa** registrado.

### C8 — Listar "Meus chamados"
- **Passos:** abrir a lista de chamados no app.
- **Esperado:** aparecem os chamados criados pela conta de teste (C2–C4),
  com status coerente ao GLPI.

### C9 — Mensagem de erro legível (não-regressão)
- **Passos:** forçar uma falha (ex.: ativar modo avião ao enviar) e tentar criar.
- **Esperado:** mensagem clara ao usuário, **sem** `Exception: Exception:`
  duplicado. Em erro de permissão/recusa do GLPI, o chamado **não** é salvo
  offline (mensagem "Nada foi salvo offline...").

---

## Matriz de resultados (preencher na execução)

| Cenário | Esperado | Resultado | ID chamado | Evidência (print) | OK? |
| --- | --- | --- | --- | --- | --- |
| C1 Login/perfil | catálogo Solicitante | | — | | |
| C2 Criar "para mim" | 201 + grupo CC-CONSERVAÇÃO | | | | |
| C3 Criar "para outra pessoa" | requester=beneficiário, observer=conta | | | | |
| C4 Anexar arquivo | documento anexado | | | | |
| C5 Enviar mensagem | followup registrado | | | | |
| C6 Aprovar solução | status → Fechado | | | | |
| C7 Recusar solução | status → reaberto + justificativa | | | | |
| C8 Meus chamados | lista coerente | | — | | |
| C9 Erro legível | mensagem sem "Exception:" | | — | | |

---

## Limpeza (obrigatória)

O Solicitante **não fecha** chamado direto (sem direito `UPDATE`). Para encerrar
os chamados de teste criados:
- **Aprovar a solução** pelo próprio app (C6) fecha; ou
- Um **técnico/admin** no GLPI web: atribuir categoria (se faltar) → registrar
  solução → fechar.

Registre os IDs encerrados para auditoria.

---

## Notas técnicas (limitações conhecidas — não são bugs do fluxo)

- **Task templates do FormCreator** (ex.: "EQUIPE EXECUTORA", "MATERIAIS
  UTILIZADOS") **não** são criados na via nativa `POST /Ticket` — só o FormCreator
  os gera. O chamado é criado e roteado (grupo certo), mas sem esses templates de
  tarefa. O app emite *warning* no read-back; **não bloqueia**.
- O Solicitante **não lê** `TicketTask`/`Document_Item` via API (`task=0`,
  `document=0`), então o **read-back governado é parcial** para ele — não afeta a
  criação nem o roteamento.
- `changeActiveProfile` **não passa pelo Worker**: por isso o perfil padrão da
  conta de teste precisa ser Solicitante para este roteiro (pré-requisito 3).

## Cobertura já validada por backend (GLPI direto, automatizada)

Os mesmos fluxos já foram validados E2E contra o GLPI **direto** pelo harness
`test/validation/sis_mutable_validation_test.dart` (conta de teste, perfil
Solicitante via `changeActiveProfile`), com evidências de efeito real:
criar (201 + grupo 21), mensagem (201), anexo (documento vinculado=1), aprovar
(5→6), recusar (5→1), para-terceiro (requester=beneficiário, observer=logado).
Este roteiro cobre a camada que **falta**: o **APK real pelo caminho do Worker**.
