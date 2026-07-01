# Decisão: acesso externo "somente APK" via Worker + Workers VPC + Tunnel, sem VPN por aparelho

- **Status:** aceita
- **Data:** 2026-07-01 (formalização como ADR; decisão original documentada
  anteriormente em `docs/ACESSO_EXTERNO_CONTROLADO.md`)

## Contexto

O GLPI da SIS é interno e depende de rede interna ou VPN para acesso direto. Usuários
finais que só precisam do APK fora da intranet não devem ser obrigados a configurar
VPN por aparelho, mas o repositório também não deve depender de soluções ad-hoc frágeis
(bridge USB/LAN, `adb reverse`, proxy de notebook) que não escalam além de uma máquina
de desenvolvedor.

## Decisão

- Para distribuição "somente APK" fora da intranet, o caminho suportado é: Cloudflare
  Worker em `workers.dev` + Workers VPC + Tunnel, sem exigir domínio próprio na
  primeira fase (arquitetura detalhada em `docs/ACESSO_EXTERNO_WORKERS_VPC.md`).
- VPN por aparelho continua reservada a desenvolvimento, suporte técnico ou grupos
  controlados — não é a estratégia para distribuição ampla do APK.
- Bridge USB/LAN, `adb reverse` e proxy de notebook **não são estratégias suportadas**
  em nenhuma circunstância — são atalhos de desenvolvedor local, não solução
  operacional.
- A sessão de serviço elevada do Worker permanece restrita a GET de diretório
  User/Group; mutação (quando necessária para validação) usa sempre a conta de teste
  dedicada, nunca a sessão de serviço do Worker.

## Consequências

- Toda mudança em build/runtime que toque acesso externo deve revalidar
  `docs/ACESSO_EXTERNO_CONTROLADO.md` e a estratégia de Workers VPC descrita em
  `docs/ACESSO_EXTERNO_WORKERS_VPC.md`.
- DTIC Mobile segue o mesmo padrão com Worker próprio
  (`tool/external-access/workers-vpc-dtic/`), não reaproveita a sessão elevada do
  Worker SIS.
- Qualquer proposta futura de reintroduzir bridge USB/LAN/`adb reverse`/proxy de
  notebook deve ser tratada como regressão desta decisão, não como alternativa válida.

## Referências

- `docs/ACESSO_EXTERNO_CONTROLADO.md` — estratégia completa e critérios de escolha por
  cenário.
- `docs/ACESSO_EXTERNO_WORKERS_VPC.md` — arquitetura de primeira fase (Worker, Workers
  VPC, Tunnel).
- `docs/PILOTO_CLOUDFLARE_PASS_THROUGH.md` — playbook histórico/fallback de
  pass-through com hostname próprio.
- `docs/PLANO_ESTABILIZACAO_ACESSO_EXTERNO.md` — plano operacional de estabilização do
  tunnel e hostname.
