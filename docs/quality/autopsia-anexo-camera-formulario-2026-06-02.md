# Autópsia rápida — anexo por câmera não persistia no formulário

Data: 2026-06-02

## Fato observado

No formulário de abertura de chamado do SIS Mobile, o botão de câmera abria a câmera e retornava para a tela, mas a foto não ficava persistida/listada como anexo.

## Classificação

Bug local de estado/processamento de anexo no widget de formulário. Não houve evidência de divergência GLPI/API nem necessidade de mutação remota para diagnosticar.

## Caminho da tela

- App SIS Mobile
- Serviço/formulário de abertura de chamado
- Seção `Anexar arquivo`
- Botão com ícone de câmera

## Comportamento esperado

Após confirmar a foto na câmera, o formulário deve:

- adicionar a foto à lista de anexos selecionados;
- exibir `Arquivos selecionados: 1`;
- repassar bytes/nome/tamanho para o `FormTemplate`, para que `submitTicket()` receba `attachmentBytesList`, `attachmentNameList` e `attachmentMimeList`.

## Comportamento observado pelo usuário

A câmera abre e a foto é confirmada, mas ao retornar ao formulário o anexo não aparece/persiste.

## Arquivos envolvidos

- `lib/widgets/anexar_arquivo_widget.dart`
- `lib/screens/form_template.dart`
- `test/anexar_arquivo_widget_camera_test.dart`

## Hipóteses consideradas

1. **Alta confiança:** fluxo da câmera dependia de path/cache via `File(foto.path)` e podia falhar antes de adicionar o anexo.
2. **Média confiança:** câmera retornava `XFile` sem nome estável, causando falha visual ou duplicação.
3. **Baixa confiança neste momento:** falha no upload GLPI. O bug relatado acontece antes do envio, na persistência visual/local do anexo.

## Causa raiz provável

O fluxo de documento usava `FilePicker` com `withData: true`, então o widget recebia bytes preservados. Já o fluxo de câmera criava `PlatformFile(bytes: null)` e dependia de `dart:io File(foto.path).length()` e posterior leitura por caminho. Em Android real, esse caminho/cache pode ser frágil; se a leitura por `File` falhar, o `catch` engole o erro e nada é adicionado à lista.

## Correção mínima

No fluxo `_tirarFoto()`:

- usar `XFile.readAsBytes()` diretamente;
- criar `PlatformFile` já com `bytes` preenchido;
- calcular `size` por `bytes.length`;
- manter fallback de nome `foto.jpg` se o plugin não retornar nome;
- permitir injeção de `pickImageFromCamera` apenas para teste automatizado.

## Validação executada

```bash
/opt/flutter/bin/flutter test test/anexar_arquivo_widget_camera_test.dart
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/dart format lib/widgets/anexar_arquivo_widget.dart test/anexar_arquivo_widget_camera_test.dart
```

Resultados:

- teste focado: passou;
- `flutter analyze`: `No issues found!`;
- suíte Flutter: `127 passed`, `1 skipped`;
- `dart format`: 2 arquivos verificados, 0 mudanças após formato.

## Aprendizado de processo

Pergunta que teria revelado o bug antes: “O fluxo da câmera preserva bytes como o fluxo de documentos, ou depende de path temporário?”

Teste que deve existir daqui para frente: widget test garantindo que uma foto retornada por `ImagePicker` vira `PlatformFile` com bytes/tamanho e notifica o formulário.

Checklist: para anexos mobile, tratar `XFile` como fonte de bytes da sessão atual; não persistir nem depender apenas de path temporário para upload posterior.
