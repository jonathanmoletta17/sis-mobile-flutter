# Definition of Ready

## Objetivo

O DoR evita iniciar uma mudanca de dominio sem contrato minimo. Ele nao e burocracia para qualquer ajuste; e uma barreira para casos que podem afetar estado, permissao, sincronizacao ou runtime real.

Use antes de implementar feature ou correcao nao trivial.

## Quando e obrigatorio

- altera fluxo de ticket;
- altera status, solucao, followup ou anexo;
- altera papel/permissao de usuario;
- altera origem de dados, cache ou refresh;
- altera comportamento offline/online;
- altera acesso externo, `.env`, build Android ou distribuicao;
- toca mais de uma superficie relevante, como detalhe + conversa + lista.

Nao e obrigatorio para:

- typo;
- ajuste visual isolado sem regra de negocio;
- comentario interno;
- documentacao puramente explicativa.

## Template

```markdown
# DoR - <feature ou bug>

## 1. Tipo

- [ ] Feature
- [ ] Correcao de bug
- [ ] Evolucao de fluxo existente
- [ ] Ajuste operacional/runtime

## 2. Fato ou objetivo

Descrever em uma frase o fato observado ou o objetivo da entrega, sem diagnostico prematuro.

## 3. Entidades envolvidas

- Primaria:
- Secundarias:

## 4. Estados tocados

- Le:
- Altera:
- Estados invalidos que precisam ser bloqueados:

## 5. Papeis envolvidos

- Quem dispara:
- Quem e afetado:
- Existe caso tecnico-solicitante?
- Existe sessao expirada ou usuario sem permissao?

## 6. Fonte de verdade

- Origem remota:
- Origem local:
- Quando reidrata:
- Quem vence em divergencia:

## 7. Invariantes aplicaveis

Listar IDs de `docs/domain/ticket/INVARIANTS.md` ou declarar que nao se aplica.

## 8. Cenários de borda obrigatórios

1.
2.
3.

## 9. Fora de escopo

Declarar pelo menos uma coisa adjacente que nao sera resolvida nesta entrega.

## 10. Validacao planejada

- Teste unitario:
- Teste Widgetbook/visual:
- Teste Android/emulador:
- Teste API/GLPI:
- Evidencia manual:

## 11. Criterio de pronto preliminar

Uma frase objetiva indicando o que precisa estar verdadeiro para considerar a entrega pronta.
```

## Regra pratica

Se durante o DoR aparecer divergencia entre regra esperada e codigo atual, nao implementar ainda. Primeiro decidir se e bug, doc desatualizada ou regra de negocio a confirmar.
