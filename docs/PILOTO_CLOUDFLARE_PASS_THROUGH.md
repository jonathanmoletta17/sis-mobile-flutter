# Piloto Cloudflare Pass-Through

## Objetivo

Subir um host intermediario estavel para que a pessoa usuaria precise apenas do APK no celular, sem VPN nem app auxiliar no aparelho.

## Escopo

Este playbook cobre a Opcao A descrita em `ACESSO_EXTERNO_CONTROLADO.md`:

- reverse proxy pass-through
- `cloudflared`
- hostname publico fixo
- APK release apontando para esse hostname

Nao cobre:

- Cloudflare Access no cliente
- relay proprio de aplicacao
- publicacao do GLPI bruto sem hardening minimo

## Artefatos do repo

- stack Docker: `../tool/external-access/pass-through/docker-compose.yml`
- proxy Nginx: `../tool/external-access/pass-through/nginx/default.conf.template`
- env do host: `../tool/external-access/pass-through/.env.host.example`
- start da stack: `../tool/external-access/pass-through/start_host_stack.ps1`
- stop da stack: `../tool/external-access/pass-through/stop_host_stack.ps1`
- env publico do app: `../.env.public.example`
- validacao do endpoint: `../tool/external-access/pass-through/validate_public_flow.ps1`
- preflight de conta/token para named tunnel: `../tool/external-access/pass-through/validate_cloudflare_named_tunnel_prereqs.ps1`
- bootstrap de named tunnel + DNS: `../tool/external-access/pass-through/bootstrap_named_tunnel.ps1`

## Pre-requisitos

- host sempre ligado com acesso ao GLPI interno
- Docker e Docker Compose no host
- conta Cloudflare com dominio sob controle
- tunnel nomeado criado no Cloudflare
- token do tunnel disponivel

## Variaveis do host

Copie:

```powershell
Copy-Item tool\external-access\pass-through\.env.host.example tool\external-access\pass-through\.env.host
```

Preencha ao menos:

- `PUBLIC_HOSTNAME`
- `GLPI_INTERNAL_ORIGIN`
- `CLOUDFLARE_TUNNEL_TOKEN`

Regra importante:

- `GLPI_INTERNAL_ORIGIN` deve apontar para a origem interna sem anexar `/sis/apirest.php`
- o proxy preserva a rota `/sis/apirest.php`

## Configuracao do Tunnel

No Cloudflare, configure o hostname publico do tunnel para apontar para:

```text
http://sis-pass-through:8080
```

Esse nome funciona porque o container `cloudflared` e o proxy `sis-pass-through` compartilham a mesma rede Docker da stack.

## Subida da stack

No host intermediario:

```powershell
.\tool\external-access\pass-through\start_host_stack.ps1
```

Verificacao local:

```powershell
Invoke-WebRequest http://127.0.0.1:18080/healthz | Select-Object StatusCode, Content
```

Quando o token do tunnel ja estiver preenchido e o hostname publico ja existir no Cloudflare:

```powershell
.\tool\external-access\pass-through\start_host_stack.ps1 -WithTunnel
```

Para parar:

```powershell
.\tool\external-access\pass-through\stop_host_stack.ps1
```

## Validacao do endpoint publico

Valide o endpoint publicado:

```powershell
.\tool\external-access\pass-through\validate_public_flow.ps1 -BaseUrl https://SEU-HOSTNAME/sis/apirest.php
```

Validacao autenticada:

```powershell
.\tool\external-access\pass-through\validate_public_flow.ps1 -BaseUrl https://SEU-HOSTNAME/sis/apirest.php -Username SEU_USUARIO -Password SUA_SENHA
```

Checklist minimo:

1. `/healthz` responde `200 ok`
2. `initSession` retorna `session_token`
3. `getFullSession` responde corretamente
4. `killSession` encerra a sessao

## Preparacao para hostname estavel

Antes de sair do quick tunnel e fechar um hostname fixo, valide o controle de Cloudflare:

```powershell
.\tool\external-access\pass-through\validate_cloudflare_named_tunnel_prereqs.ps1 -ApiToken SEU_TOKEN -AccountId SUA_CONTA -ZoneId SUA_ZONA
```

Se o token tiver permissao suficiente, o bootstrap do tunnel nomeado pode ser feito com:

```powershell
.\tool\external-access\pass-through\bootstrap_named_tunnel.ps1 -ApiToken SEU_TOKEN -AccountId SUA_CONTA -ZoneId SUA_ZONA -Hostname sis-mobile.seu-dominio.gov.br -WriteEnvFile
```

Esse comando:

1. cria o tunnel remoto
2. publica a configuracao de ingress
3. cria ou atualiza o CNAME proxied
4. grava `PUBLIC_HOSTNAME` e `CLOUDFLARE_TUNNEL_TOKEN` em `.env.host`

Se o tunel ja existir no painel, reutilize-o:

```powershell
.\tool\external-access\pass-through\bootstrap_named_tunnel.ps1 -ApiToken SEU_TOKEN -AccountId SUA_CONTA -ZoneId SUA_ZONA -TunnelId UUID_DO_TUNEL -Hostname sis-mobile.seu-dominio.gov.br -WriteEnvFile
```

## Importante sobre WARP Connector

`WARP Connector` e `Cloudflare Tunnel` nao sao a mesma trilha operacional para este app.

Para cumprir o requisito "a pessoa usa apenas o APK no celular":

- use `Cloudflare Tunnel`
- adicione uma rota do tipo `Published application`
- publique um hostname HTTP publico
- rode `cloudflared` com `TUNNEL_TOKEN`

`WARP Connector` e private hostname exigem a malha WARP/Gateway do lado cliente, o que nao atende o requisito de usar apenas o app.

## Build do APK para piloto

Opcao direta:

```powershell
.\tool\android\build_release.ps1 -GlpiBaseUrl https://SEU-HOSTNAME/sis/apirest.php
```

Opcao por arquivo dedicado:

```powershell
Copy-Item .env.public.example .env.public
```

Edite `.env.public` com o hostname real e rode:

```powershell
.\tool\android\build_release.ps1 -EnvFile .env.public
```

## Hardening minimo

- manter o host sempre ligado
- restringir a superficie publicada ao caminho do app
- observar logs do proxy e do tunnel
- definir limite de upload compativel com o uso real
- validar anexo, followup, detalhe e criacao de chamado antes de distribuir amplamente

## Linha de evolucao

Se o piloto validar conectividade mas a exposicao direta do GLPI for considerada fraca demais, a proxima etapa correta e migrar para o relay proprio da Opcao B.
