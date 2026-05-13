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

Para uso real fora da intranet, a decisao depende do requisito operacional:

1. desenvolvimento interno ou validacao controlada pode usar intranet/VPN institucional
2. distribuicao para usuarios finais com "somente o APK" nao deve exigir VPN por aparelho
3. primeira fase sem dominio proprio: Cloudflare Worker em `workers.dev` + Workers VPC + Tunnel
4. quando houver dominio institucional controlado: hostname proprio via Cloudflare Tunnel ou rota equivalente
5. se houver exigencia de autenticacao adicional no edge: relay de aplicacao proprio

## Caminho preferencial para "somente o APK"

Se o requisito for evitar VPN em cada celular, o caminho preferencial deste projeto passa a ser:

- Cloudflare Worker publicado em `workers.dev`
- Workers VPC Service apontando para o GLPI interno
- Cloudflare Tunnel outbound rodando em host institucional sempre ligado
- APK apontando `GLPI_BASE_URL` para o Worker

Vantagens:

- nao exige instalar VPN em cada aparelho
- nao exige comprar dominio nem trocar nameservers
- nao move a fonte canonica WSL para Windows
- mantem o GLPI sem porta inbound publica direta
- fornece URL HTTPS publica e estavel para o APK dentro da conta Cloudflare

Detalhamento operacional:

- `ACESSO_EXTERNO_WORKERS_VPC.md`

## Caminho por VPN

VPN institucional mobile continua valida para desenvolvimento, suporte ou grupos pequenos quando a organizacao ja possui esse fluxo operacional.

Ela nao deve ser tratada como primeira fase para distribuicao ampla do APK, porque exige configuracao por aparelho e aumenta o suporte operacional fora do app.

## Quando VPN por usuario nao for viavel

Se VPN por usuario nao for viavel, o app so podera funcionar fora da intranet quando existir um endpoint externo controlado que:

- seja estavel
- tenha hostname fixo
- tenha TLS valido
- rode em host sempre ligado
- esteja em ambiente institucional ou equivalente
- tenha protecao e monitoracao adequadas

Sem isso, uso externo continua nao suportado.

Na primeira fase sem dominio proprio, o hostname fixo pode ser o `workers.dev` do Worker da conta Cloudflare. Dominio proprio e nameserver Cloudflare nao sao requisitos para essa fase.

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

Se a pessoa usuaria deve usar apenas o APK, sem VPN, sem app auxiliar e sem configuracao manual adicional no celular, a arquitetura recomendada agora e:

1. um Cloudflare Worker publico em `workers.dev`
2. um Workers VPC Service para o GLPI interno
3. um Cloudflare Tunnel outbound a partir de host institucional com acesso ao GLPI
4. o app apontando para a URL do Worker
5. o usuario final usando apenas o app

Fluxo logico:

- celular -> Worker `workers.dev` -> Workers VPC -> Cloudflare Tunnel -> host interno -> GLPI interno

Esse desenho evita a etapa de ativar dominio no painel Cloudflare. A tela `Connect your domain` so e necessaria quando o projeto decidir usar um hostname proprio como `sis-glpi.seu-dominio`.

## Opcao A: Workers VPC + Worker em `workers.dev`

Opcao preferencial para a primeira fase sem VPN por aparelho e sem dominio proprio.

Playbook operacional:

- `ACESSO_EXTERNO_WORKERS_VPC.md`

Contrato esperado para o app:

- `GLPI_BASE_URL=https://sis-glpi.<subdominio-da-conta>.workers.dev/sis/apirest.php`
- `initSession` retorna `session_token`
- `getFullSession` e `killSession` funcionam pelo mesmo hostname
- upload/download e followup preservam metodos, headers e multipart

## Opcao B: pass-through rapido com hostname proprio

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

### Build do APK para a Opcao B

O app atual le `.env` como asset empacotado no build.

Isso implica:

- a URL publica precisa entrar no APK no momento do build
- nao existe troca de ambiente no aparelho depois da instalacao

Script suportado para piloto com hostname proprio:

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

Essa opcao exige dominio ou hostname controlado fora de `workers.dev`. Nao e mais a primeira escolha quando o bloqueio principal e evitar compra/delegacao de dominio.

## Opcao C: relay de aplicacao proprio

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
- `/ITILSolution/{id}`
- `/Document`
- `/Document_Item`
- `/Ticket/{id}/Document`
- `/ITILFollowup/{id}/Document`
- `/ITILSolution/{id}/Document`
- `/User/{id}`
- `/Ticket_User`

Na linha DTIC, esse mesmo subconjunto deve passar pelo Worker DTIC com
`App-Token` injetado apenas no servidor. Acoes de ticket usam guarda propria
(`ALLOW_TICKET_ACTIONS`) e submissao FormCreator usa guarda separada
(`ALLOW_FORMCREATOR_SUBMISSION`). Para DTIC, `POST /Ticket` direto nao deve ser
tratado como abertura canonica; a abertura precisa preservar o FormCreator.

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

1. piloto com Worker `workers.dev` + Workers VPC + Tunnel
2. validacao real de login, listagem, detalhe, followup, criacao e anexo
3. endurecimento para relay proprio se a exposicao pass-through do GLPI nao for aceitavel
4. migrar para hostname institucional proprio apenas quando houver dominio e governanca DNS disponiveis

Se ja houver exigencia forte de seguranca desde o inicio, pule a etapa de pass-through e comece direto pelo relay proprio.

## Linha de decisao

Se a necessidade for uso real em celular fora da intranet, a direcao correta e uma destas:

- Worker `workers.dev` + Workers VPC + Tunnel para "somente o APK" sem dominio proprio
- VPN institucional mobile para desenvolvimento, suporte ou grupos controlados
- endpoint externo controlado em host estavel quando houver dominio/hostname institucional
- relay proprio se a camada de seguranca exigir contrato extra

Nao reintroduzir:

- USB bridge
- LAN bridge
- `adb reverse`
- proxy de notebook

## Proximo passo recomendado

Escolher uma destas linhas:

1. criar o caminho Worker `workers.dev` + Workers VPC + Tunnel
2. validar `initSession`, `getFullSession` e `killSession` pelo Worker
3. gerar APK com `GLPI_BASE_URL` do Worker
4. validar login real em celular fora da intranet sem VPN
5. desenhar um relay de aplicacao proprio, se a camada de seguranca exigir autenticacao adicional no edge
