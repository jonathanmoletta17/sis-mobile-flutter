# Autopsia completa

## Quando usar

Use este protocolo para bugs com suspeita de inconsistencia sistemica:

- estado remoto diferente da UI;
- transicao invalida aceita;
- cache ou refresh suspeito;
- permissao ou papel incorreto;
- acao critica executada a partir de tela obsoleta;
- perda, duplicacao ou mutacao indevida de dados;
- divergencia entre detalhe, conversa, lista e GLPI.

Este protocolo e investigativo. Ele deve produzir evidencia antes de propor arquitetura.

## Postura epistemologica

- Nunca converter comportamento observado em diagnostico fechado.
- Separar obrigatoriamente fato, hipotese, evidencia, causa raiz provavel, correcao minima e aprendizado.
- Toda inferencia deve declarar confianca: alta, media ou baixa.
- Nao introduzir estados, fluxos, regras ou componentes nao confirmados sem marca-los como hipotese.
- Nao propor abstracao, refactor estrutural ou nova camada antes de provar:
  - evidencia concreta;
  - por que a correcao local nao basta;
  - custo introduzido pela nova estrutura.
- Evidencia vem antes de arquitetura.

## Classificacao inicial

Classificar o problema antes de corrigir:

- bug local;
- sincronizacao;
- interpretacao errada da regra;
- ausencia de guarda;
- duplicacao de regra;
- falha sistemica real.

A classificacao tambem e hipotese. Ela pode mudar durante a investigacao.

## Timebox

- Reproducao controlada: 20 min
- Captura de estado remoto e UI: 30 min
- Leitura/instrumentacao do codigo: 30 min
- Decisao de causa raiz provavel: 15 min
- Correcao minima e validacao focada: 45 min

Tempo total recomendado: ate 140 min.

Se o caso ultrapassar o timebox, registrar a melhor hipotese com confianca estimada e decidir entre:

- aplicar correcao minima;
- instrumentar e retestar;
- abrir nova etapa de investigacao.

## Etapas obrigatorias

### Etapa 1 - Observacao

Reconstruir exatamente o comportamento sem concluir causa.

Saida esperada:

- fato observado;
- linha do tempo;
- superficie envolvida;
- comportamento esperado;
- comportamento observado.

### Etapa 2 - Hipoteses

Listar hipoteses plausiveis com confianca alta, media ou baixa.

Considerar explicitamente se o problema pode ser:

- bug local;
- sincronizacao;
- interpretacao errada de regra;
- ausencia de guarda;
- duplicacao de regra;
- falha sistemica real.

### Etapa 3 - Evidencia faltante

Definir o que precisa ser observado para validar ou refutar cada hipotese.

### Etapa 4 - Investigacao guiada

Executar reproducao tecnica com captura de UI, estado remoto, resposta de API e logs quando aplicavel.

### Etapa 5 - Conclusao provisoria

Formular causa raiz provavel com nivel de confianca.

### Etapa 6 - Correcao minima

Propor e aplicar a menor intervencao suficiente para eliminar o risco observado.

### Etapa 7 - Extracao metodologica

Registrar:

- por que isso passou;
- qual teste faltou;
- qual invariante nasce disso;
- o que muda no processo.

## Sequencia operacional

1. Separar fato observado de hipotese.
2. Criar ou escolher massa de teste controlada.
3. Capturar estado remoto antes da acao.
4. Capturar UI antes da acao.
5. Executar uma unica acao.
6. Capturar resposta da API ou ausencia comprovada de chamada.
7. Capturar estado remoto depois da acao.
8. Capturar UI depois da acao.
9. Mapear origem dos dados por tela/camada.
10. Formular causa raiz provavel.
11. Aplicar correcao minima.
12. Validar o caminho feliz e o caminho invalido.
13. Registrar aprendizado para processo.

Para registrar a autopsia em arquivo duravel, use o modelo em `docs/quality/BUG_AUTOPSY_TEMPLATE.md`.

## Barreira contra overengineering

Antes de criar nova abstracao, classe de politica, cache central, state machine ou refactor estrutural, responder:

- qual evidencia mostra que uma correcao local nao basta?
- quantos pontos de duplicacao real existem?
- qual bug recorreria sem a abstracao?
- qual custo de manutencao a nova estrutura introduz?

Se essas perguntas nao tiverem resposta concreta, aplicar correcao minima local e registrar a decisao.

## Evidencia obrigatoria

- ticket/entidade de teste usada;
- usuario e papel envolvido;
- endpoint usado;
- estado remoto antes/depois;
- UI antes/depois;
- funcao que exibiu a acao;
- funcao que executou a acao;
- resposta da API, quando houver;
- hipoteses avaliadas com confianca;
- conclusao com nivel de confianca.

## Criterio de stop

Encerrar a autopsia completa quando:

- a causa raiz estiver pelo menos 80% provavel;
- a correcao minima tiver sido validada contra o bug observado;
- nao houver outra hipotese restante com risco maior que a causa escolhida;
- o aprendizado para processo tiver sido registrado.

Nao continuar investigando apenas para obter certeza absoluta se a correcao minima ja elimina o risco operacional observado.

## Aprendizado para processo

Obrigatorio registrar ao final:

- qual invariante foi quebrada;
- qual pergunta de validacao faltou;
- qual teste automatizado deve cobrir o caso;
- qual evidencia manual deve ser capturada em casos semelhantes;
- se a regra precisa entrar em checklist, matriz de estados ou documentacao de arquitetura.
