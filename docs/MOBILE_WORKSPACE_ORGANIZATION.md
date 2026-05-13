# Mobile Workspace Organization

## Objetivo

Definir como organizar SIS Mobile e DTIC Mobile dentro de
`/home/jonathan/projects/work/mobile` sem perder runtime funcional, historico de
validacao, build Android ou fronteiras de regra de negocio.

Este documento nao autoriza mover arquivos imediatamente. Ele define a ordem
segura para sair do estado atual ate uma eventual separacao por pastas/produtos.

## Estado atual confirmado

A fonte canonica Flutter mobile atual e:

```text
/home/jonathan/projects/work/mobile/sis-mobile-flutter
```

SIS Mobile e a linha padrao:

- entrypoint: `lib/main.dart`
- Android flavor: `sis`
- Android package id: `br.gov.rs.casacivil.sismobile`
- configuracao preferencial: `SIS_GLPI_BASE_URL`

DTIC Mobile e uma linha isolada dentro do mesmo repositorio:

- entrypoint: `lib/main_dtic.dart`
- codigo especifico: `lib/dtic/`
- Android flavor: `dtic`
- Android package id: `br.gov.rs.casacivil.dticmobile`
- recursos Android especificos: `android/app/src/dtic/`
- Worker especifico: `tool/external-access/workers-vpc-dtic/`
- configuracao preferencial: `DTIC_GLPI_BASE_URL`

Nao foi encontrado outro projeto Flutter DTIC separado sob
`/home/jonathan/projects/work`. Hoje existem apenas:

- `sis-mobile-flutter/pubspec.yaml`
- `sis-mobile-flutter/widgetbook/pubspec.yaml`

## Problema real

O problema atual nao e apenas o nome da pasta. Existem quatro riscos acoplados:

1. **Governanca:** parte da linha DTIC pode ainda estar como arquivo novo ou
   nao consolidado em Git.
2. **Fronteira de produto:** SIS e DTIC compartilham tema e componentes, mas nao
   devem compartilhar regras de negocio por simetria.
3. **Build Android:** a separacao fisica muda flavor, package id, recursos,
   scripts e possivelmente assinatura.
4. **Validacao:** qualquer split precisa provar que SIS e DTIC continuam
   analisando, testando, renderizando Widgetbook e gerando APK/AAB.

Por isso, mover `lib/dtic/` para outra pasta como primeira acao e incorreto. A
ordem segura e estabilizar, documentar, validar e so entao extrair.

## Decisao atual

Enquanto a migracao nao estiver provada, a fonte de verdade permanece:

```text
/home/jonathan/projects/work/mobile/sis-mobile-flutter
```

SIS e DTIC devem ser tratados como duas linhas de produto no mesmo Flutter, com
entrypoints, estado, configuracao, Worker e release separados.

A separacao para pastas proprias e uma migracao futura e deve acontecer apenas
quando os gates deste documento passarem.

## Estrutura-alvo recomendada

Se a separacao for aprovada, a estrutura final recomendada em `work/mobile` e:

```text
/home/jonathan/projects/work/mobile/
  sis-mobile-flutter/       # origem atual ate a migracao ser encerrada
  sis-mobile/               # app Flutter SIS independente
  dtic-mobile/              # app Flutter DTIC independente
  mobile-shared-flutter/    # pacote compartilhado somente se necessario
```

`mobile-shared-flutter/` so deve existir se houver codigo realmente compartilhado
com valor de manutencao claro. O pacote compartilhado pode conter:

- tema visual neutro
- tokens de UI
- widgets `widgets/ui/` sem dependencia de estado SIS ou DTIC
- superficies GLPI genericas
- mapeadores GLPI neutros

O pacote compartilhado nao deve conter:

- `AppState` da SIS
- `DticAppState`
- catalogo SIS em `service_data.dart`
- regras FormCreator DTIC
- Worker DTIC
- `.env`, secrets, keystores ou artefatos de build

## Fases de migracao

### Fase 0 - congelar o estado como evidencia

Objetivo: provar o que existe antes de mexer.

Comandos:

```bash
find /home/jonathan/projects/work/mobile -maxdepth 3 -type d | sort
find /home/jonathan/projects/work -maxdepth 5 -name pubspec.yaml -print | sort
git status --short
```

Criterio de aceite:

- DTIC aparece dentro de `sis-mobile-flutter`.
- Nao existe outro `pubspec.yaml` Flutter para DTIC em `work`.
- arquivos DTIC novos ou modificados estao identificados.

### Fase 1 - consolidar o modelo atual

Objetivo: fazer o modelo flavor SIS/DTIC ficar confiavel antes do split.

Acoes:

- versionar a linha DTIC atual quando revisada
- garantir que `README.md`, `BOOTSTRAP.md`, `AGENTS.md`,
  `docs/RUNTIME_CANONICO_E_VALIDACAO.md`, `docs/DTIC_MOBILE_V1.md` e
  `docs/PADRONIZACAO_APPS_SIS_DTIC.md` descrevem o mesmo runtime
- manter `.env.example` com variaveis separadas por app
- manter Worker DTIC separado
- manter `POST /Ticket` direto fora da abertura DTIC

Gates:

```bash
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter test test/dtic_formcreator_models_test.dart
```

Para mudanca visual ou superficie compartilhada:

```bash
cd widgetbook
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter build web
```

### Fase 2 - mapear dependencia compartilhada

Objetivo: decidir com evidencia se precisa de pacote compartilhado.

Comando:

```bash
rg -n "package:sis_mobile_flutter|lib/dtic|widgets/ui|theme/|service_data|FormCreator|DticAppState|AppState" lib test widgetbook
```

Criterio de aceite:

- cada arquivo fica classificado como `sis`, `dtic` ou `shared`.
- nenhum componente compartilhado depende de estado especifico de app.
- widgets com prefixo `Sis*` usados pela DTIC sao tratados como legado nominal,
  nao como acoplamento de regra SIS.

### Fase 3 - decidir o modelo final

Opcoes:

| Opcao | Quando usar | Custo |
| --- | --- | --- |
| Um repo Flutter com flavors | Releases e UI ainda evoluem juntos | Exige disciplina forte de fronteira |
| Dois repos Flutter independentes | SIS e DTIC precisam lifecycle e ownership independentes | Pode duplicar UI ou exigir pacote compartilhado |
| Monorepo mobile com `apps/` e `packages/` | Separacao fisica com compartilhamento formal | Mais tooling e mais superficie de manutencao |

Recomendacao atual:

- manter um repo com flavors ate SIS e DTIC passarem nos gates;
- so criar `sis-mobile/` e `dtic-mobile/` depois de provar builds
  independentes;
- criar `mobile-shared-flutter/` apenas se a duplicacao real justificar.

### Fase 4 - extracao controlada

Objetivo: criar pastas proprias sem quebrar runtime.

Cada app independente deve ter:

- `pubspec.yaml`
- `analysis_options.yaml`
- `.env.example`
- `README.md`
- `AGENTS.md`
- `lib/main.dart`
- `android/`
- `test/`
- `tool/android/build_release.ps1`

Ordem:

1. criar `mobile-shared-flutter/` se aprovado;
2. mover apenas componentes neutros para o pacote compartilhado;
3. criar `sis-mobile/` a partir do entrypoint SIS;
4. criar `dtic-mobile/` a partir do entrypoint DTIC;
5. ajustar imports por package path, nao por caminhos relativos frageis;
6. validar cada app isoladamente;
7. manter `sis-mobile-flutter/` congelado como origem ate a migracao ser aceita.

Gates por app:

```bash
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Gates Android no Windows host:

```powershell
flutter doctor -v
adb devices
flutter devices
.\tool\android\build_release.ps1
```

Para DTIC:

```powershell
.\tool\android\build_release.ps1 -App dtic -EnvFile .env.dtic.local
```

## Criterios de parada

Parar a migracao antes de mover codigo se:

- `flutter analyze` falhar;
- `flutter test` falhar;
- Widgetbook falhar quando houver mudanca visual;
- DTIC ainda tiver arquivos nao rastreados sem revisao;
- houver import cruzado que leve regra SIS para DTIC ou regra DTIC para SIS;
- a extracao exigir copiar `.env`, secrets, keystores ou build outputs;
- Android release nao puder ser reproduzido na camada Windows quando a mudanca
  afetar flavor, package id, assinatura ou recursos Android.

## Definicao de pronto

A migracao so pode ser declarada pronta quando:

- a estrutura final escolhida estiver documentada;
- SIS e DTIC tiverem fronteiras de codigo explicitas;
- SIS e DTIC passarem em `analyze` e `test`;
- Widgetbook passar quando houver mudanca visual;
- APK/AAB SIS e DTIC forem geraveis pelos scripts suportados;
- docs principais apontarem para as novas raizes canonicas;
- nenhum caminho Windows, `/mnt/c`, mirror, cache ou output for tratado como
  fonte canonica;
- as restricoes GLPI continuarem preservadas: validacao assistida por agente e
  read-only por padrao, e mutacao real somente com aprovacao humana explicita,
  ambiente isolado e alvo sintetico confirmado.

## Proximo passo recomendado

Executar somente as Fases 0 e 1 primeiro. Elas melhoram governanca e reduzem
risco sem alterar layout de codigo. A separacao fisica deve ser tratada como um
projeto seguinte, depois de passar nos gates atuais.
