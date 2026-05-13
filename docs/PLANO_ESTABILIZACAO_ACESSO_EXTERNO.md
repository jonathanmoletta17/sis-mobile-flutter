# Plano de Estabilizacao do Acesso Externo

## Objetivo

Transformar o piloto de acesso externo do `sis-mobile-flutter` em uma operacao estavel para celular fora da intranet, sem depender de USB, LAN, notebook de desenvolvimento ou quick tunnel efemero.

## Atualizacao de decisao

O plano abaixo registra a trilha com hostname proprio/named tunnel e continua util quando houver dominio ou zona DNS controlada.

Para a primeira fase sem custos adicionais de dominio e sem VPN por aparelho, a decisao atual do projeto e:

- Cloudflare Worker em `workers.dev`
- Workers VPC Service
- Cloudflare Tunnel outbound

Documento operacional:

- `ACESSO_EXTERNO_WORKERS_VPC.md`

## Estado comprovado nesta maquina

### O que ja foi provado

- o proxy local `sis-pass-through` responde em `http://127.0.0.1:28180/healthz`
- o fluxo autenticado pelo pass-through local foi validado com:
  - `initSession`
  - `getFullSession`
  - `killSession`
- um quick tunnel Cloudflare foi validado de ponta a ponta como prova tecnica de conectividade publica
- um APK release foi gerado apontando para essa URL publica temporaria

### O que isso significa

- o app funciona fora da rede interna quando existe um hostname publico que entrega a mesma API GLPI
- o bloqueio principal nao e mais o app Flutter
- o bloqueio principal agora e operacional:
  - hostname fixo
  - tunnel nomeado
  - host permanente
  - observabilidade minima

## O que ainda nao esta resolvido

### Bloqueios reais do plano com dominio proprio

1. o hostname publico atual e de quick tunnel
   - serve para prova
   - nao serve para distribuicao duravel
2. `tool\external-access\pass-through\.env.host` ainda nao tem `CLOUDFLARE_TUNNEL_TOKEN`
3. o valor de `PUBLIC_HOSTNAME` ainda nao aponta para um dominio institucional ou controlado
4. ainda nao houve smoke test final em aparelho fisico fora da rede usando o hostname estavel
5. a exposicao atual continua sendo pass-through direto para o GLPI

### Bloqueio comprovado nesta rodada do plano com dominio proprio

Foi validado que o token de API testado:

- e valido no endpoint `user/tokens/verify`
- usa o IP publico correto desta maquina
- mas falha com `code 9109` ao acessar a conta informada

Implicacao:

- o bloqueio atual nao e filtro de IP
- o bloqueio atual e permissao insuficiente ou `account_id` incorreto para operacao de Tunnel/DNS

### Esclarecimento importante sobre o painel

Se o recurso criado no painel estiver na trilha `WARP Connector`, isso nao fecha sozinho o caso deste app.

O requisito aqui e:

- usuario final fora da intranet
- sem cliente WARP adicional no celular
- apenas o APK consumindo um hostname HTTP publico

Para a trilha com dominio proprio, o caminho Cloudflare seria:

- `Cloudflare Tunnel`
- `Published application`
- `hostname publico`
- `cloudflared ... run --token <TUNNEL_TOKEN>`

Private hostname e WARP Connector pertencem a uma topologia diferente, voltada a malha privada e conectividade via WARP/Gateway.

### Decisao tecnica

- curto prazo sem dominio proprio: Worker `workers.dev` + Workers VPC + Tunnel
- curto prazo com dominio controlado: named tunnel + hostname controlado + pass-through
- medio prazo mais seguro: relay proprio de aplicacao

## Plano por fases

### Fase 0 - concluida

1. validar proxy local
2. provar conectividade publica com tunnel
3. gerar APK release com URL publica

### Fase 1A - estabilizacao sem dominio proprio

1. configurar o subdominio `workers.dev` da conta Cloudflare
2. criar o Tunnel na trilha Workers VPC
3. instalar e executar `cloudflared` em host institucional com acesso ao GLPI interno
4. criar VPC Service para `cau.ppiratini.intra.rs.gov.br:80` ou IP interno equivalente
5. criar Worker `sis-glpi` com binding do VPC Service
6. validar:

```powershell
curl -v https://sis-glpi.<subdominio-da-conta>.workers.dev/sis/apirest.php/initSession -H "Content-Type: application/json" -u USUARIO:SENHA
```

7. gerar `.env.public` local, nao versionado, apontando para:

```env
GLPI_BASE_URL=https://sis-glpi.<subdominio-da-conta>.workers.dev/sis/apirest.php
GLPI_DEBUG_LOGS=false
```

8. buildar o APK pelo fluxo oficial no Windows host:

```powershell
.\tool\android\build_release.ps1 -EnvFile .env.public
```

9. instalar no celular fora da intranet e executar smoke test sem VPN

### Fase 1B - estabilizacao com dominio proprio

1. criar ou selecionar um hostname fixo sob controle
   - exemplo: `sis-mobile.<dominio-controlado>`
2. criar ou selecionar um named tunnel no Cloudflare
3. obter o `CLOUDFLARE_TUNNEL_TOKEN`
4. preencher `tool\external-access\pass-through\.env.host` com:
   - `PUBLIC_HOSTNAME`
   - `CLOUDFLARE_TUNNEL_TOKEN`
5. subir a stack oficial com tunnel:

```powershell
.\tool\external-access\pass-through\start_host_stack.ps1 -WithTunnel
```

6. validar o hostname fixo:

```powershell
.\tool\external-access\pass-through\validate_public_flow.ps1 -BaseUrl https://SEU-HOSTNAME/sis/apirest.php -Username SEU_USUARIO -Password SUA_SENHA
```

7. gerar `.env.public` local, nao versionado, apontando para o hostname fixo
8. buildar o APK release pelo fluxo oficial:

```powershell
.\tool\android\build_release.ps1 -EnvFile .env.public
```

9. instalar no celular fora da intranet e executar smoke test

### Quando o tunel ja existir

Se o painel ja tiver um tunnel criado:

1. confirmar que ele e um `Cloudflare Tunnel` usavel para `Published application`
2. obter o `TUNNEL_TOKEN` desse tunnel
3. apontar a rota publica para `http://sis-pass-through:8080`
4. reutilizar o UUID existente no bootstrap local

### Permissoes minimas do token Cloudflare

Segundo a documentacao oficial da Cloudflare para criar tunnel e DNS por API, o token precisa de:

- conta:
  - `Cloudflare Tunnel Edit`
  - ou um equivalente de escrita como `Cloudflare Tunnel Write`
- zona:
  - `DNS Edit`

Sem isso, a automacao de named tunnel e DNS nao fecha.

### Fase 2 - endurecimento operacional

1. manter o host intermediario sempre ligado
2. confirmar restart automatico dos containers
3. revisar logs do proxy e do tunnel
4. definir responsavel operacional pelo hostname e pelo tunnel
5. registrar o caminho oficial do APK de distribuicao
6. repetir smoke test apos reinicio do host

### Fase 3 - decisao estrutural

1. avaliar se o pass-through direto para o GLPI e aceitavel
2. se nao for, migrar para relay proprio de aplicacao
3. expor apenas o subconjunto de rotas realmente usado pelo app

## Checklist de aceite para chamar de estavel

- `healthz` responde no hostname fixo
- `initSession` responde no hostname fixo
- `getFullSession` responde no hostname fixo
- `killSession` responde no hostname fixo
- login real funciona no celular fora da intranet
- catalogo abre
- `Meus Chamados` carrega
- `Fila offline` abre
- detalhe de chamado abre
- followup funciona
- criacao de chamado funciona
- anexo funciona
- o host continua acessivel apos reinicio do container
- um novo APK release foi gerado com o hostname estavel dentro do `.env` empacotado

## Roteiro operacional imediato

### Se o objetivo for continuar hoje

1. substituir o quick tunnel por named tunnel
2. validar o hostname fixo
3. rebuildar o APK
4. instalar no celular
5. fazer smoke test fora da rede

### Se faltar o token do Cloudflare

Sem o token nao ha como fechar a estabilizacao real.

Nesse caso, a ordem correta e:

1. obter o token
2. preencher `.env.host`
3. subir `-WithTunnel`
4. validar
5. rebuildar

## Observacao sobre esta maquina

O script `tool\android\build_release.ps1` foi endurecido para resolver fallback de JDK automaticamente quando `JAVA_HOME` estiver invalido.

Isso remove um bloqueio recorrente de build release nesta estacao, mas nao substitui a necessidade do hostname fixo e do tunnel nomeado para acesso externo estavel.
