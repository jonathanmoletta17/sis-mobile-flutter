# Plano de Testes Completo - SIS Mobile Flutter MVP

**Objetivo:** Validar TODAS as funcionalidades, fluxos e interações do app de ponta a ponta.

**Data:** 2026-06-14  
**Status:** Ready for Manual/Automated Testing  
**Ambiente:** GLPI SIS Real

---

## 1. AUTENTICAÇÃO & SESSÃO

### 1.1 Login com Credenciais Válidas (Requerente)
**Pré-requisito:** Credenciais válidas de requerente no GLPI SIS  
**Ações:**
1. Abrir app
2. Inserir username/password válidos (ex: `solicitante_teste`)
3. Tap "Entrar"

**Resultado Esperado:**
- ✅ Login bem-sucedido
- ✅ Tela de catálogo de serviços é exibida
- ✅ Username do usuário é salvo em estado local
- ✅ Session token armazenado

---

### 1.2 Login com Credenciais Inválidas
**Pré-requisito:** Nenhum  
**Ações:**
1. Inserir username/password inválidos
2. Tap "Entrar"

**Resultado Esperado:**
- ✅ Mensagem de erro em português exibida
- ✅ Usuário permanece na tela de login
- ✅ Sem acesso ao app

---

### 1.3 Login com Usuário Técnico
**Pré-requisito:** Credenciais válidas de técnico no GLPI  
**Ações:**
1. Inserir credenciais de técnico (ex: `tecnico_manutencao`)
2. Tap "Entrar"

**Resultado Esperado:**
- ✅ Login bem-sucedido
- ✅ Acesso a fila técnica disponível
- ✅ Papel técnico identificado corretamente

---

### 1.4 Sessão Expirada - Redirecionamento para Login
**Pré-requisito:** App aberto, aguardar token expirar (~30 min)  
**Ações:**
1. Tentar executar qualquer ação que requer autenticação
2. Ou deixar app aberto por período longo

**Resultado Esperado:**
- ✅ Redirecionamento automático para tela de login
- ✅ Mensagem "Sessão expirada" (se aplicável)
- ✅ Dados locais preserved (offline tickets não perdidos)

---

### 1.5 Logout
**Pré-requisito:** Usuário logado  
**Ações:**
1. Acessar menu > Logout (se houver)
2. OU: Forçar via reinicialização do app

**Resultado Esperado:**
- ✅ Redirecionamento para tela de login
- ✅ Session token removido
- ✅ Dados persistentes (offline tickets) preservados

---

## 2. CATÁLOGO & SELEÇÃO DE SERVIÇO

### 2.1 Carregar Catálogo Governado
**Pré-requisito:** Usuário logado, conexão internet  
**Ações:**
1. Login bem-sucedido
2. Observar carregamento da tela de catálogo

**Resultado Esperado:**
- ✅ Catálogo carrega dinamicamente do GLPI
- ✅ Sub-serviços (CONSERVAÇÃO, MANUTENÇÃO, GG) são exibidos
- ✅ Cada serviço mostra ícone correto
- ✅ Sem lag/travamento

---

### 2.2 Visualizar Serviço do Catálogo
**Pré-requisito:** Catálogo carregado  
**Ações:**
1. Tap em um serviço (ex: CONSERVAÇÃO)

**Resultado Esperado:**
- ✅ Detalhes do serviço são exibidos
- ✅ Descrição é visible
- ✅ Próximo botão ("Criar Chamado") está disponível

---

### 2.3 Selecionar Sub-serviço (em Serviço Agregado)
**Pré-requisito:** Serviço agregado selecionado (ex: CONSERVAÇÃO)  
**Ações:**
1. Observar opções de sub-serviço
2. Selecionar um sub-serviço (ex: "Limpeza")

**Resultado Esperado:**
- ✅ Sub-serviço é selecionado visualmente
- ✅ Próxima etapa (formulário) usa sub-serviço correto

---

### 2.4 Pesquisar/Filtrar Serviço
**Pré-requisito:** Catálogo carregado  
**Ações:**
1. Usar campo de busca (se existir)
2. Digitar nome do serviço (ex: "Limpeza")

**Resultado Esperado:**
- ✅ Resultados filtrados em tempo real
- ✅ Apenas serviços relevantes são exibidos
- ✅ Sem resultados → mensagem apropriada

---

## 3. CRIAÇÃO DE TICKET - REQUERENTE

### 3.1 Criar Ticket Simples (Online)
**Pré-requisito:** Usuário requerente logado, conexão internet  
**Ações:**
1. Selecionar serviço do catálogo
2. Preencher campos obrigatórios:
   - Assunto: "Problema com ar condicionado"
   - Categoria: Selecionar "TI"
   - Localização: Selecionar "Sala 101"
3. Tap "Enviar"

**Resultado Esperado:**
- ✅ Ticket criado no GLPI (ID visível no app)
- ✅ Mensagem de sucesso: "✅ Chamado enviado com sucesso! ID: XXXXX"
- ✅ Ticket aparece imediatamente em "Meus Chamados"
- ✅ Entidade do usuário preservada

---

### 3.2 Criar Ticket com Anexo
**Pré-requisito:** Em tela de criação de ticket  
**Ações:**
1. Preencher campos obrigatórios
2. Tap "Anexar Arquivo"
3. Selecionar imagem/documento da galeria
4. Tap "Enviar"

**Resultado Esperado:**
- ✅ Arquivo anexado visualmente na tela
- ✅ Tamanho do arquivo exibido (ex: "2.5 MB")
- ✅ Ticket criado COM o anexo no GLPI
- ✅ Arquivo é visível no ticket no GLPI

---

### 3.3 Criar Ticket Sem Preencher Campo Obrigatório
**Pré-requisito:** Em tela de criação de ticket  
**Ações:**
1. Deixar campo obrigatório em branco (ex: Assunto)
2. Tap "Enviar"

**Resultado Esperado:**
- ✅ Validação de campo dispara
- ✅ Mensagem de erro: "Campo obrigatório: Assunto"
- ✅ Ticket NÃO é criado
- ✅ Dados preenchidos são preservados

---

### 3.4 Criar Ticket Offline
**Pré-requisito:** Internet desativada, usuário logado  
**Ações:**
1. Desativar internet (airplane mode)
2. Preencher e tentar enviar ticket

**Resultado Esperado:**
- ✅ Ticket é salvo localmente como "Pendente (Offline)"
- ✅ Aparece em "Meus Chamados" com badge "Offline"
- ✅ Mensagem: "Ticket salvo localmente. Será sincronizado quando conectado."
- ✅ Dados não são perdidos

---

### 3.5 Sincronizar Ticket Offline
**Pré-requisito:** Ticket criado offline, internet restaurada  
**Ações:**
1. Ativar internet novamente
2. App detecta conectividade
3. Observar sincronização automática

**Resultado Esperado:**
- ✅ Ticket offline é sincronizado com GLPI
- ✅ ID real do GLPI é recebido
- ✅ Badge "Offline" é removido
- ✅ Ticket agora aparece como "Online"
- ✅ Entidade preservada (mesmo que criado offline)

---

### 3.6 Criar Ticket com Seleção de Beneficiário (Para Terceiro)
**Pré-requisito:** Usuário logado, formulário suporta seleção de beneficiário  
**Ações:**
1. Em tela de criação, selecionar "Criar para Terceiro"
2. Buscar beneficiário (ex: "João Silva")
3. Selecionar da lista

**Resultado Esperado:**
- ✅ Beneficiário selecionado é exibido
- ✅ Ticket criado com requester = beneficiário (não o usuário logado)
- ✅ Campo de busca busca usuários GLPI em tempo real

---

## 4. VISUALIZAÇÃO DE TICKET

### 4.1 Visualizar Ticket Pessoal (Requerente)
**Pré-requisito:** Requerente tem ticket criado  
**Ações:**
1. Tap em "Meus Chamados"
2. Selecionar um ticket da lista

**Resultado Esperado:**
- ✅ Tela de detalhe do ticket é exibida
- ✅ Informações visíveis:
  - ID do ticket
  - Assunto
  - Status (ex: "Novo")
  - Data de criação
  - Requester (usuário)
  - Categoria
  - Localização
- ✅ Sem erro ao carregar

---

### 4.2 Visualizar Conversação/Histórico do Ticket
**Pré-requisito:** Ticket selecionado, tem mensagens  
**Ações:**
1. Em detalhe do ticket, scroll para "Conversação"
2. Observar mensagens

**Resultado Esperado:**
- ✅ Todas as mensagens/acompanhamentos são exibidos
- ✅ Ordem cronológica (mais antigas primeiro ou último?)
- ✅ Nomes dos autores visíveis
- ✅ Datas/horários corretos
- ✅ Sem caracteres garbled (UTF-8 correto)

---

### 4.3 Visualizar Anexos do Ticket
**Pré-requisito:** Ticket tem anexos  
**Ações:**
1. Em detalhe do ticket, procurar seção de "Anexos"
2. Tap em um anexo

**Resultado Esperado:**
- ✅ Lista de anexos é exibida
- ✅ Nomes de arquivo visíveis
- ✅ Tamanhos visíveis
- ✅ Download/visualização funciona (se implementado)

---

### 4.4 Visualizar Ticket de Outro Usuário (Não Proprietário)
**Pré-requisito:** Usuário técnico, ticket de outro requerente  
**Ações:**
1. Login como técnico
2. Acessar fila de tickets
3. Selecionar ticket criado por outro usuário

**Resultado Esperado:**
- ✅ Técnico pode visualizar o ticket
- ✅ Informações completas são exibidas
- ✅ Sem erro de permissão

---

### 4.5 Tentar Visualizar Ticket Sem Permissão
**Pré-requisito:** Outro requerente (não proprietário, não técnico)  
**Ações:**
1. Login como requerente A
2. Tentar acessar ticket de requerente B (hack: URL direto, se app tiver)

**Resultado Esperado:**
- ✅ Acesso negado (permissão verificada)
- ✅ Mensagem de erro apropriada: "Você não tem permissão para acessar este ticket"
- ✅ Redirecionamento para "Meus Chamados"

---

## 5. INTERAÇÃO COM TICKET - REQUERENTE

### 5.1 Enviar Acompanhamento (Followup)
**Pré-requisito:** Ticket em status "Novo" ou "Em Andamento", requerente é proprietário  
**Ações:**
1. Em detalhe do ticket, scroll para "Adicionar Acompanhamento"
2. Digitar mensagem: "Problema persiste"
3. Tap "Enviar"

**Resultado Esperado:**
- ✅ Mensagem é enviada ao GLPI
- ✅ Aparece imediatamente em "Conversação" (com timestamp)
- ✅ Nome do autor é o requerente
- ✅ Sem erro na API

---

### 5.2 Tentar Enviar Acompanhamento em Ticket Resolvido
**Pré-requisito:** Ticket em status "Solucionado"  
**Ações:**
1. Tentar acessar campo de acompanhamento

**Resultado Esperado:**
- ✅ Campo está DESABILITADO/ESCONDIDO
- ✅ Mensagem: "Conversação encerrada. Para retomar, contacte o suporte."
- ✅ Botão de envio não está disponível

---

### 5.3 Anexar Arquivo a Acompanhamento
**Pré-requisito:** Em tela de acompanhamento, ticket é "Novo" ou "Em Andamento"  
**Ações:**
1. Tap "Anexar Arquivo"
2. Selecionar imagem/PDF
3. Digitar mensagem
4. Tap "Enviar"

**Resultado Esperado:**
- ✅ Acompanhamento é criado COM anexo
- ✅ Arquivo é visível no GLPI
- ✅ Aparece na conversação com ícone de anexo

---

### 5.4 Editar Acompanhamento Próprio (Se Implementado)
**Pré-requisito:** Requerente tem mensagem enviada por ele  
**Ações:**
1. Long-press na própria mensagem
2. Tap "Editar"
3. Modificar texto
4. Tap "Salvar"

**Resultado Esperado:**
- ✅ Mensagem é atualizada no GLPI
- ✅ Badge "(editado)" aparece na mensagem
- ✅ Timestamp original preservado

---

### 5.5 Tentar Editar Mensagem de Outro Usuário
**Pré-requisito:** Requerente vê mensagem de técnico  
**Ações:**
1. Long-press na mensagem de outro usuário
2. Procurar opção "Editar"

**Resultado Esperado:**
- ✅ Opção "Editar" NÃO está disponível
- ✅ Apenas "Visualizar" ou similar
- ✅ Sem error

---

## 6. SOLUÇÃO & VALIDAÇÃO

### 6.1 Técnico Propõe Solução
**Pré-requisito:** Técnico logado, ticket em status "Em Andamento"  
**Ações:**
1. Em detalhe do ticket, procurar botão "Propor Solução"
2. Digitar texto da solução: "Reinicie o computador"
3. Tap "Enviar Solução"

**Resultado Esperado:**
- ✅ Solução é criada no GLPI
- ✅ Aparece como "Solução Proposta" na conversação
- ✅ Ticket permanece em "Em Andamento" (ou muda para "Solucionado"?)
- ✅ Requerente recebe notificação (se implementado)

---

### 6.2 Requerente Aprova Solução
**Pré-requisito:** Técnico propôs solução, ticket em status "Solucionado"  
**Ações:**
1. Requerente acessa o ticket
2. Observa card de "Solução Proposta"
3. Tap "Aprovar"

**Resultado Esperado:**
- ✅ Solução é aprovada
- ✅ Ticket muda para status "Fechado"
- ✅ Botão de aprovar desaparece
- ✅ Badge "✅ Aprovada" aparece no card
- ✅ Mensagem: "Solução aprovada. O chamado foi fechado."

---

### 6.3 Requerente Recusa Solução
**Pré-requisito:** Técnico propôs solução, ticket em "Solucionado"  
**Ações:**
1. Requerente acessa o ticket
2. Tap "Recusar"
3. Digitar justificativa: "Problema persiste"
4. Opcionalmente anexar arquivo
5. Tap "Enviar Recusa"

**Resultado Esperado:**
- ✅ Recusa é registrada no GLPI
- ✅ Mensagem com justificativa aparece na conversação
- ✅ Ticket volta para "Em Andamento"
- ✅ Badge "❌ Recusada" aparece no card de solução

---

### 6.4 Requerente Tenta Aprovar Solução Sem Permissão
**Pré-requisito:** Requerente NÃO é o proprietário do ticket, ticket tem solução  
**Ações:**
1. Outro requerente acessa o ticket (se conseguir)
2. Procura botão de "Aprovar"

**Resultado Esperado:**
- ✅ Botão "Aprovar" está DESABILITADO
- ✅ Mensagem: "Apenas o criador do chamado pode validar a solução"

---

### 6.5 Solução Proposta em Ticket Não Solucionado
**Pré-requisito:** Técnico tenta propor solução, ticket em "Em Andamento"  
**Ações:**
1. Técnico tenta propor solução
2. OU: Verifica se botão "Propor Solução" está visível

**Resultado Esperado:**
- ✅ Botão de "Propor Solução" está VISÍVEL (técnico pode propor)
- ✅ Ao enviar, requerente pode validar quando ticket for "Solucionado"

---

## 7. MUDANÇA DE STATUS

### 7.1 Técnico Muda Status: Novo → Em Andamento
**Pré-requisito:** Técnico logado, ticket em "Novo"  
**Ações:**
1. Em detalhe do ticket, procurar "Mudar Status"
2. Selecionar "Em Andamento"
3. Tap "Confirmar"

**Resultado Esperado:**
- ✅ Status muda no GLPI em tempo real
- ✅ Exibido no app: "Status: Em Andamento"
- ✅ Cor do status muda visualmente (se houver)

---

### 7.2 Técnico Muda Status: Em Andamento → Solucionado
**Pré-requisito:** Ticket em "Em Andamento"  
**Ações:**
1. Mudar status para "Solucionado"

**Resultado Esperado:**
- ✅ Status muda
- ✅ Se há solução proposta, aparece card "Aguardando aprovação do requerente"
- ✅ Requerente agora pode validar

---

### 7.3 Requerente Tenta Mudar Status
**Pré-requisito:** Requerente logado, proprietário do ticket  
**Ações:**
1. Procurar opção "Mudar Status"
2. OU: Tentar acessar dropdown de status

**Resultado Esperado:**
- ✅ Opção NÃO está disponível (ou está desabilitada)
- ✅ Requerente NÃO pode mudar status manualmente
- ✅ Status só muda através de ações válidas (validação de solução, etc.)

---

### 7.4 Status Transitions Inválidas
**Pré-requisito:** Ticket em qualquer status  
**Ações:**
1. Tentar transicionar para status inválido
   - Ex: De "Novo" para "Fechado" (pulando status intermediários)

**Resultado Esperado:**
- ✅ Transição é bloqueada
- ✅ Mensagem de erro: "Status não permitido nesta sequência"
- ✅ Status válidos são listados (ex: "Novo → Em Andamento, Planejado, Pendente")

---

## 8. ATRIBUIÇÃO & TÉCNICOS

### 8.1 Auto-atribuir Ticket (Técnico)
**Pré-requisito:** Técnico visualiza ticket em "Novo", mudança de status para "Em Andamento"  
**Ações:**
1. Técnico muda status para "Em Andamento"
2. Observa se há checkbox "Auto-atribuir"
3. Marcar checkbox
4. Confirmar

**Resultado Esperado:**
- ✅ Ticket é atribuído ao técnico automaticamente
- ✅ Campo "Atribuído a" mostra nome do técnico
- ✅ No GLPI, técnico aparece como "Atribuído"

---

### 8.2 Remover Atribuição (Técnico)
**Pré-requisito:** Ticket atribuído ao técnico  
**Ações:**
1. Em detalhe do ticket, tap em "Atribuído a: [Nome]"
2. Selecionar "Remover Atribuição"

**Resultado Esperado:**
- ✅ Atribuição é removida
- ✅ Campo "Atribuído a" fica vazio ou mostra "Não atribuído"
- ✅ Ticket volta para fila pública

---

### 8.3 Reatribuir para Outro Técnico
**Pré-requisito:** Ticket está atribuído, supervisor/técnico senior logado  
**Ações:**
1. Tap em "Atribuído a"
2. Buscar outro técnico
3. Selecionar e confirmar

**Resultado Esperado:**
- ✅ Atribuição é transferida
- ✅ Campo mostra novo técnico
- ✅ Histórico preservado no GLPI

---

## 9. FILAS & FILTROS

### 9.1 Visualizar Fila "Meus Chamados" (Requerente)
**Pré-requisito:** Requerente logado  
**Ações:**
1. Tap na aba "Meus Chamados"
2. Observar lista

**Resultado Esperado:**
- ✅ Apenas tickets criados por esse requerente aparecem
- ✅ Total de tickets exibido (ex: "3 chamados")
- ✅ Cada ticket mostra: ID, Assunto, Status, Data

---

### 9.2 Visualizar Fila Técnica (Técnico)
**Pré-requisito:** Técnico logado, domínio correto  
**Ações:**
1. Tap na aba "Fila Técnica" (ou similar)
2. Observar tickets não atribuídos

**Resultado Esperado:**
- ✅ Tickets da fila técnica aparecem
- ✅ Apenas tickets do domínio do técnico (ex: Conservação)
- ✅ Tickets atribuídos a outros técnicos NÃO aparecem

---

### 9.3 Visualizar Fila Operacional (Se Implementada)
**Pré-requisito:** Usuário com acesso, tickets na fila operacional  
**Ações:**
1. Procurar aba "Fila Operacional"
2. Tap

**Resultado Esperado:**
- ✅ Seção "Fila Operacional" mostra tickets com badge âmbar
- ✅ Diferente da fila pessoal (cor, agrupamento)

---

### 9.4 Filtrar Tickets por Status
**Pré-requisito:** Lista de tickets visível  
**Ações:**
1. Procurar opção de filtro
2. Selecionar status "Em Andamento"
3. Observar lista atualizada

**Resultado Esperado:**
- ✅ Apenas tickets em "Em Andamento" são exibidos
- ✅ Outros status desaparecem
- ✅ Contador atualiza (ex: "5 em andamento")

---

### 9.5 Filtrar Tickets por Categoria
**Pré-requisito:** Lista de tickets visível  
**Ações:**
1. Procurar dropdown/filtro de categoria
2. Selecionar categoria (ex: "TI")
3. Observar

**Resultado Esperado:**
- ✅ Apenas tickets da categoria aparecem
- ✅ Sem erro ao filtrar

---

### 9.6 Ordenar Tickets por Data
**Pré-requisito:** Lista de tickets visível  
**Ações:**
1. Procurar opção de ordenação
2. Selecionar "Mais Recente" ou "Mais Antigo"

**Resultado Esperado:**
- ✅ Tickets reordenados corretamente
- ✅ Mais recentes aparecem primeiro (ou configurado)

---

## 10. BUSCA

### 10.1 Buscar Ticket por ID
**Pré-requisito:** Usuário na lista de tickets  
**Ações:**
1. Usar campo de busca
2. Digitar ID do ticket (ex: "1234")

**Resultado Esperado:**
- ✅ Ticket com ID correspondente é exibido
- ✅ Sem outras tickets
- ✅ Busca em tempo real (sem delay)

---

### 10.2 Buscar Ticket por Assunto
**Pré-requisito:** Campo de busca visível  
**Ações:**
1. Digitar parte do assunto (ex: "ar condicionado")

**Resultado Esperado:**
- ✅ Tickets com "ar condicionado" no assunto aparecem
- ✅ Busca é case-insensitive
- ✅ Sem caracteres garbled no resultado

---

### 10.3 Buscar Ticket por Categoria
**Pré-requisito:** Campo de busca visível  
**Ações:**
1. Digitar nome de categoria (ex: "Infraestrutura")

**Resultado Esperado:**
- ✅ Tickets da categoria aparecem
- ✅ OU: Dropdown de categorias aparece

---

### 10.4 Limpar Busca
**Pré-requisito:** Busca ativa  
**Ações:**
1. Tap no "X" para limpar campo de busca

**Resultado Esperado:**
- ✅ Campo é limpo
- ✅ Lista volta para estado anterior (sem filtros)

---

## 11. OFFLINE & SINCRONIZAÇÃO

### 11.1 Criar Ticket Offline & Sincronizar
**Pré-requisito:** Internet desativada, usuário logado  
**Ações:**
1. Desativar internet (airplane mode)
2. Criar ticket normalmente
3. Ativar internet
4. Observar sincronização

**Resultado Esperado:**
- ✅ Ticket criado offline é salvo localmente
- ✅ Ao restaurar internet, sincronização ocorre
- ✅ Ticket recebe ID real do GLPI
- ✅ Status muda de "Offline" para "Online"

---

### 11.2 Enviar Acompanhamento Offline
**Pré-requisito:** Internet desativada, ticket já existe online  
**Ações:**
1. Abrir ticket online
2. Desativar internet
3. Enviar acompanhamento
4. Ativar internet

**Resultado Esperado:**
- ✅ Acompanhamento é salvo localmente
- ✅ Badge indica status "Pendente (Offline)"
- ✅ Ao sincronizar, aparece no GLPI
- ✅ Sem duplicação ou erro

---

### 11.3 Sincronizar Lista de Tickets
**Pré-requisito:** Vários tickets offline  
**Ações:**
1. Ativar internet
2. Observar sincronização automática

**Resultado Esperado:**
- ✅ Todos os tickets são sincronizados
- ✅ IDs reais são recebidos
- ✅ Sem erro mesmo com muitos tickets

---

### 11.4 Conflito de Sincronização (Se Implementado)
**Pré-requisito:** Ticket editado tanto localmente (offline) quanto no GLPI (por outro usuário)  
**Ações:**
1. Criar cenário de conflito (if possible)
2. Sincronizar

**Resultado Esperado:**
- ✅ Conflito é detectado
- ✅ Usuário é alertado
- ✅ Opção para manter versão local ou servidor
- ✅ Sem perda de dados

---

### 11.5 Offline Indicator
**Pré-requisito:** Internet desativada  
**Ações:**
1. Observar interface do app

**Resultado Esperado:**
- ✅ Ícone/indicador de "Offline" está visível
- ✅ Botões que requerem internet estão desabilitados
- ✅ Mensagem "Você está offline" (se aplicável)

---

## 12. VALIDAÇÃO DE REGRAS

### 12.1 Requerente Não Pode Propor Solução
**Pré-requisito:** Requerente logado  
**Ações:**
1. Acessar ticket
2. Procurar botão "Propor Solução"

**Resultado Esperado:**
- ✅ Botão NÃO está visível
- ✅ Apenas técnicos podem propor

---

### 12.2 Requerente NÃO Pode Mudar Status
**Pré-requisito:** Requerente proprietário do ticket  
**Ações:**
1. Procurar opção "Mudar Status"

**Resultado Esperado:**
- ✅ Opção NÃO disponível
- ✅ Status é controlado apenas por técnicos

---

### 12.3 Requerente Não Pode Atribuir Ticket
**Pré-requisito:** Requerente logado  
**Ações:**
1. Procurar opção "Atribuir Técnico"

**Resultado Esperado:**
- ✅ Opção NÃO disponível

---

### 12.4 Técnico Não Pode Validar Solução
**Pré-requisito:** Técnico visualiza solução proposta (criada por outro técnico)  
**Ações:**
1. Procurar botão "Aprovar Solução"

**Resultado Esperado:**
- ✅ Botão NÃO está disponível
- ✅ Apenas requerente pode validar

---

### 12.5 Ticket Fechado é Read-Only
**Pré-requisito:** Ticket em status "Fechado"  
**Ações:**
1. Tentar enviar acompanhamento
2. Tentar anexar arquivo

**Resultado Esperado:**
- ✅ Campo de acompanhamento está desabilitado
- ✅ Botão "Anexar" está desabilitado
- ✅ Histórico é visível (read-only)

---

## 13. ENTRADA DE DADOS & VALIDAÇÃO

### 13.1 Caracteres Especiais no Assunto
**Pré-requisito:** Em tela de criação de ticket  
**Ações:**
1. Assunto: "Problema com @ # $ % & especiais"
2. Enviar

**Resultado Esperado:**
- ✅ Caracteres especiais são aceitos
- ✅ Ticket criado corretamente
- ✅ No GLPI, caracteres aparecem intactos

---

### 13.2 Caracteres Acentuados (UTF-8)
**Pré-requisito:** Em tela de criação  
**Ações:**
1. Assunto: "Problêma com áir condicionadõr"
2. Enviar

**Resultado Esperado:**
- ✅ Acentos são preservados
- ✅ No GLPI, aparecem corretamente (não garbled)
- ✅ Sem erros de encoding

---

### 13.3 Limite de Caracteres
**Pré-requisito:** Campo de assunto/descrição  
**Ações:**
1. Digitar muito texto (ex: 5000 caracteres)
2. Tentar enviar

**Resultado Esperado:**
- ✅ Se houver limite, validação dispara (ex: "Máximo 255 caracteres")
- ✅ OU: Aceita tudo e envia com sucesso

---

### 13.4 Whitespace e Caracteres Invisíveis
**Pré-requisito:** Campo de assunto  
**Ações:**
1. Assunto: "   Espaços no início e fim   "
2. Enviar

**Resultado Esperado:**
- ✅ Trimming automático (espaços removidos)
- ✅ OU: Aceita como enviado
- ✅ Sem erro

---

## 14. PERFORMANCE & ESTABILIDADE

### 14.1 Carregar Lista com 100+ Tickets
**Pré-requisito:** Usuário com muitos tickets  
**Ações:**
1. Acessar "Meus Chamados"
2. Observar carregamento

**Resultado Esperado:**
- ✅ Lista carrega (com ou sem paginação)
- ✅ Sem travamento
- ✅ Scroll é fluido

---

### 14.2 Abrir Ticket com 50+ Mensagens
**Pré-requisito:** Ticket com muitas mensagens  
**Ações:**
1. Abrir detalhe do ticket
2. Scroll através de mensagens

**Resultado Esperado:**
- ✅ Todas as mensagens carregam
- ✅ Sem lag ao scroll
- ✅ Sem crash

---

### 14.3 Enviar Mensagem Muito Longa
**Pré-requisito:** Em tela de acompanhamento  
**Ações:**
1. Digitar 10,000 caracteres
2. Enviar

**Resultado Esperado:**
- ✅ Mensagem é enviada
- ✅ No GLPI, aparece completa
- ✅ Sem truncamento não intencional

---

### 14.4 Abrir App Após 1 Hora Inativo
**Pré-requisito:** App deixado aberto  
**Ações:**
1. Deixar app aberto por 1 hora
2. Retornar ao app
3. Tentar executar ação

**Resultado Esperado:**
- ✅ Token ainda é válido (ou solicitado login)
- ✅ Dados offline não foram perdidos
- ✅ App não ficou em estado broken

---

## 15. NOTIFICAÇÕES & ALERTAS

### 15.1 Notificação de Novo Acompanhamento
**Pré-requisito:** Técnico envia acompanhamento, requerente tem app aberto  
**Ações:**
1. Técnico envia mensagem
2. Observar app do requerente

**Resultado Esperado:**
- ✅ Notificação é exibida (banner, badge, push - se implementado)
- ✅ Ticket atualiza em tempo real ou próximo refresh

---

### 15.2 Notificação de Mudança de Status
**Pré-requisito:** Técnico muda status, requerente tem app  
**Ações:**
1. Técnico muda para "Solucionado"
2. Observar notificação no requerente

**Resultado Esperado:**
- ✅ Requerente é notificado
- ✅ App atualiza status automaticamente (ou na próxima refresh)

---

## 16. DESIGN & UX

### 16.1 Layout Responsivo (Diferentes Tamanhos de Tela)
**Pré-requisito:** App rodando em diferentes dispositivos (ou orientação)  
**Ações:**
1. Rodar em telefone pequeno (5 polegadas)
2. Rodar em telefone grande (6.5 polegadas)
3. Mudar para landscape (se suportado)

**Resultado Esperado:**
- ✅ Layout se adapta sem quebras
- ✅ Botões e campos estão acessíveis
- ✅ Sem texto cortado ou sobreposto

---

### 16.2 Temas Escuro/Claro (Se Implementado)
**Pré-requisito:** Sistema tem modo escuro  
**Ações:**
1. Ativar modo escuro do sistema
2. Abrir app
3. Observar tema

**Resultado Esperado:**
- ✅ App muda para tema escuro
- ✅ Texto é legível
- ✅ Contraste adequado

---

### 16.3 Ícones e Cores Consistentes
**Pré-requisito:** App aberto  
**Ações:**
1. Observar ícones (status, ações, etc.)
2. Verificar cores (status "Novo" sempre verde?)

**Resultado Esperado:**
- ✅ Ícones são consistentes em toda a app
- ✅ Cores representam estados de forma consistente
- ✅ Sem cores aleatórias ou confusas

---

## 17. ACESSIBILIDADE

### 17.1 Tamanho de Fonte Aumentado (Se Suportado)
**Pré-requisito:** Sistema com tamanho de fonte grande  
**Ações:**
1. Aumentar tamanho de fonte do sistema
2. Abrir app
3. Ler texto

**Resultado Esperado:**
- ✅ App respeita tamanho de fonte do sistema
- ✅ Sem corte de texto
- ✅ Layout não quebra

---

### 17.2 Navigation com Teclado (Android)
**Pré-requisito:** Teclado externo conectado  
**Ações:**
1. Usar Tab para navegar entre elementos
2. Usar Enter para clicar

**Resultado Esperado:**
- ✅ Navegação funciona
- ✅ Foco visual é claro (highlight)

---

## 18. SEGURANÇA

### 18.1 Password Não é Exibida em Texto Claro
**Pré-requisito:** Em tela de login  
**Ações:**
1. Digitar password
2. Observar campo

**Resultado Esperado:**
- ✅ Password é mascarada com pontos/asteriscos
- ✅ Sem caracteres visíveis

---

### 18.2 Session Token Não é Exibido no Código/Logs
**Pré-requisito:** App logado  
**Ações:**
1. Checar logs de debug (adb logcat, if Android)
2. Procurar token

**Resultado Esperado:**
- ✅ Token não aparece em logs
- ✅ OU: Apenas primeiros/últimos caracteres (truncado)

---

### 18.3 HTTPS para Todas as Requisições
**Pré-requisito:** App rodando  
**Ações:**
1. Capturar requisições de rede (Burp Suite, Charles, etc.)
2. Verificar protocolo

**Resultado Esperado:**
- ✅ Todas as requisições usam HTTPS (não HTTP)
- ✅ Sem certificado auto-assinado não confiável (ou é do GLPI)

---

## 19. INTEGRAÇÃO GLPI

### 19.1 Ticket Criado no App Aparece no GLPI Web
**Pré-requisito:** Ticket criado no app  
**Ações:**
1. Acessar GLPI web
2. Procurar o ticket pelo ID

**Resultado Esperado:**
- ✅ Ticket aparece no GLPI
- ✅ Todos os campos estão corretos
- ✅ Anexos estão presentes

---

### 19.2 Acompanhamento Adicionado no App Aparece no GLPI
**Pré-requisito:** Acompanhamento enviado do app  
**Ações:**
1. Abrir ticket no GLPI web
2. Procurar a mensagem na aba "Histórico" ou "Acompanhamento"

**Resultado Esperado:**
- ✅ Mensagem aparece
- ✅ Autor correto
- ✅ Timestamp correto

---

### 19.3 Mudança de Status no App é Refletida no GLPI
**Pré-requisito:** Status mudado no app  
**Ações:**
1. Abrir mesmo ticket no GLPI web
2. Verificar status

**Resultado Esperado:**
- ✅ Status é o mesmo que foi definido no app
- ✅ Sem delay (ou delay aceitável)

---

### 19.4 Validação de Solução no App Fecha Ticket no GLPI
**Pré-requisito:** Solução aprovada no app  
**Ações:**
1. Abrir ticket no GLPI web
2. Verificar status e histórico

**Resultado Esperado:**
- ✅ Ticket está em "Fechado"
- ✅ Histórico mostra aprovação
- ✅ Sem erro

---

## 20. CENÁRIOS EDGE CASE

### 20.1 Criar Ticket com Anexo Muito Grande (>50MB)
**Pré-requisito:** Arquivo grande disponível  
**Ações:**
1. Tentar anexar arquivo grande
2. Enviar

**Resultado Esperado:**
- ✅ Validação detecta: "Arquivo muito grande (máximo X MB)"
- ✅ OU: Permite envio com feedback de progresso
- ✅ Sem crash

---

### 20.2 Criar Ticket Simultâneo em Múltiplos Dispositivos
**Pré-requisito:** Mesmo usuário logado em 2 dispositivos  
**Ações:**
1. Criar ticket no dispositivo A
2. Criar ticket no dispositivo B (simultaneamente)

**Resultado Esperado:**
- ✅ Ambos os tickets são criados
- ✅ IDs diferentes
- ✅ Sem conflito

---

### 20.3 Atualizar Categorias no GLPI Enquanto App Está Aberto
**Pré-requisito:** App aberto em catálogo  
**Ações:**
1. No GLPI web, adicionar nova categoria
2. No app, atualizar catálogo (refresh)

**Resultado Esperado:**
- ✅ Nova categoria aparece no app
- ✅ Sem restart do app necessário

---

### 20.4 GLPI Fora do Ar Enquanto App Tenta Sincronizar
**Pré-requisito:** GLPI momentaneamente indisponível  
**Ações:**
1. Parar GLPI
2. App tenta sincronizar/fazer requisição
3. Iniciar GLPI novamente
4. App detecta conectividade

**Resultado Esperado:**
- ✅ App mostra erro graceful: "Servidor indisponível. Tente novamente."
- ✅ Dados offline são preservados
- ✅ Ao sincronizar novamente, tudo funciona

---

### 20.5 Ticket Deletado no GLPI Enquanto Aberto no App
**Pré-requisito:** Ticket aberto, admin deleta no GLPI  
**Ações:**
1. Abrir ticket no app
2. Deletar ticket no GLPI web (admin)
3. Tentar atualizar/refrescar no app

**Resultado Esperado:**
- ✅ App mostra erro: "Ticket não encontrado"
- ✅ Redirecionamento para lista de tickets
- ✅ Sem crash

---

## 21. REGRESSÃO CHECKLIST

### 21.1 Encoding UTF-8 (Regressão de Correção Anterior)
**Pré-requisito:** App rodando  
**Ações:**
1. Criar ticket com acentos: "Condicionador de ár"
2. Enviar
3. Verificar no GLPI

**Resultado Esperado:**
- ✅ Acentos aparecem corretamente no GLPI (não como garbled)
- ✅ Sem `Ã©` ou outros caracteres corrompidos

---

### 21.2 Solution Validation (Feature Habilitada)
**Pré-requisito:** Técnico propôs solução, requerente logado  
**Ações:**
1. Requerente tenta aprovar solução
2. Observar se botão está disponível

**Resultado Esperado:**
- ✅ Botão "Aprovar" está VISÍVEL
- ✅ Botão "Recusar" está VISÍVEL
- ✅ Sem mensagem "Recurso indisponível"

---

## TABELA DE RESUMO

| # | Funcionalidade | Teste | Status |
|---|---|---|---|
| 1.1 | Login Válido | ✓ | [ ] |
| 1.2 | Login Inválido | ✓ | [ ] |
| 1.3 | Login Técnico | ✓ | [ ] |
| 1.4 | Sessão Expirada | ✓ | [ ] |
| 1.5 | Logout | ✓ | [ ] |
| 2.1 | Carregar Catálogo | ✓ | [ ] |
| ... | ... | ... | ... |
| 21.2 | Solution Validation | ✓ | [ ] |

---

## INSTRUÇÕES DE USO

1. **Para cada teste:** Marque [X] na coluna "Status" após completar
2. **Se falhar:** Anote o erro, print de tela, e ID do teste
3. **Ambiente:** GLPI SIS Real (servidor interno ou staging)
4. **Usuários de teste:**
   - Requerente: `solicitante_teste` / `senha123`
   - Técnico (Conservação): `tecnico_cons` / `senha123`
   - Técnico (Manutenção): `tecnico_manu` / `senha123`
5. **Relatório:** Compile todos os resultados em um documento

---

**Total de Testes:** ~150+ cenários  
**Tempo Estimado:** 4-6 horas (teste manual completo)  
**Prioridade:** Crítica para MVP
