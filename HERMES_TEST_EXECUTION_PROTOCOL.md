# Protocolo de Execução de Testes - Hermes

**Objetivo:** Hermes executar automaticamente 150+ testes do SIS Mobile Flutter MVP contra GLPI SIS real.

**Data:** 2026-06-14  
**Responsável:** Hermes (Agente Automatizado)  
**Escopo:** Teste ponta a ponta com validações de segurança  
**Ambiente:** GLPI SIS Real (Produção com restrições)

---

## 🔐 REGRAS DE SEGURANÇA (CRÍTICAS)

### Restrição 1: Criação de Tickets
- **MÁXIMO 2 tickets podem ser criados durante toda a execução de testes**
- Tickets adicionais devem ser rejeitados com erro
- Estes 2 tickets serão usados para validar TODAS as funcionalidades
- Nenhum outro usuário deve ter seus dados alterados

### Restrição 2: Operações Read-Only
- **PADRÃO:** Apenas leitura
- **EXCEÇÃO:** Apenas as 2 criações de ticket + interações neles (followup, status, validação)
- **BLOQUEADO:** Delete, Update de ticket de outro usuário, Bulk operations

### Restrição 3: Usuários Autorizados
```
✅ PERMITIDO USAR:
  - solicitante_teste (requerente de teste)
  - tecnico_manutencao (técnico de manutenção)
  - jonathan-moletta (admin/supervisor - confirmado pelo usuário)

❌ BLOQUEADO:
  - Qualquer outro usuário
  - Modificar dados de usuários existentes
```

### Restrição 4: Dados Existentes
- **NUNCA alterar** tickets existentes criados por outros usuários
- **NUNCA deletar** dados do GLPI
- **NUNCA modificar** categorias, localizações, ou metadados
- **APENAS** interagir com os 2 tickets de teste criados por Hermes

---

## 📋 PLANO DE EXECUÇÃO

### Fase 1: Preparação (5 minutos)
1. [ ] Verificar credenciais de acesso ao GLPI SIS
2. [ ] Verificar acesso à app SIS Mobile Flutter (Android/iOS emulador ou device real)
3. [ ] Confirmar conectividade com GLPI
4. [ ] Listar usuários disponíveis para teste

### Fase 2: Testes de Autenticação (10 minutos)
**Testes a executar:** #1.1 a #1.5 (5 testes)

```
1.1 Login com Requerente (solicitante_teste)
    - [ ] Login bem-sucedido
    - [ ] Catálogo carregado
    
1.2 Login com Técnico (tecnico_manutencao)
    - [ ] Login bem-sucedido
    - [ ] Fila técnica acessível
    
1.3 Login com Admin (jonathan-moletta)
    - [ ] Login bem-sucedido
    - [ ] Acesso completo confirmado
    
1.4 Logout
    - [ ] Logout funciona
    - [ ] Dados locais preservados
    
1.5 Sessão expirada
    - [ ] Detectada corretamente
    - [ ] Re-login funciona
```

**Resultado esperado:** 5/5 testes passarem

### Fase 3: Criação de Tickets (15 minutos)
**Testes a executar:** #3.1 a #3.5 (5 testes, cria 2 tickets)

```
TICKET #1 (Requerente - solicitante_teste):
  3.1 Criar ticket online
      - Assunto: "HERMES_TEST_001 - Problema com equipamento"
      - Categoria: TI
      - Localização: Sala 101
      - [ ] Ticket criado (salvar ID para referência)
      - [ ] Aparece em "Meus Chamados"
      
  3.2 Criar com anexo (opcional)
      - [ ] Anexo salvo corretamente

TICKET #2 (Requerente - solicitante_teste):
  3.3 Criar ticket com validação de campo obrigatório
      - [ ] Campo obrigatório detectado
      - [ ] Validação funciona
      
  3.5 Criar com seleção de sub-serviço
      - Assunto: "HERMES_TEST_002 - Limpeza de workspace"
      - Sub-serviço: Limpeza (CONSERVAÇÃO)
      - [ ] Ticket criado (salvar ID)
      - [ ] Sub-serviço preservado no GLPI

**REGRA:** Parar criação após 2 tickets. Rejeitar qualquer tentativa adicional.
**Resultado esperado:** 2 tickets criados, IDs registrados
```

### Fase 4: Visualização & Interação (20 minutos)
**Testes a executar:** #4.1 a #5.3 (10 testes)

**COM TICKET #1:**
```
4.1 Visualizar detalhe
    - [ ] Todas informações exibidas
    - [ ] Status é "Novo"
    
4.2 Visualizar conversação (vazia inicialmente)
    - [ ] Seção existe
    - [ ] Sem mensagens
    
5.1 Enviar acompanhamento
    - Mensagem: "HERMES: Acompanhamento #1 - Problema confirmado"
    - [ ] Mensagem enviada
    - [ ] Aparece na conversação
    - [ ] Timestamp correto
    
5.3 Anexar arquivo a acompanhamento
    - [ ] Arquivo anexado
    - [ ] Visível no GLPI
```

**COM TICKET #2:**
```
Repetir 4.1, 4.2, 5.1 com ticket #2
```

**Resultado esperado:** 10/10 testes passarem

### Fase 5: Mudança de Status (15 minutos)
**Testes a executar:** Login como técnico, manipular status dos 2 tickets

**IMPORTANTE:** Hermes deve trocar de usuário para técnico para este teste

```
COM TICKET #1 (técnico logado):
  7.1 Mudar status: Novo → Em Andamento
      - [ ] Status muda no app
      - [ ] Status muda no GLPI
      
  7.2 Mudar status: Em Andamento → Solucionado
      - [ ] Status muda
      - [ ] Card de "Aguardando validação" aparece
      
COM TICKET #2 (técnico logado):
  7.1 Mudar para Em Andamento
      - [ ] Status refletido
```

**Resultado esperado:** Status transitions funcionando

### Fase 6: Solução & Validação (15 minutos)
**Testes a executar:** #6.1 a #6.3 (3 testes)

```
COM TICKET #1 (solucionado):
  6.1 Técnico propõe solução
      - [ ] Solução criada
      - [ ] Card "Solução Proposta" aparece
      
  6.2 Requerente aprova solução
      - Login como solicitante_teste
      - [ ] Botão "Aprovar" visível
      - [ ] Tap "Aprovar"
      - [ ] Ticket fecha (status → Fechado)
      - [ ] Badge "✅ Aprovada" aparece

COM TICKET #2 (solucionado):
  6.3 Requerente recusa solução
      - [ ] Botão "Recusar" visível
      - [ ] Tap "Recusar"
      - [ ] Justificativa: "HERMES: Solução não resolveu problema"
      - [ ] Mensagem com justificativa registrada
      - [ ] Ticket volta a "Em Andamento"
```

**Resultado esperado:** 3/3 testes passarem

### Fase 7: Offline & Sincronização (10 minutos)
**Testes a executar:** #11.1 a #11.2 (2 testes)

```
7.1 Simular offline
    - [ ] Modo offline ativado (ou conexão desativada)
    - [ ] Indicador "Offline" visível
    
7.2 Enviar acompanhamento offline em Ticket #1
    - Mensagem: "HERMES: Mensagem offline"
    - [ ] Salvo localmente
    - [ ] Badge "Pendente (Offline)"
    
7.3 Restaurar conexão
    - [ ] Sincronização automática ocorre
    - [ ] Badge removido
    - [ ] Mensagem aparece no GLPI
```

**Resultado esperado:** Sincronização funciona

### Fase 8: Validação de Regras (10 minutos)
**Testes a executar:** #12.1 a #12.5 (5 testes)

```
12.1 Requerente tenta propor solução
    - [ ] Botão NÃO visível
    
12.2 Requerente tenta mudar status
    - [ ] Opção NÃO disponível
    
12.3 Requerente tenta atribuir ticket
    - [ ] Opção NÃO disponível
    
12.4 Ticket fechado é read-only
    - [ ] Campo de acompanhamento desabilitado
    - [ ] Botão "Anexar" desabilitado

12.5 Técnico tenta validar solução de outro
    - [ ] Botão "Aprovar" NÃO disponível
```

**Resultado esperado:** 5/5 regras validadas

### Fase 9: Entrada de Dados (10 minutos)
**Testes a executar:** #13.1 a #13.4 (4 testes)

```
9.1 Caracteres especiais (@#$%&) em acompanhamento
    - Mensagem: "HERMES: Teste@#$%& especiais"
    - [ ] Caracteres preservados no GLPI
    
9.2 Caracteres acentuados (UTF-8)
    - Mensagem: "HERMES: Tëstê áçéñtös"
    - [ ] Acentos corretos no GLPI (não garbled)
    
9.3 Mensagem longa (1000+ caracteres)
    - [ ] Enviada completamente
    - [ ] No GLPI, aparece intacta
    
9.4 Whitespace (espaços início/fim)
    - Mensagem: "   HERMES: Teste com espaços   "
    - [ ] Trimming automático OU aceita como é
    - [ ] Sem erro
```

**Resultado esperado:** 4/4 testes passarem

### Fase 10: Busca & Filtros (10 minutos)
**Testes a executar:** #9 e #10 (10 testes)

```
10.1 Buscar TICKET #1 por ID
    - [ ] Encontrado
    - [ ] Exatamente 1 resultado
    
10.2 Buscar por assunto "HERMES_TEST"
    - [ ] Ambos tickets aparecem
    
10.3 Filtrar por status "Solucionado"
    - [ ] Ambos tickets aparecem
    
10.4 Filtrar por status "Em Andamento"
    - [ ] Apenas TICKET #2
    
10.5 Ordenar por data (mais recente)
    - [ ] TICKET #2 aparece primeiro
```

**Resultado esperado:** 10/10 testes passarem

### Fase 11: Integração GLPI (10 minutos)
**Testes a executar:** #19.1 a #19.4 (4 testes)

```
19.1 Verificar no GLPI Web
    - [ ] TICKET #1 existe
    - [ ] TICKET #2 existe
    - [ ] Todos os campos corretos
    - [ ] Acompanhamentos visíveis
    - [ ] Status corretos
    
19.2 Verificar anexos
    - [ ] Se houver, aparecem no GLPI
    
19.3 Verificar conversação
    - [ ] Todas as mensagens no GLPI
    - [ ] Autores corretos
    - [ ] Timestamps corretos
    
19.4 Verificar histórico de status
    - [ ] Novo → Em Andamento → Solucionado
    - [ ] Transições registradas
```

**Resultado esperado:** Sincronização perfeita com GLPI

### Fase 12: UTF-8 & Regressão (5 minutos)
**Testes a executar:** #21 (2 testes)

```
21.1 Verificar encoding UTF-8
    - [ ] Nenhum caractere garbled em nenhuma mensagem
    - [ ] Acentos aparecem corretamente
    
21.2 Verificar Solution Validation
    - [ ] Funcionalidade de aprovar/recusar habilitada
    - [ ] Trabalhando corretamente
```

**Resultado esperado:** 2/2 testes passarem

---

## 📊 RELATÓRIO FINAL

Hermes deve compilar um relatório com:

```
RESUMO EXECUTIVO
═════════════════════════════════════════════════════════

Execução: [Data/Hora início] → [Data/Hora fim]
Duração Total: [X horas Y minutos]
Ambiente: GLPI SIS Real
Executante: Hermes

RESULTADOS
═════════════════════════════════════════════════════════

Fase 1 (Preparação):        ✅ 4/4 passos
Fase 2 (Autenticação):      ✅ 5/5 testes
Fase 3 (Criação):           ✅ 5/5 testes (2 tickets criados)
Fase 4 (Visualização):      ✅ 10/10 testes
Fase 5 (Status):            ✅ [X/X] testes
Fase 6 (Solução):           ✅ [X/X] testes
Fase 7 (Offline):           ✅ [X/X] testes
Fase 8 (Regras):            ✅ [X/X] testes
Fase 9 (Entrada Dados):     ✅ [X/X] testes
Fase 10 (Busca):            ✅ [X/X] testes
Fase 11 (Integração GLPI):  ✅ [X/X] testes
Fase 12 (Regressão):        ✅ [X/X] testes
───────────────────────────────────────────────────────
TOTAL:                      ✅ [XX]/[XX] testes PASSARAM

TICKETS DE TESTE CRIADOS
═════════════════════════════════════════════════════════
TICKET #1:
  ID GLPI: [número]
  Assunto: HERMES_TEST_001 - Problema com equipamento
  Status Final: Fechado (Aprovado)
  Acompanhamentos: [N] mensagens

TICKET #2:
  ID GLPI: [número]
  Assunto: HERMES_TEST_002 - Limpeza de workspace
  Status Final: Em Andamento (Solução recusada)
  Acompanhamentos: [N] mensagens

ISSUES ENCONTRADAS
═════════════════════════════════════════════════════════
[Listar todos os problemas encontrados, se houver]
- [ ] Issue #1: [Descrição] (Bloqueante? Sim/Não)
- [ ] Issue #2: ...

SE NENHUM: "Nenhuma issue encontrada. MVP passa em todos os testes."

RECOMENDAÇÕES
═════════════════════════════════════════════════════════
[Qualquer comportamento inesperado ou otimização sugerida]

ASSINATURA
═════════════════════════════════════════════════════════
Executado por: Hermes
Data: [Data]
Validado por: [Seu nome]
Status Aprovação: [ ] Pronto para Produção / [ ] Retorno para Fix
```

---

## 🚨 SITUAÇÕES DE PARADA (ABORT CONDITIONS)

Hermes deve PARAR e relatar imediatamente se:

1. **Tentativa de 3º ticket**
   - Parar tudo
   - Relatar: "Limite de 2 tickets excedido"

2. **Erro ao acessar GLPI**
   - Parar tudo
   - Relatar: "GLPI inacessível: [erro específico]"

3. **Dados de outro usuário sendo alterados**
   - Parar tudo
   - Relatar: "Tentativa de modificar dados de outro usuário"

4. **Erro crítico no app (crash)**
   - Parar o teste
   - Documentar: Passo exato, erro, como reproduzir

5. **Caracteres corrompidos/garbled**
   - Documentar erro
   - Continuar (não é bloqueante)

---

## 📞 PERGUNTAS QUE VOCÊ PODE FAZER AO HERMES

Se quiser transmitir esse protocolo via chat/mensagem, use estas perguntas:

### Pergunta 1: Execução do Plano
```
"Hermes, você pode executar o protocolo de teste do SIS Mobile Flutter?
Arquivo: HERMES_TEST_EXECUTION_PROTOCOL.md

Resumo:
- Executar 12 fases de teste (Autenticação, Criação, Solução, etc)
- Criar APENAS 2 tickets de teste
- Usar apenas usuários autorizados: solicitante_teste, tecnico_manutencao
- Não alterar dados existentes
- Documentar resultado final em relatório

Pode começar?"
```

### Pergunta 2: Credenciais & Acesso
```
"Você tem acesso a:
- GLPI SIS (http://cau.ppiratini.intra.rs.gov.br/sis/apirest.php)
- Contas de teste: solicitante_teste, tecnico_manutencao
- Conta admin: jonathan-moletta
- App SIS Mobile Flutter (emulador/device)

Confirme que consegue acessar tudo antes de começar."
```

### Pergunta 3: Dúvidas Específicas
```
"Durante o teste, se encontrar situações ambíguas (ex: campo opcional que deveria ser obrigatório?), 
você deve:
1. Documentar
2. Continuar testando
3. NÃO parar o teste

Certo?"
```

### Pergunta 4: Relatório Final
```
"Após terminar todos os testes, envie:
1. Relatório completo (quantos testes passaram/falharam)
2. Screenshots de qualquer erro crítico
3. IDs dos 2 tickets criados
4. Recomendação: 'Pronto para produção' ou 'Retorno para fix'

Entendido?"
```

---

## ✅ CHECKLIST PARA VOCÊ

Antes de liberar Hermes:

- [ ] Leia e entendeu o protocolo?
- [ ] Hermes tem as 3 contas de teste?
  - [ ] solicitante_teste
  - [ ] tecnico_manutencao
  - [ ] jonathan-moletta
- [ ] Hermes tem acesso ao GLPI SIS?
- [ ] Hermes tem acesso ao app SIS Mobile Flutter?
- [ ] Hermes entendeu as 4 restrições de segurança?
- [ ] Hermes sabe parar em situações de ABORT?

---

## 🎯 RESULTADO ESPERADO

Se tudo passar:
- ✅ 70+ testes executados
- ✅ 0 tickets de outros usuários alterados
- ✅ 2 tickets de teste criados, completamente validados
- ✅ GLPI sincronizado perfeitamente
- ✅ UTF-8 sem corrupção
- ✅ Todas as regras de permissão funcionando
- ✅ **MVP pronto para produção**

---

**Você pode compartilhar este arquivo com Hermes ou formular as perguntas acima via chat.**
