# Template de Autopsia de Bug

## Objetivo

Este template deve ser usado para bugs de dominio, estado, permissao, sincronizacao ou divergencia entre telas.

Ele formaliza o protocolo:

FATO OBSERVADO -> HIPOTESES -> EVIDENCIAS -> CAUSA RAIZ PROVAVEL -> CORRECAO MINIMA -> APRENDIZADO DE PROCESSO.

## Quando usar

- ticket fechado aceitou tentativa de acao;
- tela antiga mostra estado diferente da conversa/lista;
- usuario ve acao que seu papel nao deveria ver;
- ID aparece onde nome humano deveria aparecer;
- GLPI aceita ou rejeita mutacao de forma inesperada;
- bug reaparece em outro caminho.

Para bugs pequenos e localizados, use `docs/AUTOPSIA_RAPIDA.md`.
Para divergencias sistemicas, use `docs/AUTOPSIA_COMPLETA.md`.

## Template

```markdown
# Autopsia - <titulo curto>

## 1. Fato observado

Descrever a sequencia exatamente como aconteceu, sem diagnostico.

## 2. Contexto

- Data:
- Ambiente:
- APK/build:
- Usuario:
- Perfil:
- Ticket de teste:
- Endpoint:

## 3. Linha do tempo

| Ponto | Ator | Acao | Estado antes | Estado depois | Observado em |
| --- | --- | --- | --- | --- | --- |
| T0 | | | | | |

## 4. Hipoteses

| ID | Hipotese | Confianca inicial | Evidencia que validaria | Evidencia que refutaria |
| --- | --- | --- | --- | --- |
| H1 | | baixa/media/alta | | |

## 5. Evidencia coletada

| Evidencia | Origem | Resultado | Hipotese afetada |
| --- | --- | --- | --- |
| | | | |

## 6. Classificacao provisoria

- [ ] bug local;
- [ ] sincronizacao;
- [ ] interpretacao errada de regra;
- [ ] ausencia de guarda;
- [ ] duplicacao de regra;
- [ ] falha sistemica real;
- [ ] regra GLPI a confirmar.

## 7. Causa raiz provavel

Formular em uma frase.

Confianca: baixa/media/alta.

Evidencias principais:

-

Hipoteses descartadas:

-

## 8. Correcao minima proposta

Menor intervencao suficiente para eliminar o risco observado.

## 9. Validacao da correcao

- Testes automatizados:
- Teste manual:
- Estado GLPI antes/depois:
- Evidencia visual/log:

## 10. Aprendizado de processo

- Por que passou?
- Qual teste faltou?
- Qual invariante nasce ou muda?
- Qual doc/checklist precisa mudar?
- O que fica fora de escopo?
```

## Anti-padroes

- assumir cache, arquitetura ou backend sem evidencia;
- corrigir antes de registrar fato observado;
- transformar bug local em refactor amplo sem provar duplicacao;
- aceitar "nao consegui reproduzir" como conclusao sem capturar o que foi tentado;
- expor credenciais em evidencia.
