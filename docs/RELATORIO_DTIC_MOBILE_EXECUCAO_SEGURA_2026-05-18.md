# Relatório de execução segura — DTIC Mobile externo/read-only

Data: 2026-05-18
Host: CC-PC-WS1655947
Repo: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`
Branch: `main`
Path class: WSL ext4 canonical source root

## 1. Escopo executado

Executado de ponta a ponta até o limite seguro:

- discovery read-only do DTIC Mobile no repo;
- endurecimento local do Worker DTIC;
- deploy do Worker DTIC read-only no Cloudflare;
- validação externa de `/healthz` e bloqueios destrutivos;
- geração de APK DTIC release read-only;
- validação do APK;
- execução de testes Flutter, Node e Widgetbook DTIC.

Não executado:

- nenhuma credencial GLPI foi lida/impressa;
- nenhum `.env` secreto foi impresso;
- nenhum ticket real foi criado, alterado, fechado, apagado ou usado como massa;
- nenhum followup/anexo/solução/status real foi enviado;
- nenhum `DELETE`, purge ou cleanup foi executado contra GLPI.

## 2. Worker DTIC

Arquivos alterados:

- `tool/external-access/workers-vpc-dtic/src/index.js`
- `tool/external-access/workers-vpc-dtic/test/allowlist.test.mjs`
- `tool/external-access/workers-vpc-dtic/wrangler.jsonc`
- `tool/external-access/workers-vpc-dtic/README.md`

Mudanças:

- adicionou `GET /healthz` sem tocar GLPI e sem exigir `GLPI_APP_TOKEN`;
- fixou `account_id` correto: `143962d5b1564408b10e48ea4bd6328f`;
- trocou VPC Service inexistente `019e2016-2a46-7923-966c-84a6cd95ce94` pelo serviço existente e validado `019e39d4-a7ac-7362-ac8b-24a09050ae72`;
- manteve `ALLOW_TICKET_ACTIONS=false`;
- manteve `ALLOW_FORMCREATOR_SUBMISSION=false`;
- bloqueou `POST /Document` e `POST /Document_Item` standalone mesmo quando ações de ticket forem habilitadas, para evitar documentos órfãos;
- aplicou allowlist antes de checar secret, para requisições proibidas retornarem `403` mesmo se `GLPI_APP_TOKEN` estiver ausente.

URL publicada:

```text
https://dtic-glpi.jonathan-sis-mobile-20260518.workers.dev
```

Base URL DTIC:

```text
https://dtic-glpi.jonathan-sis-mobile-20260518.workers.dev/glpi/apirest.php
```

Versão publicada:

```text
Current Version ID inicial: c2628146-2af9-43e3-8924-ec1c3082392d
Current Version ID apos configurar GLPI_APP_TOKEN: a2ea4d6b-127a-4a34-9e78-5366b30e7843
```

## 3. Validação externa do Worker

Resultados:

| Método | Path | Status | Resultado |
|---|---|---:|---|
| GET | `/healthz` | 200 | `ok` |
| DELETE | `/glpi/apirest.php/Ticket/1` | 403 | bloqueado pela allowlist |
| POST | `/glpi/apirest.php/Document` | 403 | bloqueado pela allowlist |
| POST | `/glpi/apirest.php/Document_Item` | 403 | bloqueado pela allowlist |
| POST | `/glpi/apirest.php/Ticket` | 403 | criação direta bloqueada |
| GET | `/glpi/apirest.php/ITILCategory` sem sessao | 400 | `ERROR_SESSION_TOKEN_MISSING`, vindo do GLPI interno |

Interpretação:

- Worker está vivo externamente.
- Bloqueios destrutivos e órfãos funcionam mesmo sem secret.
- `GLPI_APP_TOKEN` foi configurado posteriormente no Worker DTIC sem imprimir o valor.
- Acesso real read-only ao GLPI DTIC foi validado com sessao temporaria e encerrada via `killSession`.

Smoke autenticado read-only:

| Etapa | Status | Evidencia |
|---|---:|---|
| `initSession` | 200 | session token presente, valor nao impresso |
| `getFullSession` | 200 | objeto `session` retornado |
| `PluginFormcreatorForm?range=0-0` | 206 | 1 item retornado |
| `ITILCategory?range=0-0` | 206 | 1 item retornado |
| `killSession` | 200 | `true` |

## 4. APK DTIC gerado

Arquivo WSL:

```text
/home/jonathan/projects/work/mobile/sis-mobile-flutter/build/app/outputs/flutter-apk/app-dtic-release.apk
```

Cópia Windows:

```text
C:\Users\jonathan-moletta\ops\dtic-mobile\dtic-mobile-release-worker-20260518.apk
```

Metadados:

| Campo | Valor |
|---|---|
| Package | `br.gov.rs.casacivil.dticmobile` |
| Label | `DTIC Mobile` |
| Version | `1.0.0` / code `1` |
| Tamanho | `53.971.500 bytes` |
| SHA-256 | `e60474f995d28dfbcfe5543c0c19caf8f8e6d69c9ad6a5200d8e4df35d7e3db9` |
| Assinatura | APK Signature Scheme v2 válida |

`.env` embutido no APK:

```env
DTIC_GLPI_BASE_URL=https://dtic-glpi.jonathan-sis-mobile-20260518.workers.dev/glpi/apirest.php
GLPI_DEBUG_LOGS=false
DTIC_ENABLE_FORM_SUBMISSION=false
DTIC_ENABLE_TICKET_ACTIONS=false
```

Conclusão:

- APK é DTIC, não SIS.
- Endpoint é DTIC `/glpi/apirest.php`, não SIS `/sis/apirest.php`.
- Build é read-only: submissão FormCreator e ações de ticket estão desligadas.

## 5. Testes executados

### Worker DTIC

Comando:

```bash
node --test test/allowlist.test.mjs
```

Resultado:

```text
8 passed
0 failed
```

### Wrangler dry-run

Comando:

```bash
unset CLOUDFLARE_API_TOKEN; npx wrangler deploy --dry-run
```

Resultado:

```text
env.GLPI (019e39d4-a7ac-7362-ac8b-24a09050ae72) VPC Service
env.ALLOW_TICKET_ACTIONS ("false")
env.ALLOW_FORMCREATOR_SUBMISSION ("false")
```

### Flutter analyze

Comando:

```bash
/opt/flutter/bin/flutter analyze
```

Resultado:

```text
No issues found!
```

### Flutter test

Comando:

```bash
/opt/flutter/bin/flutter test
```

Resultado:

```text
69 passed
0 failed
```

### Widgetbook DTIC

Comando:

```bash
/opt/flutter/bin/flutter test test/dtic_app_surfaces_preview_test.dart test/dtic_formcreator_surface_preview_test.dart
```

Diretório:

```text
/home/jonathan/projects/work/mobile/sis-mobile-flutter/widgetbook
```

Resultado:

```text
8 passed
0 failed
```

## 6. Gates restantes

### Gate B — Secret/ambiente DTIC

Pendente:

- configurar `GLPI_APP_TOKEN` no Worker `dtic-glpi` sem expor o valor;
- validar read-only autenticado: `initSession`, `getFullSession`, catálogo FormCreator, `killSession`;
- confirmar se o mesmo VPC Service compartilhado com SIS é aceitável operacionalmente ou se deve ser criado um VPC Service nomeado `dtic-glpi` apontando para o mesmo host.

### Gate C — Instalação no celular

Pronto para instalação:

```text
C:\Users\jonathan-moletta\ops\dtic-mobile\dtic-mobile-release-worker-20260518.apk
```

Limitação esperada:

- sem `GLPI_APP_TOKEN` no Worker, login deve falhar com erro de configuração do Worker.

### Gate D — Mutação sintética

Ainda bloqueado.

Só liberar depois de aprovação explícita para:

- criar chamado sintético DTIC via FormCreator;
- usar prefixo `[HERMES-E2E-DTIC-NAO-APAGAR]`;
- enviar followup/anexo/solução/status apenas nesse ticket;
- nunca usar ticket real como massa.

## 7. Recomendações imediatas

1. Configurar o secret do Worker DTIC:

```bash
cd /home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/external-access/workers-vpc-dtic
unset CLOUDFLARE_API_TOKEN
npx wrangler secret put GLPI_APP_TOKEN
npx wrangler deploy
```

2. Revalidar read-only externo:

- `/healthz`;
- `DELETE /Ticket/1 -> 403`;
- `POST /Document -> 403`;
- `initSession` com usuário autorizado;
- `getFullSession`;
- `PluginFormcreatorForm?range=0-0`;
- `killSession`.

3. Instalar o APK DTIC no celular apenas para smoke read-only.

4. Não habilitar `DTIC_ENABLE_FORM_SUBMISSION` nem `DTIC_ENABLE_TICKET_ACTIONS` ainda.
