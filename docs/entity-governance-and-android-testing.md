# SIS Mobile - entidade do usuario e teste Android

## Objetivo

Este documento consolida duas coisas que precisam ficar objetivas:

- como a entidade deve governar as acoes do usuario
- como testar a aplicacao Android na pratica, sem ambiguidade

## Regra de entidade

### Fonte da verdade

A entidade usada para abrir chamados nao pode depender de suposicao do GLPI ou da sessao do momento.

Ela precisa seguir esta ordem:

1. o app autentica no GLPI
2. o app carrega o contexto da sessao
3. o usuario escolhe a entidade operacional na UI
4. essa entidade fica salva no estado local
5. toda criacao de chamado usa explicitamente esse `entities_id`
6. se o chamado cair offline, o ticket pendente preserva a mesma entidade
7. quando sincronizar depois, usa a entidade original do ticket offline

### Regra operacional

- online: o payload do ticket deve enviar `entities_id`
- offline: o ticket salvo localmente deve guardar `entities_id`
- sincronizacao: o ticket offline sincronizado deve reutilizar o mesmo `entities_id`
- leitura: a entidade ativa precisa ficar visivel para o usuario na UI

### O que isso evita

- chamado abrindo sempre na entidade padrao
- chamado abrindo na entidade da sessao atual, e nao na entidade escolhida
- chamado offline sincronizando depois em entidade errada

## Estado atual validado

Foi validado com GLPI real:

- login real
- escolha de entidade na UI
- criacao online com `entities_id` explicito
- criacao offline preservando a entidade
- sincronizacao offline reutilizando a entidade original

Casos confirmados em runtime:

- ticket `7930` criado online com `entities_id = 24`
- ticket `7931` criado offline e sincronizado depois com `entities_id = 24`

## APKs geradas nesta rodada

### APK release para teste manual

Arquivo:

- `C:\Users\jonathan-moletta\Downloads\sis-mobile-release.apk`

Uso:

- instalar no celular
- fazer login manual
- usar em teste real

### APK debug limpa para teste manual

Arquivo:

- `C:\Users\jonathan-moletta\Downloads\sis-mobile-debug-manual.apk`

Uso:

- instalar no emulador ou celular
- fazer login manual
- usada para debug local

## Importante sobre a build de QA

Durante a validacao automatizada foi usada uma build debug temporaria com `dart-define` para auto-login.

Ela nao deve ser distribuida.

Por seguranca, o artefato recomendado para teste humano nesta maquina e:

- release manual
- debug manual limpa

## Pre-condicao de rede

O GLPI da SIS esta em ambiente interno:

- `http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`

Entao o teste real so funciona se o aparelho tiver acesso a essa rede:

- rede interna
- ou VPN corporativa

Sem isso:

- o app instala
- a UI abre
- mas login e operacoes online nao vao responder

## Roteiro de teste no celular

1. Instalar `sis-mobile-release.apk`
2. Garantir acesso de rede ao GLPI interno
3. Abrir o app
4. Fazer login com conta real
5. Abrir a drawer e conferir a entidade selecionada
6. Abrir `Servicos`
7. Abrir um formulario, por exemplo `Carregadores`
8. Criar um chamado com assunto facil de localizar
9. Abrir `Meus Chamados`
10. Confirmar que o chamado aparece
11. Abrir o detalhe
12. Enviar um followup curto
13. Se desejar, anexar arquivo

## Roteiro de teste da regra de entidade

1. Selecionar explicitamente uma entidade diferente da padrao
2. Criar um chamado novo
3. Localizar o chamado no GLPI
4. Confirmar que o ticket ficou com a mesma entidade escolhida

### Validacao offline

1. Selecionar a entidade desejada
2. Desligar a conectividade do emulador/aparelho
3. Criar o chamado
4. Confirmar que o app salvou offline
5. Restaurar a conectividade
6. Reabrir o app
7. Confirmar que a sincronizacao criou o ticket na mesma entidade

## O que observar durante o teste

- a entidade exibida na UI bate com a entidade esperada
- o chamado criado aparece no GLPI
- followup aparece depois do envio
- anexo aparece no chamado, quando usado
- quando offline, o ticket nao se perde
- quando voltar a conexao, ele sincroniza sem trocar de entidade

## Limites conhecidos

O nucleo critico esta validado, mas ainda existem limites conhecidos:

- formularios continuam estaticos, nao vindos da API
- categoria e localizacao dependem da taxonomia local do app
- ainda existe mojibake residual em comentarios e alguns logs internos

## Leitura final

Hoje a SIS ja pode ser testada de forma pratica e objetiva.

O ponto mais critico, que era a entidade online/offline, foi endurecido:

- entidade escolhida na UI
- entidade persistida no estado
- entidade enviada no payload
- entidade preservada no offline
- entidade reaplicada na sincronizacao
