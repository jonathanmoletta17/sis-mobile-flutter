# Definition of Done

## Objetivo

O DoD transforma "parece pronto" em uma auditoria objetiva e finita.

Ele deve ser usado antes de declarar concluida qualquer entrega que toque dominio, runtime, Android, acesso externo ou multiplas telas.

## Niveis de validacao

Nem toda entrega exige todos os niveis. Entregas de leitura podem parar antes de runtime Android; entregas de transicao de ticket normalmente exigem todos os niveis aplicaveis.

### Nivel 1 - Fluxo feliz

- [ ] O caminho esperado funciona no app.
- [ ] A resposta do GLPI/API e coerente.
- [ ] A UI reflete o resultado sem exigir truque manual.

### Nivel 2 - Estados invalidos bloqueados na UI

- [ ] Acoes invalidas nao aparecem ou ficam indisponiveis.
- [ ] `Solucionado` e `Fechado` nao expõem botoes tecnicos comuns.
- [ ] Estado de carregamento nao permite clique antes da decisao.

### Nivel 3 - Guarda de execucao

- [ ] A funcao que executa a acao revalida estado/papel quando aplicavel.
- [ ] A UI nao e a unica barreira.
- [ ] Erro do GLPI nao deixa estado local mentiroso.

### Nivel 4 - Estado obsoleto

- [ ] Tela aberta antes de uma mudanca remota nao consegue executar acao invalida.
- [ ] O ticket e reidratado ao voltar para detalhe/conversa quando a mudanca afetar estado.
- [ ] Existe teste ou reproducao manual desse caminho.

### Nivel 5 - Sincronizacao entre superficies

- [ ] Lista, detalhe e conversa convergem para o mesmo status.
- [ ] Apos acao de status/solucao/mensagem/anexo, superficies afetadas foram recarregadas ou invalidadas.
- [ ] Reabrir o app mostra o mesmo estado observado no GLPI.

### Nivel 6 - Papeis e permissoes

- [ ] Solicitante foi testado.
- [ ] Tecnico foi testado quando aplicavel.
- [ ] Tecnico-solicitante foi testado quando aplicavel.
- [ ] Sessao invalida ou expirada foi considerada.

### Nivel 7 - Erros e rejeicoes

- [ ] Erro de rede mostra mensagem util.
- [ ] Erro de regra do GLPI mostra mensagem util.
- [ ] Loading termina mesmo em falha.
- [ ] O estado local volta ao ultimo estado remoto confiavel.

### Nivel 8 - Idempotencia e concorrencia

- [ ] Clique duplo nao executa duas mutacoes.
- [ ] A mesma acao nao duplica efeito por dois caminhos.
- [ ] Mudanca por outra sessao entre load e clique aborta a acao ou recarrega a tela.

### Nivel 9 - Evidencia registrada

- [ ] Comandos executados foram registrados.
- [ ] Screenshots, UI tree ou logs foram salvos quando houve teste manual.
- [ ] Ticket de teste ou massa usada foi identificado sem expor segredo.

### Nivel 10 - Documentacao atualizada

- [ ] `docs/domain/ticket/STATES.md` atualizado se houve estado novo.
- [ ] `docs/domain/ticket/TRANSITIONS.md` atualizado se houve transicao/papel novo.
- [ ] `docs/domain/ticket/INVARIANTS.md` atualizado se houve invariante novo.
- [ ] `docs/domain/ticket/SOURCES_OF_TRUTH.md` atualizado se mudou origem/cache/refresh.
- [ ] Autopsia ou plano de regressao atualizado quando a mudanca veio de bug real.

## Gates por tipo de mudanca

### Codigo Flutter

```bash
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

### Widgetbook ou visual

```bash
cd widgetbook
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Quando houver alteracao visual relevante, validar tambem o workbench/goldens conforme `docs/WIDGETBOOK_WORKBENCH.md`.

### Android/runtime

Usar a camada Windows host quando a validacao envolve Android SDK, emulator, `adb` ou build Android. A WSL continua sendo a raiz canonica de fonte, nao precisa virar ambiente Android completo.

### Documentacao pura

```bash
git diff --check
git status --ignored --short
```

Tambem revisar coerencia entre:

- `README.md`;
- `docs/README.md`;
- `docs/RUNTIME_CANONICO_E_VALIDACAO.md`.

## Criterio de pronto

Uma entrega pode ser chamada de pronta quando:

- os niveis aplicaveis estao verdes;
- os niveis nao aplicaveis foram justificados;
- pendencias reais foram registradas como proximo slice, nao escondidas;
- nao ha refactor adjacente entrando como fuga da validacao.
