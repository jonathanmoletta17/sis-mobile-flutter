# Acesso Externo Controlado

## Objetivo

Definir uma estrategia aceitavel para usar o app em celular fora da intranet, sem depender de USB, `adb reverse`, IP de LAN local ou notebook de desenvolvimento como relay.

## O que esta explicitamente rejeitado

As seguintes abordagens nao fazem parte da operacao suportada deste projeto:

- bridge USB
- bridge LAN
- `adb reverse`
- proxy local rodando no notebook do desenvolvedor
- APKs apontando para `127.0.0.1`, IP privado da maquina ou porta local ad hoc

Essas abordagens podem servir para experimento de bancada, mas nao sao operacao pratica, estavel nem sustentavel para uso real em celular.

## Contrato real do app

Hoje o app conhece apenas:

- uma `GLPI_BASE_URL`
- autenticacao `initSession` com login e senha
- continuidade por `Session-Token`
- uploads multipart para os endpoints REST do GLPI

Na pratica, isso significa:

- se o caminho externo expuser a mesma API GLPI por outro hostname, o app tende a continuar funcionando sem mudanca estrutural
- se o edge exigir autenticacao adicional por cookie, browser login, desafio interativo ou token proprio, o app nao suporta isso automaticamente

## Ordem correta de decisao

Para uso real fora da intranet, a ordem recomendada e:

1. VPN institucional no celular
2. endpoint externo estavel publicado por host sempre ligado
3. relay de aplicacao proprio, se houver exigencia de autenticacao adicional no edge

## Caminho preferencial de curto prazo

Se a organizacao ja possuir VPN institucional para celular, essa e a melhor saida de curto prazo.

Vantagens:

- preserva o endpoint interno atual
- nao exige expor o GLPI para internet publica
- tende a nao exigir mudanca no app
- aproveita autenticacao e governanca ja existentes no ambiente corporativo

Implicacao pratica:

- o app continua apontando para o `GLPI_BASE_URL` interno
- o aparelho passa a alcancar a intranet por VPN

## Quando VPN nao estiver disponivel

Se nao houver VPN institucional viavel, o app so podera funcionar fora da intranet quando existir um endpoint externo controlado que:

- seja estavel
- tenha hostname fixo
- tenha TLS valido
- rode em host sempre ligado
- esteja em ambiente institucional ou equivalente
- tenha protecao e monitoracao adequadas

Sem isso, uso externo continua nao suportado.

## Desenho aceito para endpoint externo

O desenho aceito para acesso externo e:

1. um host estavel com acesso ao GLPI interno
2. um tunnel ou reverse proxy gerenciado nesse host
3. um hostname publico fixo para o app consumir
4. uma variante de configuracao do app apontando para esse hostname
5. validacao real de login, catalogo, meus chamados, detalhe, followup e anexo por esse caminho

### Requisitos tecnicos minimos do endpoint externo

Esse caminho precisa preservar:

- metodos `GET`, `POST` e `PUT`
- headers `Accept`, `Content-Type` e `Session-Token`
- uploads multipart de anexos
- downloads de documentos
- codigos de resposta da API
- estabilidade de rota para `/sis/apirest.php`

## Arquitetura recomendada para "so o app no celular"

Se o requisito for que a pessoa usuaria precise apenas do APK, sem VPN, sem app auxiliar e sem configuracao manual adicional no celular, a arquitetura recomendada passa a ser:

1. um host intermediario sempre ligado dentro do ambiente que alcanca o GLPI interno
2. um reverse proxy ou relay HTTP nesse host
3. `cloudflared` publicando um hostname publico fixo
4. o app apontando para esse hostname publico
5. o usuario final usando apenas o app

Fluxo logico:

- celular -> hostname publico -> Cloudflare Tunnel -> host intermediario -> GLPI interno

## Opcao A: pass-through rapido

Opcao mais simples para validar o modelo:

1. o host intermediario expoe um reverse proxy HTTPS interno
2. o proxy repassa `/sis/apirest.php/*` para o GLPI interno
3. `cloudflared` publica esse servico em um hostname fixo
4. o APK usa `GLPI_BASE_URL=https://hostname-publico/sis/apirest.php`

Vantagens:

- implementacao mais rapida
- menor volume de codigo novo
- tende a funcionar com poucas mudancas no app

Riscos:

- publica uma superficie maior do GLPI
- exige endurecimento no host e observabilidade melhor
- qualquer comportamento inesperado do GLPI fica mais proximo da internet

### Build do APK para a Opcao A

O app atual le `.env` como asset empacotado no build.

Isso implica:

- a URL publica precisa entrar no APK no momento do build
- nao existe troca de ambiente no aparelho depois da instalacao

Script suportado para piloto:

```powershell
.\tool\android\build_release.ps1 -GlpiBaseUrl https://hostname-publico/sis/apirest.php
```

Alternativa usando arquivo de ambiente dedicado:

```powershell
.\tool\android\build_release.ps1 -EnvFile .env.public
```

O script aplica o `.env` temporariamente durante o build e restaura o `.env` original ao final.

Playbook operacional desta opcao:

- `PILOTO_CLOUDFLARE_PASS_THROUGH.md`

## Opcao B: relay de aplicacao proprio

Opcao mais segura para piloto e producao:

1. o host intermediario roda um servico proprio
2. esse servico expoe apenas o subconjunto de rotas que o app realmente usa
3. o servico fala com o GLPI interno e devolve resposta compativel ao app
4. `cloudflared` publica apenas esse relay
5. o APK aponta para o relay publico

Subconjunto minimo hoje observado no app:

- `/initSession`
- `/killSession`
- `/getFullSession`
- `/ITILCategory`
- `/search/Ticket`
- `/Ticket`
- `/Ticket/{id}`
- `/Ticket/{id}/TicketFollowup`
- `/TicketFollowup`
- `/ITILSolution`
- `/Document`
- `/Document_Item`
- `/User/{id}`
- `/Ticket_User`

Vantagens:

- reduz superficie publicada
- facilita observabilidade, rate limit e trilha de auditoria
- permite tratar inconsistencias do GLPI sem empurrar complexidade para o app

Custos:

- requer desenvolvimento e manutencao do relay
- aumenta o trabalho inicial

## Opcao temporaria viavel

Uma opcao temporaria viavel e usar Cloudflare Tunnel (`cloudflared`) ou equivalente, desde que:

- nao rode no notebook do desenvolvedor como dependencia operacional
- publique um hostname estavel
- fique em host sempre ligado
- tenha camada de seguranca compativel com publicar um servico interno

### Diferenca operacional importante

Nao confundir:

- `tunnel_id`: UUID do tunnel no painel Cloudflare
- `TUNNEL_TOKEN`: valor longo usado por `cloudflared ... run --token ...`

Para este projeto, o host intermediario precisa do `TUNNEL_TOKEN` real.
So o UUID do tunnel nao permite subir o `cloudflared` da stack.

Tambem nao confundir as trilhas:

- `Cloudflare Tunnel` com `Published application`: atende o requisito de usar apenas o APK
- `WARP Connector` ou `private hostname`: dependem da malha WARP/Gateway no cliente e nao fecham sozinhos o caso deste app

## Importante sobre Cloudflare Access

Cloudflare Tunnel pode resolver o problema de roteamento.

Mas Cloudflare Access nao deve ser tratado como encaixe automatico neste app Flutter.

Se houver uma camada Access ou servico equivalente exigindo token adicional alem do login do GLPI, o cliente mobile precisa suportar esse contrato ou deve existir um relay proprio que trate essa autenticacao de forma compativel.

Sem esse cuidado, o tunnel resolve conectividade, mas nao necessariamente o fluxo completo do app.

Para cumprir o requisito "so o app no celular", nao assuma Access como camada transparente.
Se Access exigir cookie, login web, token adicional ou troca de credenciais no cliente, isso quebra o requisito.

## O que muda no app e o que nao muda

Nao precisa mudar no app quando:

- o aparelho entra por VPN e continua acessando o mesmo endpoint interno
- o hostname externo entrega a mesma API GLPI sem nova autenticacao no edge

Pode exigir mudanca no app quando:

- o hostname externo for diferente e precisar de variante de configuracao
- houver autenticacao adicional no edge
- houver exigencia de headers extras, cookies ou fluxo web de login

Nao e aceitavel embutir segredo permanente de edge no aplicativo como solucao padrao.

## Recomendacao pratica

Se o objetivo for colocar o APK na mao do usuario final sem exigir mais nada no celular, a melhor ordem e:

1. piloto rapido com host intermediario + pass-through controlado
2. validacao real de login, listagem, detalhe, followup, criacao e anexo
3. endurecimento para relay proprio se a exposicao direta do GLPI nao for aceitavel

Se ja houver exigencia forte de seguranca desde o inicio, pule a etapa de pass-through e comece direto pelo relay proprio.

## Linha de decisao

Se a necessidade for uso real em celular fora da intranet, a direcao correta e uma destas:

- VPN institucional mobile, quando existir
- endpoint externo controlado em host estavel
- relay proprio se a camada de seguranca exigir contrato extra

Nao reintroduzir:

- USB bridge
- LAN bridge
- `adb reverse`
- proxy de notebook

## Proximo passo recomendado

Escolher uma destas linhas:

1. validar se existe VPN institucional suportada para celular e testar o APK nesse contexto
2. publicar um endpoint externo institucional ou corporativo para o GLPI/app
3. montar um tunnel gerenciado em host estavel com hostname fixo
4. desenhar um relay de aplicacao proprio, se a camada de seguranca exigir autenticacao adicional no edge
