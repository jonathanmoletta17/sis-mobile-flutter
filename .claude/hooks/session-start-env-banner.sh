#!/usr/bin/env bash
set -euo pipefail

# Detecta se a sessao roda no host WSL canonico deste projeto ou em outra
# modalidade de ambiente (ex.: Claude Code on the web / container efemero), e avisa
# quais validacoes (Android, GLPI direto via VPN/intranet, scripts PowerShell) sao
# fisicamente possiveis aqui. Sem isso, nada impede um agente de tentar ou alegar
# ter executado um passo que o ambiente atual nao suporta.
#
# Ver docs/RUNTIME_CANONICO_E_VALIDACAO.md e BOOTSTRAP.md para o modelo hibrido
# completo assumido no host canonico.

CANONICAL_ROOT="/home/jonathan/projects/work/mobile/sis-mobile-flutter"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if [ "$PROJECT_DIR" = "$CANONICAL_ROOT" ]; then
  MSG="[ambiente] Host WSL canonico detectado ($PROJECT_DIR). Modelo hibrido de BOOTSTRAP.md aplica: Android/emulador/adb via camada Windows host, GLPI interno acessivel via rede interna/VPN, gate visual via PowerShell tambem disponivel."
else
  MSG="[ambiente] Sessao rodando FORA do host WSL canonico deste projeto (cwd=$PROJECT_DIR; canonico esperado=$CANONICAL_ROOT). Provavelmente INDISPONIVEIS nesta sessao: build/emulador/adb Android, acesso direto a rede interna/VPN do GLPI, scripts PowerShell do host Windows. Antes de tentar essas validacoes, confirme a capacidade real do ambiente; se nao for possivel executa-las, declare isso explicitamente em vez de presumir sucesso. Tipicamente possivel aqui: ler/editar codigo, flutter analyze/test, git, geracao de relatorios e documentacao."
fi

ESCAPED="$(printf '%s' "$MSG" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESCAPED"
