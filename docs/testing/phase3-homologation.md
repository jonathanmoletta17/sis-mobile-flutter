# Plano de Homologacao da Fase 3

## Status

Plano futuro. Nao autoriza mutacoes no GLPI SIS de producao.

## Ambiente obrigatorio

- GLPI de homologacao/sandbox isolado da fila SIS original.
- Mesma versao e plugins relevantes da producao.
- Worker staging separado.
- Usuarios sinteticos com perfis requerente e tecnico.
- Prefixo unico nos dados: `SIS-MOBILE-HML-<data>-<execucao>`.
- Limite de dois tickets sinteticos por execucao completa.

Se qualquer requisito estiver ausente, executar somente testes locais com fake
GLPI e encerrar antes de mutacoes.

## Criterios de parada

- Duas criacoes de ticket foram atingidas.
- Uma operacao fica `UNKNOWN` sem explicacao.
- O Worker aceita mutacao sem version/session/operation ID.
- O proxy permite acesso cruzado.
- O ambiente deixa de ser comprovadamente homologacao.

Nao executar DELETE, purge ou limpeza automatizada.

## Roteiro

### Etapa 1 - Read-only

1. Confirmar identidade do ambiente.
2. Validar snapshot, ETag, entidades, categorias, status e FormCreator.
3. Comparar capabilities com perfil, entidade e ticket no GLPI Web.

### Etapa 2 - Ticket sintetico HML-1, fluxo online

1. Criar um ticket pelo App.
2. Confirmar no GLPI Web o mesmo operation ID/correlacao disponivel na
   observabilidade do Worker.
3. Adicionar followup e assumir o ticket.
4. Enviar imagem, PDF e video pequeno para os destinos suportados.
5. Abrir cada anexo no APK e no PWA.
6. Confirmar no GLPI Web os Document_Item e itens pais.
7. Alterar status e validar read-back.

### Etapa 3 - Ticket sintetico HML-2, fluxo offline

1. Ficar offline no App.
2. Criar ticket, followup e anexo.
3. Reiniciar o App ainda offline e conferir a mesma cadeia/operation IDs.
4. Voltar online e sincronizar uma unica vez.
5. Confirmar no GLPI Web ausencia de duplicidade observada.

### Etapa 4 - Falhas controladas

Usar fake GLPI/Worker staging para timeout ambiguo; nao provocar incerteza
deliberada no GLPI real de homologacao.

1. Produzir resultado ambiguo apos dispatch.
2. Confirmar `remote_unknown`.
3. Repetir a mesma operacao e provar que a reconciliacao e read-only.
4. Confirmar que create/followup sem marcador unico permanecem UNKNOWN.
5. Alterar um ticket no GLPI Web antes de mutacao com `ticket_date_mod` antigo.
6. Esperado: `409 STATE_CONFLICT` e `failed_terminal`, nunca
   `remote_unknown` por conflito conhecido.

### Etapa 5 - Proxy e plataforma

1. Testar acesso direto, por followup e por solucao.
2. Forcar document item de outro ticket e exigir `403`.
3. Validar nome, MIME, PDF, imagem, video e Range quando upstream responder
   `206`.
4. No PWA offline, confirmar que o upload fica bloqueado antes de selecionar ou
   perder arquivo.

### Etapa 6 - Versao minima

1. Ativar min app version apenas no Worker staging.
2. Validar `426` para versao ausente e inferior em rotas novas e legadas
   mutaveis.
3. Restaurar a flag de staging ao final; nao alterar producao.

## Go/No-Go

- No maximo dois tickets sinteticos criados.
- Nenhuma duplicidade observada nos cenarios controlados.
- UNKNOWN nunca foi reenviado automaticamente.
- Nenhuma URL interna ou secret vazou nos responses/logs.
- APK e PWA abriram imagem, PDF e video suportado.
- Migracao preservou todas as pendencias do dataset sintetico.
- Evidencias incluem App, Worker e confirmacao no GLPI Web de homologacao.

Falha em qualquer item mantem a Fase 3 em no-go.
