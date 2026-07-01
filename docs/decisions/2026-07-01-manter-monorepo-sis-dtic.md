# Decisão: manter SIS Mobile e DTIC Mobile no mesmo repositório (monorepo com flavors)

- **Status:** aceita
- **Data:** 2026-07-01

## Contexto

DTIC Mobile é uma linha de produto real e funcionalmente isolada dentro deste
repositório (entrypoint próprio `lib/main_dtic.dart`, ~15 arquivos em `lib/dtic/`
contra ~87 do SIS, flavor Android próprio com `applicationId` distinto, Worker
Cloudflare dedicado, `.env` e feature flags separados), compartilhando de forma
deliberada apenas tema/UI neutra com o SIS. Isso levanta periodicamente a pergunta de
separar os dois em repositórios independentes.

## Decisão

Manter os dois num único repositório Flutter, com flavors Android, até que algum dos
gates abaixo (já definidos em `docs/MOBILE_WORKSPACE_ORGANIZATION.md`) seja atingido:

- builds/releases de SIS e DTIC provados independentes (hoje ambos usam o mesmo
  `pubspec.yaml`/versão, nunca extraídos isoladamente);
- volume real de duplicação de UI que justifique um pacote compartilhado formal (hoje
  o compartilhamento é só tema/tokens/alguns widgets `Sis*`, ~15% do código é DTIC);
- lifecycle ou ownership de time independentes entre as duas linhas (hoje mesmo
  repositório, mesmo ritmo de commits na mesma mainline);
- pressão de CI/CD que exija pipelines fisicamente separados (hoje não existe CI/CD
  configurado no repositório).

Nenhum desses gates foi atingido em 2026-07-01. Criar `sis-mobile/` + `dtic-mobile/` +
`mobile-shared-flutter/` agora adicionaria dois `pubspec.yaml`, dois pipelines e
resolução de imports por pacote sem ganho medido, para uma base de ~20k LOC.

## Consequências

- A fronteira SIS/DTIC continua sendo mantida por convenção de diretório
  (`lib/dtic/` vs. resto de `lib/`) e por revisão manual, não por isolamento físico de
  repositório/pacote.
- Já ocorreu um incidente de acoplamento (IDs de grupo SIS hardcoded vazando para
  lógica também usada por DTIC — ver `docs/audits/ACOPLAMENTO_SIS_DTIC_2026-06-27.md`),
  corrigido pontualmente. Isso é o custo aceito de não ter separação física: exige
  vigilância contínua, não um evento único de migração.
- Recomenda-se rodar periodicamente (antes de feature DTIC grande, ou
  trimestralmente) o comando de mapeamento de dependência já definido em
  `docs/MOBILE_WORKSPACE_ORGANIZATION.md` (Fase 2) como monitor de drift, em vez de
  tratar a separação como migração única e distante.
- Reavaliar esta decisão apenas quando um dos gates acima for atingido, não por
  preferência estética de organização de pastas.

## Referências

- `docs/MOBILE_WORKSPACE_ORGANIZATION.md` — framework completo de gates e fases de
  migração, caso a separação seja aprovada no futuro.
- `docs/PADRONIZACAO_APPS_SIS_DTIC.md` — contrato de padronização SIS/DTIC.
- `docs/audits/ACOPLAMENTO_SIS_DTIC_2026-06-27.md` — evidência do único incidente de
  acoplamento já ocorrido e sua correção.
