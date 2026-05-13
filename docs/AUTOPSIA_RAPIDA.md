# Autopsia rapida

## Quando usar

Use este protocolo para bugs localizados, sem risco imediato de perda de dados, sem impacto em multiplas telas e sem suspeita forte de inconsistencia entre app e GLPI.

Exemplos:

- texto errado;
- botao aparecendo em lugar incorreto;
- estado visual inconsistente, mas sem mutacao remota;
- falha que parece restrita a uma tela.

Se durante a investigacao aparecer divergencia entre UI, API e estado remoto, promova para `AUTOPSIA_COMPLETA.md`.

## Postura epistemologica

- Fato observado nao e diagnostico.
- Toda hipotese deve declarar confianca: alta, media ou baixa.
- Nao propor refactor, nova camada ou abstracao antes de evidencia concreta.
- Preferir correcao minima validada.
- Se a correcao local resolver o risco observado, nao continuar investigando por perfeccionismo.

## Classificacao inicial

Antes de corrigir, classificar o caso como uma destas categorias:

- bug local;
- sincronizacao;
- interpretacao errada da regra;
- ausencia de guarda;
- duplicacao de regra;
- falha sistemica real.

Se a categoria provavel for sincronizacao, permissao, divergencia UI/API ou falha sistemica real, usar `AUTOPSIA_COMPLETA.md`.

## Timebox

- Reproducao: 20 min
- Leitura do codigo envolvido: 20 min
- Hipotese e correcao minima: 20 min
- Validacao da correcao: 20 min

Tempo total recomendado: ate 80 min.

## Protocolo

1. Registrar fato observado em uma frase.
2. Reproduzir uma vez.
3. Capturar screenshot ou UI tree, se for bug visual.
4. Localizar arquivo e funcao provaveis.
5. Formular no maximo 3 hipoteses, cada uma com nivel de confianca.
6. Registrar a evidencia que validaria ou refutaria cada hipotese.
7. Escolher a correcao minima somente depois da evidencia suficiente.
8. Validar com teste focado ou reproducao manual.
9. Registrar aprendizado para processo.

## Evidencia minima

- caminho da tela;
- acao executada;
- comportamento esperado;
- comportamento observado;
- arquivo/funcao provavel;
- hipotese escolhida e confianca;
- validacao executada.

## Criterio de stop

Encerrar a autopsia rapida quando:

- a causa raiz estiver pelo menos 80% provavel;
- a correcao minima tiver sido validada;
- nao houver sinal de divergencia entre UI, API e estado remoto.

Se uma dessas condicoes falhar, promover para autopsia completa.

## Aprendizado para processo

Obrigatorio registrar ao final:

- qual pergunta teria revelado o bug antes;
- qual teste deve existir daqui para frente;
- se o caso vira checklist, teste automatizado ou apenas anotacao.
