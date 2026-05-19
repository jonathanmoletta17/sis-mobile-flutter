# Scripts iOS/iPhone

Scripts seguros para preparar validação em iPhone sem tocar GLPI.

## Web/PWA para iPhone

```bash
./tool/ios/package_iphone_web.sh
```

Gera builds Web SIS/DTIC prontos para hospedagem HTTPS. É o caminho imediato para Safari/iPhone sem Apple Developer.

## IPA nativo no Mac

```bash
./tool/ios/build_ipa_on_mac.sh sis
```

Requer macOS + Xcode + Flutter + signing Apple.

O script recusa rodar fora do macOS e bloqueia DTIC se o Xcode project ainda não tiver bundle id/scheme DTIC real. Isso evita uma falsa entrega de IPA DTIC com identidade SIS.
