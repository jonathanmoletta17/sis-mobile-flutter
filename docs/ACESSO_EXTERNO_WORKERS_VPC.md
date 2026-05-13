# Acesso Externo com Cloudflare Workers VPC

## Guarda operacional

O acesso externo existe para preservar uso real do app, nao para ampliar a superficie de teste destrutivo.

- Funcionalidades normais de producao continuam preservadas para usuarios autorizados.
- Worker SIS pass-through deve ser tratado como superficie sensivel ate existir allowlist/bloqueio tecnico de metodos destrutivos.
- Agentes nao devem usar Worker SIS para `DELETE /Ticket`, purge, cleanup automatizado ou qualquer metodo destrutivo contra GLPI real sem aprovacao humana explicita e ambiente isolado.
- Validacoes assistidas por agente devem preferir chamadas read-only.

## Objetivo

Definir a arquitetura de primeira fase para usar o app em celular fora da intranet sem instalar VPN em cada aparelho, sem comprar ou delegar dominio proprio e sem mover a fonte canonica do projeto para Windows.

## Decisao

Para o requisito "a pessoa usuaria instala apenas o APK", a opcao preferencial passa a ser:

- Cloudflare Worker publicado em `workers.dev`
- Workers VPC Service apontando para o GLPI interno
- Cloudflare Tunnel como conector outbound a partir de um host dentro da rede interna
- app Flutter apontando `GLPI_BASE_URL` para a URL do Worker

Essa trilha nao exige:

- migrar o repo WSL para Windows
- instalar VPN em cada celular
- comprar dominio
- transferir nameservers para Cloudflare
- publicar o GLPI direto na internet
- usar bridge USB/LAN, `adb reverse` ou proxy de notebook

## Fronteira WSL + Windows

A fonte canonica continua em:

```text
/home/jonathan/projects/work/mobile/sis-mobile-flutter
```

Windows pode hospedar Android SDK, emulator, `adb`, Flutter Windows, Docker Desktop ou `cloudflared`, mas isso e camada de runtime/build/infra. Nao e raiz de codigo-fonte.

Se for necessario espelho Windows para build Android, ele continua sendo operacional e temporario:

```text
C:\Users\jonathan-moletta\build-mirrors\sis-mobile-flutter
```

Edicoes de fonte devem voltar para a raiz WSL.

## Fluxo alvo

### SIS

```text
App Flutter no celular
  -> https://sis-glpi.<subdominio-da-conta>.workers.dev/sis/apirest.php
  -> Cloudflare Worker
  -> Workers VPC Service
  -> Cloudflare Tunnel outbound
  -> host dentro da intranet
  -> http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php
```

### DTIC

```text
App Flutter DTIC no celular
  -> https://dtic-glpi.<subdominio-da-conta>.workers.dev/glpi/apirest.php
  -> Cloudflare Worker DTIC
  -> Workers VPC Service
  -> Cloudflare Tunnel outbound
  -> host dentro da intranet
  -> http://cau.ppiratini.intra.rs.gov.br/glpi/apirest.php
```

## Modelo consolidado SIS + DTIC

As duas linhas usam a mesma abordagem para operar fora do dominio institucional:
o APK fala com uma URL publica HTTPS do Worker, e o Worker alcança o GLPI
interno pelo caminho VPC/Tunnel.

A diferenca nao e o login do usuario. Em ambos os casos, o usuario continua
autenticando com usuario/senha do GLPI. A diferenca DTIC e que a API exige
`App-Token`, e esse token fica somente no Worker DTIC.

Contrato por linha:

- SIS: Worker pass-through preserva o contrato atual do app para tickets,
  mensagens, solucoes, anexos e transicoes suportadas pelo GLPI SIS.
- DTIC: Worker separado injeta `App-Token`, preserva `Session-Token` e libera
  acoes de ticket apenas com `ALLOW_TICKET_ACTIONS=true`.
- DTIC FormCreator: abertura real de chamado e decisao separada; nao deve usar
  `POST /Ticket` direto e so pode ser liberada com
  `ALLOW_FORMCREATOR_SUBMISSION=true` em janela autorizada.

## Por que nao usar a tela "Connect your domain"

A tela de dominio do painel Cloudflare serve para ativar uma zona DNS propria, por exemplo `exemplo.com.br`, e depois criar hostnames como `sis-glpi.exemplo.com.br`.

Esse caminho exige controle real do dominio e, normalmente, troca de nameservers.

Para a primeira fase deste projeto, isso nao e requisito. `workers.dev` ja fornece uma URL HTTPS publica da conta Cloudflare para um Worker sem onboarding de dominio proprio.

## Por que nao usar Quick Tunnel como solucao

Quick Tunnel com `trycloudflare.com` e util para prova tecnica pontual, mas nao e adequado para distribuicao:

- URL aleatoria
- sem contrato de estabilidade
- indicado para teste e desenvolvimento
- exige rebuild do APK quando a URL muda

Use Quick Tunnel apenas para provar conectividade, nunca como URL do APK distribuivel.

## Pre-requisitos

- Conta Cloudflare com Workers habilitado.
- Subdominio `workers.dev` configurado na conta.
- Acesso a Workers VPC na conta.
- Host sempre ligado dentro da rede interna ou ambiente institucional que resolva/alcanque:

```text
http://cau.ppiratini.intra.rs.gov.br
```

- `cloudflared` instalado nesse host.
- Permissao para criar Tunnel, VPC Service e Worker.

## Configuracao de alto nivel

### 1. Configurar `workers.dev`

No painel Cloudflare:

1. abrir `Workers & Pages`
2. configurar o subdominio `workers.dev` da conta, se ainda nao existir
3. reservar um nome de Worker, por exemplo `sis-glpi`

URL final esperada:

```text
https://sis-glpi.<subdominio-da-conta>.workers.dev
```

### 2. Criar Tunnel para Workers VPC

No painel de Workers VPC:

1. criar um Tunnel, por exemplo `sis-glpi-vpc`
2. copiar o comando/token de instalacao do `cloudflared`
3. executar o conector em host que esteja dentro da intranet
4. confirmar que o tunnel fica conectado

Esse host precisa conseguir acessar o GLPI interno por DNS ou IP.

### 3. Criar VPC Service para o GLPI

Opcao por hostname interno:

```powershell
npx wrangler vpc service create sis-glpi `
  --type http `
  --tunnel-id <TUNNEL_ID> `
  --hostname cau.ppiratini.intra.rs.gov.br `
  --http-port 80
```

Opcao por IP interno, se DNS interno falhar no caminho do tunnel:

```powershell
npx wrangler vpc service create sis-glpi `
  --type http `
  --tunnel-id <TUNNEL_ID> `
  --ipv4 10.72.30.39 `
  --http-port 80
```

O path `/sis/apirest.php` nao pertence ao VPC Service; ele e preservado pelo Worker.

### 4. Criar Worker proxy

Configuracao esperada em `wrangler.jsonc`:

```jsonc
{
  "$schema": "./node_modules/wrangler/config-schema.json",
  "name": "sis-glpi",
  "main": "src/index.ts",
  "compatibility_date": "2026-04-28",
  "workers_dev": true,
  "vpc_services": [
    {
      "binding": "GLPI",
      "service_id": "<SERVICE_ID>",
      "remote": true
    }
  ]
}
```

Worker minimo:

```ts
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const incoming = new URL(request.url);
    const target = new URL(incoming.pathname + incoming.search, 'http://cau.ppiratini.intra.rs.gov.br');

    return env.GLPI.fetch(new Request(target, request));
  },
};

interface Env {
  GLPI: Fetcher;
}
```

O Worker deve ser pass-through HTTP para o contrato atual do app:

- `GET`, `POST` e `PUT`
- headers `Accept`, `Content-Type` e `Session-Token`
- upload multipart
- download de documentos
- codigos de resposta originais do GLPI

### 5. Deploy

```powershell
npx wrangler deploy
```

Validar a URL:

```powershell
curl -v https://sis-glpi.<subdominio-da-conta>.workers.dev/sis/apirest.php/initSession `
  -H "Content-Type: application/json" `
  -u USUARIO:SENHA
```

Resultado esperado:

- HTTP `200`
- corpo com `session_token`

Depois da validacao, encerrar a sessao com `killSession`.

## Configuracao do app

Gerar um `.env.public` local e nao versionado:

```env
GLPI_BASE_URL=https://sis-glpi.<subdominio-da-conta>.workers.dev/sis/apirest.php
GLPI_DEBUG_LOGS=false
```

Build Android pelo Windows host:

```powershell
.\tool\android\build_release.ps1 -EnvFile .env.public
```

Para debug APK via espelho Windows, o espelho continua sendo derivado da fonte WSL e nao substitui a raiz canonica.

## Seguranca e limites

- Nao habilitar Cloudflare Access no Worker se isso exigir cookie, login web ou token que o app Flutter nao envia.
- Nao embutir segredo permanente de edge no APK como solucao padrao.
- O Worker precisa ter logs e limites compativeis com expor uma API interna.
- Antes de producao ampla, validar limites, plano e politica de uso da conta Cloudflare.
- Se o GLPI devolver redirects com hostname interno em `Location`, o Worker precisa reescrever esse header para a URL publica.
- Se pass-through integral do GLPI for considerado amplo demais, evoluir para relay proprio com allowlist das rotas usadas pelo app.

## Checklist de aceite

- `workers.dev` ativo e com URL HTTPS publica.
- Tunnel conectado a partir de host institucional sempre ligado.
- VPC Service criado para `cau.ppiratini.intra.rs.gov.br:80` ou IP interno equivalente.
- Worker publicado e respondendo.
- `initSession`, `getFullSession` e `killSession` funcionando pelo Worker.
- APK gerado com `GLPI_BASE_URL` do Worker.
- Login real no celular fora da intranet sem VPN.
- Catalogo, meus chamados, detalhe, followup, criacao e anexo validados pelo mesmo endpoint.

## Referencias oficiais

- Cloudflare Workers `workers.dev`: https://developers.cloudflare.com/workers/configuration/routing/workers-dev/
- Cloudflare Workers VPC: https://developers.cloudflare.com/workers-vpc/
- Private API via Workers VPC: https://developers.cloudflare.com/workers-vpc/examples/private-api/
- Cloudflare Quick Tunnels: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/trycloudflare/
