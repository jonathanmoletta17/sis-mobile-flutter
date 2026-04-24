# SIS Mobile - validacao atual e roteiro de teste

## Estado atual

Esta base ja foi validada em 3 niveis:

- validacao estrutural
  - `flutter analyze`: ok
  - `flutter test`: ok
- validacao da API real do GLPI
  - autenticacao
  - leitura de chamados
  - detalhe
  - followup
  - solucoes
  - anexos
- validacao em runtime no emulador Android
  - login
  - catalogo
  - meus chamados
  - detalhe do chamado
  - conversa
  - envio de followup
  - criacao de chamado
  - upload de anexo
  - envio de solucao com regra de negocio tratada na UI

## O que esta solido hoje

- autenticacao contra GLPI real
- catalogo de servicos
- abertura de chamados pela UI
- listagem de chamados reais
- detalhe de chamado real
- followup pela UI
- anexo pela UI
- tratamento amigavel de erro de negocio ao tentar registrar solucao sem categoria

## O que ainda e divida tecnica

- comentarios e logs internos com mojibake em alguns arquivos
- decisao sobre manter ou remover o auto-login de QA em debug
- rodada final em aparelho fisico fora do emulador
- empacotamento interno mais formal se a app for distribuida para mais pessoas

## Dependencia operacional importante

O backend da SIS esta em ambiente interno:

- `http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php`

Isso significa que o app so vai funcionar em teste real se o aparelho tiver acesso a essa rede.

Na pratica, o teste em celular exige um destes cenarios:

- estar na rede interna que alcanca esse host
- estar em VPN corporativa com acesso a esse host
- estar em um ambiente onde esse endpoint esteja roteavel

Sem isso, a app abre, mas o login e as operacoes online nao vao responder.

## APK atual para teste local

Build atual para teste manual:

- `C:\Users\jonathan-moletta\code\sis-mobile-flutter\build\app\outputs\flutter-apk\app-debug.apk`
- `C:\Users\jonathan-moletta\Downloads\sis-mobile-debug-teste-manual.apk`

Observacao:

- esta build e de debug
- esta versao atual nao usa auto-login de QA
- ela e apropriada para teste manual local com login real
- isso ainda nao deve ser tratado como distribuicao final

## Como testar na pratica no seu celular

### Opcao 1: teste manual normal

1. Copie o APK para o celular.
2. Instale o app.
3. Garanta que o celular consegue acessar o GLPI interno.
4. Abra a app.
5. Faca login com sua conta real do GLPI.

Smoke test recomendado:

1. Abrir `Servicos`
2. Entrar em `Meus Chamados`
3. Abrir um chamado existente
4. Entrar na conversa
5. Enviar um followup curto
6. Voltar
7. Abrir um formulario do catalogo, por exemplo `Carregadores`
8. Criar um chamado de teste com assunto identificavel
9. Confirmar que ele aparece em `Meus Chamados`
10. Entrar no detalhe e validar anexos, se houver

### Opcao 2: teste controlado de regra de solucao

Use um chamado sem categoria definida.

Fluxo:

1. Abrir o chamado
2. Entrar em conversa
3. Trocar o tipo para `Solucionar chamado`
4. Digitar uma solucao
5. Enviar

Resultado esperado:

- a UI deve mostrar:
  - `Defina a categoria do chamado antes de registrar a solucao.`

Isso confirma que a regra do GLPI esta sendo refletida de forma amigavel no app.

## Como testar no emulador desta maquina

1. Inicie o AVD:
   - `sisApi36`
2. Instale o APK:
   - `adb install -r build\app\outputs\flutter-apk\app-debug.apk`
3. Abra a app:
   - `adb shell am start -n br.gov.rs.casacivil.sismobile/.MainActivity`
4. Se a rede do host tiver acesso ao GLPI, a app consegue operar normalmente.

## O que observar durante o teste

- se o login entra sem erro
- se `Meus Chamados` carrega com contagens coerentes
- se o detalhe mostra status e anexos corretamente
- se o followup aparece depois do envio
- se o chamado novo aparece na lista
- se o anexo enviado aparece no chamado
- se a solucao bloqueada mostra mensagem clara

## O que ainda falta antes de chamar de distribuicao interna consolidada

1. Fazer uma rodada em aparelho fisico na rede real.
2. Limpar o mojibake residual de comentarios e logs internos.
3. Decidir a politica do auto-login de QA.
4. Gerar uma build de distribuicao interna com assinatura adequada.

## Leitura final

Hoje a SIS ja esta validada de forma consistente no backend real e no runtime Android.

Ela ja pode ser testada de verdade por voce, desde que:

- o aparelho alcance o GLPI interno
- a conta usada tenha permissao no ambiente real

O que falta agora nao e o nucleo funcional. O que falta e fechar a operacao de teste em aparelho fisico e preparar uma esteira mais formal de distribuicao interna.
