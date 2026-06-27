# Plano de Testes - Outbox Offline Flutter/Drift

## Escopo

Validar persistencia, ordenacao, isolamento, staging de anexos, migracao e
tratamento de resultado remoto ambiguo. Este plano nao afirma que Drift ja esta
integrado.

## Persistencia e dependencias

### CT-F01 - Operation ID persistido antes do envio

- Criar uma acao offline.
- Esperado: UUID salvo antes de qualquer tentativa e reutilizado em todos os
  replays.

### CT-F02 - Cadeia linear

- Criar ticket A, followup B e anexo C offline.
- Esperado: `B.depends_on = A.id`, `C.depends_on = B.id`; sincronizacao segue
  essa ordem.

### CT-F03 - Dependencia terminal

- A sincroniza e B recebe `422`.
- Esperado: B vira `failed_terminal`; C vira `blocked_dependency`; A permanece
  `synced`.

### CT-F04 - Crash transacional

- Interromper a transacao que insere acao e dependencias.
- Esperado: rollback completo, sem linha orfa.

### CT-F05 - Reinicio durante processing

- Encerrar o App depois do dispatch e antes da resposta.
- Esperado: a acao e reaberta como `reconciling`/`remote_unknown`, nunca como
  novo envio automatico.

## Anexos

### CT-F06 - Promocao valida

- Gravar staging, reiniciar, validar existencia, tamanho e SHA-256.
- Esperado: copiar para storage persistente e preencher `committed_blob_ref`.

### CT-F07 - Staging corrompido

- Alterar bytes ou tamanho.
- Esperado: `blob_lost`, sem upload parcial.

### CT-F08 - Destinos

- Cobrir Ticket, ITILFollowup e ITILSolution.
- Esperado: item type e target ID preservados apos reinicio e sincronizacao.

### CT-F09 - PWA offline

- Tentar anexar sem conectividade no PWA.
- Esperado: controle desabilitado com motivo; nenhuma referencia descartavel e
  gravada na outbox.

## Isolamento e seguranca

### CT-F10 - Troca de usuario

- Usuario A possui pendencias; sair e entrar como B.
- Esperado: B nao lista nem sincroniza a fila de A.

### CT-F11 - Retorno do usuario original

- Entrar novamente como A.
- Esperado: pendencias voltam a ficar elegiveis sem recriacao de IDs.

### CT-F12 - Descarte autorizado

- Operador autorizado descarta `remote_unknown`.
- Esperado: `discarded_human`, com autor, data e justificativa obrigatorios.

## Migracao

### CT-F13 - Migracao unica

- Preparar cinco tickets legados em SharedPreferences.
- Esperado: inserir no Drift, criar marker por ambiente/servico/usuario/entidade
  e nao fazer dual-write.

### CT-F14 - Reinicio apos migracao

- Reiniciar o App mantendo a fila legada.
- Esperado: marker impede nova importacao.

### CT-F15 - Falha parcial na migracao

- Interromper antes do commit.
- Esperado: transacao reverte; nova tentativa nao duplica itens.

## Criterio de saida

- Testes executados em Android e Web para as superficies suportadas.
- Nenhuma acao de outro usuario e sincronizada.
- UNKNOWN nunca gera novo operation ID automaticamente.
- Arquivos comprometidos sobrevivem a reinicio e limpeza de cache normal.
