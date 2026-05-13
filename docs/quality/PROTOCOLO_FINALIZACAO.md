# Protocolo de Finalizacao

## Objetivo

Transformar a fase final de desenvolvimento em um processo finito, observavel e testavel.

Este protocolo existe para evitar dois erros recorrentes:

- declarar uma entrega pronta por percepcao subjetiva;
- entrar em refactor amplo quando o problema real ainda nao foi provado.

Ele nao substitui `DOR.md`, `DOD.md` ou os protocolos de autopsia. Ele decide qual deles usar e como parar no ponto certo.

## Regra central

Evidencia vem antes de arquitetura.

Antes de propor refactor, nova camada, policy central, cache global ou redesenho de fluxo, responda:

- qual fato observado prova o problema?
- qual invariante foi violado?
- qual teste ou reproducao demonstra a falha?
- por que uma correcao local validada nao basta?
- qual custo de manutencao a nova estrutura introduz?

Se essas perguntas nao tiverem resposta concreta, faca a menor correcao validavel e pare.

## Classificacao inicial

Antes de comecar, classifique a mudanca.

| Tipo | Exemplos | Processo minimo |
| --- | --- | --- |
| Trivial | typo, texto, comentario, ajuste isolado sem regra | alterar, revisar diff, validar comando aplicavel |
| Visual | layout, componente, tela, estado visual | Widgetbook quando houver superficie coberta; revisar regressao visual |
| Dominio | ticket, status, entidade, sessao, anexo, mensagem, offline | DoR minimo, invariantes, teste focado, DoD aplicavel |
| Bug localizado | comportamento errado restrito a uma tela ou funcao | `docs/AUTOPSIA_RAPIDA.md` |
| Bug sistemico | divergencia UI/API/GLPI, permissao, stale state, transicao critica | `docs/AUTOPSIA_COMPLETA.md` |
| Runtime | Android, `.env`, acesso externo, build, emulador, APK | docs de runtime/distribuicao e validacao na camada correta |

Se a classificacao mudar durante a investigacao, registre a mudanca e siga o processo mais rigoroso.

## Matriz de integridade

Para qualquer eixo relevante do app, preencher mentalmente ou em nota curta:

| Pergunta | Resposta esperada |
| --- | --- |
| Entidade critica | Qual objeto pode mudar? |
| Estados | Quais estados existem e quais sao terminais? |
| Acoes | Quais comandos podem mutar dados? |
| Papeis | Quem pode executar ou ver cada acao? |
| Fonte de verdade | GLPI, estado local, cache, storage ou runtime? |
| Divergencia | Quem vence se local e remoto discordarem? |
| Estados invalidos | O que a UI nao deve mostrar? |
| Guarda de execucao | O que impede acao disparada por tela obsoleta? |
| Pos-acao | O que precisa ser recarregado ou invalidado? |
| Evidencia | Qual teste, log, screenshot ou comando prova? |

Essa matriz se aplica a tickets, mas tambem a sessao, entidade GLPI, formulario, anexos, identidade, offline e runtime Android.

## Niveis de rigor

Use o menor nivel que cubra o risco real.

### Nivel 0 - Ajuste simples

Use quando nao ha estado de dominio, permissao, runtime ou mutacao remota.

Validacao tipica:

- revisar diff;
- `git diff --check`;
- comando especifico se existir.

### Nivel 1 - Fluxo simples

Use quando existe comportamento de usuario, mas sem transicao critica.

Validacao tipica:

- fluxo feliz;
- um erro esperado;
- teste focado se a regra puder quebrar de novo.

### Nivel 2 - Dominio com estado

Use quando a entrega toca ticket, sessao, entidade, anexo, mensagem, identidade ou offline.

Validacao minima:

- `docs/quality/DOR.md`;
- teste automatizado do caminho feliz ou invalido mais importante;
- `docs/quality/DOD.md` nos niveis aplicaveis;
- `flutter analyze`;
- `flutter test`.

### Nivel 3 - Fluxo critico remoto

Use quando ha GLPI real, stale state, permissao, fechamento, sincronizacao, anexo ou Android.

Validacao minima:

- autopsia rapida ou completa se veio de bug;
- teste automatizado para o caminho invalido;
- refresh/revalidacao antes de mutacao quando aplicavel;
- evidencia manual quando o risco depende de runtime real;
- Android host quando envolver APK, emulador, `adb` ou distribuicao.

## Eixos do SIS Mobile

### Ticket e status

Perguntas obrigatorias:

- o estado remoto foi revalidado antes de mutar?
- `Solucionado` e `Fechado` bloqueiam acoes indevidas?
- lista, detalhe e conversa convergem depois da acao?
- tecnico-solicitante recebe a visao correta?

### Sessao e autenticacao

Perguntas obrigatorias:

- sessao expirada limpa estado sensivel?
- chamadas 401/403 convergem para a mesma experiencia?
- tela antiga consegue executar acao com token invalido?
- o usuario logado e usado como fonte de verdade em todas as telas?

### Entidade GLPI

Perguntas obrigatorias:

- ticket e criado na entidade correta?
- troca de entidade invalida listas antigas?
- storage local preserva entidade sem criar vazamento entre usuarios?
- fallback de entidade e explicito?

### Formulario e payload

Perguntas obrigatorias:

- o que e payload tecnico para GLPI e o que e resumo humano?
- campos tecnicos vazam na UI?
- anexo aparece como nome humano ou identificador bruto?
- mudanca de formulario tem teste de renderizacao legivel?

### Identidade e nomes

Perguntas obrigatorias:

- ID numerico aparece somente quando nao ha nome resolvivel?
- solicitante, tecnico, autor de mensagem e autor de solucao seguem o mesmo fallback?
- cache de nomes nao mistura usuarios?

### Mensagens, anexos e documentos

Perguntas obrigatorias:

- ticket terminal bloqueia envio?
- falha de upload deixa estado local coerente?
- anexo nao duplica se a acao for repetida?
- documento fica vinculado ao ticket correto?

### Offline e sincronizacao

Perguntas obrigatorias:

- item pendente pode ser enviado duas vezes?
- erro de rede preserva payload suficiente para retentativa?
- retentativa revalida entidade, usuario e estado remoto quando aplicavel?
- conflito entre fila local e GLPI tem decisao explicita?

### Android e runtime

Perguntas obrigatorias:

- a WSL continua sendo raiz canonica de fonte?
- Android SDK, emulator e `adb` rodam na camada Windows quando necessario?
- APK gerado corresponde ao estado atual do repo?
- `.env`, keystores e outputs continuam fora do versionamento?

## Padrao de execucao para agentes

Ao receber uma tarefa nao trivial neste repo:

1. Reportar o tipo de mudanca e o nivel de rigor escolhido.
2. Ler os docs especificos do eixo afetado.
3. Separar fato, hipotese e evidencia se houver bug.
4. Escrever ou atualizar o menor teste que prova o risco.
5. Implementar a menor correcao suficiente.
6. Rodar os gates aplicaveis.
7. Declarar o que ficou fora de escopo.
8. Parar quando o criterio de pronto for atingido.

## Barreira contra inflacao documental

Documento novo so entra quando for:

- normativo;
- reutilizavel;
- ligado a bug real, decisao de arquitetura ou processo recorrente;
- menor do que a confusao que remove.

Se a terceira peca de governanca estiver sendo criada para a mesma feature sem teste ou codigo observavel, pare e produza evidencia primeiro.

## Criterio de pronto

Uma entrega pode ser encerrada quando:

- o risco principal foi classificado;
- o nivel de rigor adequado foi aplicado;
- o teste ou evidencia principal esta verde;
- o DoD aplicavel foi satisfeito ou suas excecoes foram justificadas;
- nao ha refactor adjacente disfarcado de finalizacao;
- o proximo slice real esta claro.
