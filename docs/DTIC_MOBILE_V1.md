# DTIC Mobile v1

## Contrato

DTIC Mobile e uma linha isolada dentro deste repositorio. A SIS continua sendo
o app padrao e a DTIC usa entrypoint, flavor Android e Worker proprios.

## Escopo do MVP

- login com usuario/senha do GLPI DTIC
- catalogo dinamico vindo do FormCreator
- renderizacao de formularios ativos em modo de validacao local
- consulta dos chamados do usuario
- detalhe com mensagens, solucoes e anexos principais
- aba de conversas para chamados em andamento
- painel de acoes do chamado com mensagem, solucao, anexos e atualizacao de
  status quando perfil, estado, build e Worker permitirem

Fora do MVP:

- paridade offline completa
- criacao offline com FormCreator
- atribuicao tecnica e aprovacao/recusa de solucao quando dependerem de
  permissao institucional especifica ou contrato adicional

## Padronizacao com SIS

A linha DTIC compartilha a fundacao visual e operacional do app SIS, mas nao
herda regras SIS por simetria.

Contrato detalhado:

- `PADRONIZACAO_APPS_SIS_DTIC.md`

Em resumo:

- mesmo tema, tokens, componentes `widgets/ui/`, padrao de estados e semantica
  GLPI
- entrypoint, estado, catalogo, Worker e fonte de verdade separados
- catalogo DTIC sempre vem do FormCreator
- abertura real DTIC nao usa `POST /Ticket` direto
- offline DTIC e acoes avancadas sao capacidades de paridade a modelar, nao
  exclusoes arquiteturais causadas pelo FormCreator
- Widgetbook possui previews e goldens para login, catalogo, chamados,
  conversas, detalhe e FormCreator DTIC

## Configuracao

O app DTIC deve apontar para um Worker, nao para o GLPI interno direto:

```env
DTIC_GLPI_BASE_URL=https://dtic-glpi.<conta>.workers.dev/glpi/apirest.php
GLPI_DEBUG_LOGS=false
DTIC_ENABLE_TICKET_ACTIONS=false
DTIC_ENABLE_FORM_SUBMISSION=false
```

`GLPI_BASE_URL` continua aceito como fallback legado, mas a linha DTIC deve
preferir `DTIC_GLPI_BASE_URL` para evitar apontar acidentalmente para o GLPI SIS.

`App-Token` nao entra no Flutter nem no APK. Ele deve ser configurado como
secret do Worker DTIC:

```bash
npx wrangler secret put GLPI_APP_TOKEN
```

## Build

SIS continua sendo o padrao do script:

```powershell
.\tool\android\build_release.ps1
```

Build DTIC:

```powershell
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local
```

O arquivo `.env.dtic.local` e local e nao deve ser versionado.

## Worker

Worker DTIC:

```text
tool/external-access/workers-vpc-dtic/
```

Ele injeta `App-Token` server-side e bloqueia escritas por padrao.

Acoes de ticket seguem a mesma abordagem externa da SIS, mas exigem dupla
liberacao:

- build/app: `DTIC_ENABLE_TICKET_ACTIONS=true`
- Worker: `ALLOW_TICKET_ACTIONS=true`

Submissao real via `PluginFormcreatorFormAnswer` e a capacidade correta para
abertura DTIC. Ela deve ser habilitada por contrato e validacao controlada, com
`ALLOW_FORMCREATOR_SUBMISSION=true`, sem recorrer a `POST /Ticket` direto.

## Guardas

- `service_data.dart` nao e fonte de verdade para DTIC.
- `POST /Ticket` direto nao faz parte do fluxo DTIC.
- FormCreator e a fonte de verdade do catalogo.
- FormCreator nao reduz o escopo de navegacao, conversas, offline ou acoes de
  ticket; ele apenas muda o contrato de abertura de chamados.
- FormCreator esta encapsulado porque o plugin esta em fim de vida e pode ser
  substituido por Forms nativo em GLPI futuro.
