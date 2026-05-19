# iPhone / iOS — plano operacional SIS/DTIC Mobile

Este documento separa o que é possível provar no WSL do que exige macOS/Xcode.

## 1. Verdade operacional

- iPhone não instala APK. APK é Android.
- Flutter reaproveita o código Dart/UI, mas cada plataforma precisa de artefato próprio.
- iPhone nativo exige IPA/TestFlight/App Store/MDM.
- IPA exige macOS + Xcode + signing Apple.
- Este repo já possui `ios/`, mas o host WSL atual não possui toolchain iOS.

Evidência neste host:

- `xcodebuild`: ausente
- `pod`: ausente
- `flutter build` neste host não lista `ios` nem `ipa`
- pasta `ios/`: presente

## 2. Caminho imediato para colega com iPhone: Web/PWA

Use quando o objetivo é validar rapidamente no Safari sem Apple Developer.

Comando no WSL:

```bash
./tool/ios/package_iphone_web.sh
```

Saída padrão:

```text
C:\Users\jonathan-moletta\ops\sis-mobile\iphone-web-YYYYMMDD-HHMM
```

Publicação necessária:

- hospedar `sis/` em HTTPS com base `/sis-mobile/`
- hospedar `dtic/` em HTTPS com base `/dtic-mobile/`

No iPhone:

1. Abrir a URL no Safari.
2. Compartilhar > Adicionar à Tela de Início.
3. Primeiro teste: abrir app e fazer fluxo read-only.
4. Só depois, com aprovação, usar ticket sintético.

Limitações esperadas no Web/PWA:

- permissões de arquivo/câmera dependem do Safari iOS;
- não é IPA;
- não aparece como app instalado via TestFlight/App Store;
- precisa CORS/Worker funcionando.

## 3. Caminho nativo correto: IPA/TestFlight

Pré-requisitos fora do WSL:

- Mac com macOS recente;
- Xcode instalado;
- Flutter instalado no Mac;
- CocoaPods (`pod`) instalado;
- Apple Developer Team;
- signing configurado no Xcode;
- device iPhone autorizado ou TestFlight.

Script preparado:

```bash
./tool/ios/build_ipa_on_mac.sh sis
```

Para DTIC:

```bash
./tool/ios/build_ipa_on_mac.sh dtic
```

Observação importante: a configuração iOS atual é SIS-first. O script bloqueia DTIC se o bundle id `br.gov.rs.casacivil.dticmobile` ainda não estiver configurado no Xcode project. Isso evita gerar um IPA DTIC falso com bundle SIS.

## 4. Estado iOS atual do repo

Confirmado:

- `ios/Runner/Info.plist` existe;
- display name atual: `SIS Mobile`;
- bundle id no Xcode project: `br.gov.rs.casacivil.sismobile`;
- não há evidência de scheme/flavor iOS DTIC pronto;
- Android já tem flavors SIS/DTIC separados.

Conclusão:

- SIS iOS nativo é o primeiro alvo viável em Mac.
- DTIC iOS nativo precisa configuração adicional de flavor/scheme/bundle id no Xcode.

## 5. Gates obrigatórios para dizer “funciona no iPhone”

### Gate A — Build nativo

- Rodar em Mac.
- `flutter doctor -v` verde para iOS.
- `pod install` sem erro.
- `flutter build ipa` gera IPA.
- IPA tem bundle id esperado.

### Gate B — Instalação

- Instalar via Xcode/Apple Configurator/MDM/TestFlight.
- Abrir em iPhone real.
- Capturar versão/build.

### Gate C — Rede read-only

- App alcança Worker público.
- Login funciona.
- `killSession`/logout funciona.
- Lista/detalhe/conversa abrem sem mutação.

### Gate D — Mutação sintética, se aprovada

- Criar ou usar no máximo 1–2 tickets `[HERMES-E2E-NAO-APAGAR]`.
- Revalidar ID/prefixo antes de cada mutação.
- Nunca tocar ticket real.

## 6. Garantia honesta

O que pode ser garantido no WSL:

- código Flutter analisado/testado;
- Android/Web buildados;
- scripts e documentação iOS preparados;
- artefatos Web/PWA para Safari gerados;
- validação de que não há toolchain iOS local.

O que só pode ser garantido em Mac/Apple:

- IPA gerado;
- assinatura válida;
- TestFlight/App Store/MDM;
- instalação em iPhone;
- runtime iOS real.
