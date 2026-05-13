import 'package:flutter/material.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/theme/app_colors.dart';
import 'package:sis_mobile_flutter/theme/app_radius.dart';
import 'package:sis_mobile_flutter/theme/app_spacing.dart';
import 'package:sis_mobile_flutter/theme/app_status.dart';
import 'package:sis_mobile_flutter/widgets/ui/glpi_app_navigation.dart';
import 'package:sis_mobile_flutter/widgets/ui/glpi_login_surface.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_empty_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_loading_state.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_page_scaffold.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_section_header.dart';
import 'package:sis_mobile_flutter/widgets/ui/sis_status_chip.dart';

import '../workbench_surface.dart';

enum DticLoginSurfaceVariant { idle, loading, failure }

enum DticCatalogSurfaceVariant { ready, loading, empty }

enum DticTicketsSurfaceVariant { populated, filteredEmpty, loading, error }

enum DticConversationsSurfaceVariant { populated, empty, loading }

enum DticTicketDetailSurfaceVariant {
  readOnly,
  responseEnabled,
  closed,
  loading,
}

class DticLoginSurfacePreview extends StatelessWidget {
  const DticLoginSurfacePreview({super.key, required this.variant});

  final DticLoginSurfaceVariant variant;

  bool get _isLoading => variant == DticLoginSurfaceVariant.loading;
  bool get _hasFailure => variant == DticLoginSurfaceVariant.failure;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: GlpiLoginSurface(
        badge: 'GLPI DTIC',
        title: 'DTIC Mobile',
        description:
            'Acesse o atendimento DTIC com seu usuario de rede e senha do GLPI.',
        footer: 'Autenticacao segura via GLPI DTIC',
        brandMark: const GlpiLoginBrandIcon(icon: Icons.verified_user_outlined),
        children: [
          TextFormField(
            initialValue: _isLoading || _hasFailure ? 'usuario.rede' : '',
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Usuario de rede',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: _isLoading || _hasFailure ? 'secret' : '',
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: Icon(Icons.visibility_outlined),
            ),
          ),
          if (_hasFailure) ...[
            const SizedBox(height: AppSpacing.md),
            const GlpiLoginInlineNotice(
              message:
                  'Falha na autenticacao DTIC. Verifique usuario, senha e acesso ao Worker.',
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {},
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.login),
            label: Text(_isLoading ? 'Entrando...' : 'Entrar'),
          ),
        ],
      ),
    );
  }
}

class DticCatalogSurfacePreview extends StatelessWidget {
  const DticCatalogSurfacePreview({super.key, required this.variant});

  final DticCatalogSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'DTIC Mobile',
        subtitle: 'Casa Civil RS > DTIC',
        bottomNavigationBar: GlpiAppNavigationBar(
          current: GlpiAppSection.services,
          destinations: dticShellDestinations(),
          onDestinationSelected: (_) {},
        ),
        actions: [
          IconButton(
            tooltip: 'Meus chamados',
            onPressed: () {},
            icon: const Icon(Icons.confirmation_number_outlined),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () {},
            icon: const Icon(Icons.logout),
          ),
        ],
        body: switch (variant) {
          DticCatalogSurfaceVariant.loading => const SisLoadingState(
            title: 'Carregando catalogo DTIC',
            message: 'Lendo atendimentos disponiveis no GLPI DTIC.',
          ),
          DticCatalogSurfaceVariant.empty => const _CatalogEmptyState(),
          DticCatalogSurfaceVariant.ready => const _CatalogReadyBody(),
        },
      ),
    );
  }
}

class DticTicketsSurfacePreview extends StatelessWidget {
  const DticTicketsSurfacePreview({super.key, required this.variant});

  final DticTicketsSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Meus chamados DTIC',
        subtitle: 'usuario.rede',
        bottomNavigationBar: GlpiAppNavigationBar(
          current: GlpiAppSection.tickets,
          destinations: dticShellDestinations(),
          onDestinationSelected: (_) {},
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
        body: switch (variant) {
          DticTicketsSurfaceVariant.loading => const SisLoadingState(
            title: 'Carregando chamados',
            message: 'Consultando tickets do usuario logado.',
          ),
          DticTicketsSurfaceVariant.error => SisEmptyState(
            icon: Icons.error_outline,
            title: 'Falha ao carregar chamados',
            message:
                'O Worker DTIC respondeu com erro ao consultar a fila do usuario.',
            actionLabel: 'Tentar novamente',
            onAction: () {},
          ),
          DticTicketsSurfaceVariant.filteredEmpty => const _TicketsBody(
            filteredEmpty: true,
          ),
          DticTicketsSurfaceVariant.populated => const _TicketsBody(),
        },
      ),
    );
  }
}

class DticConversationsSurfacePreview extends StatelessWidget {
  const DticConversationsSurfacePreview({super.key, required this.variant});

  final DticConversationsSurfaceVariant variant;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Conversas DTIC',
        subtitle: 'Chamados em andamento e novas atividades',
        bottomNavigationBar: GlpiAppNavigationBar(
          current: GlpiAppSection.conversations,
          destinations: dticShellDestinations(),
          onDestinationSelected: (_) {},
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
        body: switch (variant) {
          DticConversationsSurfaceVariant.loading => const SisLoadingState(
            title: 'Carregando conversas',
            message: 'Consultando chamados em andamento.',
          ),
          DticConversationsSurfaceVariant.empty => const _ConversationsBody(
            empty: true,
          ),
          DticConversationsSurfaceVariant.populated =>
            const _ConversationsBody(),
        },
      ),
    );
  }
}

class DticTicketDetailSurfacePreview extends StatelessWidget {
  const DticTicketDetailSurfacePreview({super.key, required this.variant});

  final DticTicketDetailSurfaceVariant variant;

  bool get _canRespond =>
      variant == DticTicketDetailSurfaceVariant.responseEnabled;
  bool get _isClosed => variant == DticTicketDetailSurfaceVariant.closed;

  @override
  Widget build(BuildContext context) {
    return WorkbenchSurface(
      fullBleed: true,
      child: SisPageScaffold(
        title: 'Chamado #1042',
        subtitle: _canRespond ? 'Atendimento DTIC' : 'Historico e anexos',
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
        body: switch (variant) {
          DticTicketDetailSurfaceVariant.loading => const SisLoadingState(
            title: 'Carregando chamado',
            message: 'Buscando detalhe, mensagens, solucoes e anexos.',
          ),
          DticTicketDetailSurfaceVariant.readOnly ||
          DticTicketDetailSurfaceVariant.responseEnabled ||
          DticTicketDetailSurfaceVariant.closed => _DetailBody(
            canRespond: _canRespond,
            isClosed: _isClosed,
          ),
        },
      ),
    );
  }
}

class _ConversationsBody extends StatelessWidget {
  const _ConversationsBody({this.empty = false});

  final bool empty;

  @override
  Widget build(BuildContext context) {
    final tickets = empty
        ? const <_DtcTicketFixture>[]
        : _dticTickets
              .where(
                (ticket) =>
                    GlpiStatusMapper.isOpenForInteraction(ticket.status),
              )
              .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const TextField(
          decoration: InputDecoration(
            hintText: 'Buscar conversa',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (tickets.isEmpty)
          const SisEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Nenhuma conversa ativa',
            message: 'Chamados abertos e em atendimento aparecerão aqui.',
          )
        else
          for (final ticket in tickets) ...[
            _TicketCard(
              ticket: ticket,
              surfaceColor: ticket.unread
                  ? AppColors.brandSoft
                  : AppStatusPalette.resolve(
                      AppStatusPalette.fromGlpiStatus(ticket.status),
                    ).surface,
              accentColor: AppStatusPalette.resolve(
                AppStatusPalette.fromGlpiStatus(ticket.status),
              ).foreground,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _CatalogReadyBody extends StatelessWidget {
  const _CatalogReadyBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const _CatalogHero(formCount: 9, ticketCount: 6),
        const SizedBox(height: AppSpacing.lg),
        SisSectionHeader(
          title: 'Solicitacoes disponiveis',
          subtitle: 'Escolha o atendimento que deseja abrir.',
          trailing: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.list_alt),
            label: const Text('6 chamados'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final form in _dticForms) _DticFormCard(form: form),
      ],
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        _CatalogHero(formCount: 0, ticketCount: 0),
        SizedBox(height: AppSpacing.lg),
        SisEmptyState(
          icon: Icons.assignment_outlined,
          title: 'Nenhum formulario ativo',
          message: 'O catalogo DTIC nao retornou formularios ativos.',
        ),
      ],
    );
  }
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({required this.formCount, required this.ticketCount});

  final int formCount;
  final int ticketCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent_outlined,
            color: AppColors.textInverse,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central DTIC',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$formCount solicitacoes ativas | $ticketCount chamados recentes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textOnBrandMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DticFormCard extends StatelessWidget {
  const _DticFormCard({required this.form});

  final _DticFormFixture form;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.infoSoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(Icons.dynamic_form_outlined, color: AppColors.info),
        ),
        title: Text(form.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            '${form.fields} campos | ${form.required} obrigatorios | ${form.files} anexos',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _TicketsBody extends StatelessWidget {
  const _TicketsBody({this.filteredEmpty = false});

  final bool filteredEmpty;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _TicketFilters(filteredCount: filteredEmpty ? 0 : 6, totalCount: 6),
        const SizedBox(height: AppSpacing.md),
        if (filteredEmpty)
          const SisEmptyState(
            icon: Icons.search_off_outlined,
            title: 'Nenhum chamado nos filtros',
            message:
                'Ajuste a busca ou limpe os filtros para ver a lista completa.',
          )
        else ...[
          _TicketGroup(
            label: 'Novo',
            tickets: _dticTickets
                .where((ticket) => ticket.status == GlpiStatus.novo.code)
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          _TicketGroup(
            label: 'Em atendimento',
            tickets: _dticTickets
                .where(
                  (ticket) => ticket.status == GlpiStatus.emAtendimento.code,
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          _TicketGroup(
            label: 'Solucionado',
            tickets: _dticTickets
                .where((ticket) => ticket.status == GlpiStatus.solucionado.code)
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _TicketFilters extends StatelessWidget {
  const _TicketFilters({required this.filteredCount, required this.totalCount});

  final int filteredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Buscar chamado, categoria ou requerente',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const _FilterPill(
                icon: Icons.filter_alt_outlined,
                label: 'Todos os status',
              ),
              const _FilterPill(
                icon: Icons.category_outlined,
                label: 'Todas as categorias',
              ),
              Text(
                '$filteredCount/$totalCount',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketGroup extends StatelessWidget {
  const _TicketGroup({required this.label, required this.tickets});

  final String label;
  final List<_DtcTicketFixture> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return const SizedBox.shrink();
    final tone = AppStatusPalette.fromGlpiStatus(tickets.first.status);
    final visuals = AppStatusPalette.resolve(tone);

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          iconColor: visuals.foreground,
          collapsedIconColor: AppColors.textMuted,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          title: Row(
            children: [
              Expanded(child: Text(label)),
              SisStatusChip(label: '${tickets.length}', tone: tone),
            ],
          ),
          children: [
            for (final ticket in tickets)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _TicketCard(
                  ticket: ticket,
                  surfaceColor: visuals.surface,
                  accentColor: visuals.foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.surfaceColor,
    required this.accentColor,
  });

  final _DtcTicketFixture ticket;
  final Color surfaceColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ticket.unread ? AppColors.brandSoft : surfaceColor,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Text(
                  ticket.id,
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (ticket.unread)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.4),
                  ),
                ),
              ),
          ],
        ),
        title: Text(ticket.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  SisStatusChip(
                    label: GlpiStatusMapper.label(ticket.status),
                    tone: AppStatusPalette.fromGlpiStatus(ticket.status),
                  ),
                  _MetaPill(icon: Icons.schedule_outlined, label: ticket.date),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ticket.category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.canRespond, required this.isClosed});

  final bool canRespond;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    final status = isClosed
        ? GlpiStatus.fechado.code
        : GlpiStatus.emAtendimento.code;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acesso ao sistema SEI',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    SisStatusChip(
                      label: GlpiStatusMapper.label(status),
                      tone: AppStatusPalette.fromGlpiStatus(status),
                    ),
                    SisStatusChip(
                      label: isClosed
                          ? 'Chamado encerrado'
                          : canRespond
                          ? 'Acoes habilitadas'
                          : 'Historico e anexos',
                      tone: canRespond
                          ? AppStatusTone.info
                          : AppStatusTone.neutral,
                    ),
                    const _MetaPill(
                      icon: Icons.category_outlined,
                      label: 'Sistemas internos',
                    ),
                    const _MetaPill(
                      icon: Icons.person_outline,
                      label: 'Requerente: usuario.rede',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _FieldSummary(),
              ],
            ),
          ),
        ),
        if (canRespond) ...[
          const SizedBox(height: AppSpacing.md),
          const _ResponsePanel(),
        ],
        const SizedBox(height: AppSpacing.md),
        const SisSectionHeader(title: 'Anexos'),
        const SizedBox(height: AppSpacing.sm),
        const _DocumentCard(
          name: 'comprovante-acesso.pdf',
          meta: 'Chamado | application/pdf',
          icon: Icons.insert_drive_file_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        const SisSectionHeader(title: 'Historico'),
        const SizedBox(height: AppSpacing.sm),
        const _InteractionCard(
          kind: 'Mensagem',
          author: 'Atendimento DTIC',
          date: '03/05/2026 14:20',
          content: 'Solicitamos confirmar a lotacao para concluir o acesso.',
          tone: AppStatusTone.info,
        ),
        _InteractionCard(
          kind: 'Solucao',
          author: 'Equipe DTIC',
          date: isClosed ? '03/05/2026 16:05' : 'Aguardando validacao',
          content: isClosed
              ? 'Acesso concedido e validado pelo requerente.'
              : 'A solicitacao esta em atendimento pela equipe responsavel.',
          tone: isClosed ? AppStatusTone.success : AppStatusTone.warning,
        ),
      ],
    );
  }
}

class _ResponsePanel extends StatelessWidget {
  const _ResponsePanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Acoes do chamado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(Icons.chat_bubble_outline),
                  label: Text('Mensagem'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.task_alt_outlined),
                  label: Text('Solucao'),
                ),
              ],
              selected: const {0},
              onSelectionChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Em Atendimento atual'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync_outlined),
                  label: const Text('Marcar Pendente'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const TextField(
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Mensagem',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.attach_file),
              label: const Text('Anexos selecionados: 2'),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _SelectedAttachmentTile(
              name: 'print-erro-sei.png',
              size: '482.0 KB',
            ),
            const _SelectedAttachmentTile(
              name: 'oficio-solicitacao.pdf',
              size: '1.8 MB',
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar mensagem'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAttachmentTile extends StatelessWidget {
  const _SelectedAttachmentTile({required this.name, required this.size});

  final String name;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(size),
          trailing: IconButton(
            tooltip: 'Remover anexo',
            onPressed: () {},
            icon: const Icon(Icons.close),
          ),
        ),
      ),
    );
  }
}

class _FieldSummary extends StatelessWidget {
  const _FieldSummary();

  @override
  Widget build(BuildContext context) {
    const fields = [
      MapEntry('Sistema', 'SEI'),
      MapEntry('Tipo de acesso', 'Perfil basico'),
      MapEntry('Lotacao', 'Casa Civil'),
      MapEntry('Justificativa', 'Novo servidor precisa acessar processos.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 124,
                  child: Text(
                    field.key,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(field.value)),
              ],
            ),
          ),
      ],
    );
  }
}

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({
    required this.kind,
    required this.author,
    required this.date,
    required this.content,
    required this.tone,
  });

  final String kind;
  final String author;
  final String date;
  final String content;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SisStatusChip(label: kind, tone: tone),
                const Spacer(),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              author,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.name,
    required this.meta,
    required this.icon,
  });

  final String name;
  final String meta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brandDark),
        title: Text(name),
        subtitle: Text(meta),
        trailing: IconButton(
          tooltip: 'Abrir anexo',
          onPressed: () {},
          icon: const Icon(Icons.open_in_new),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutralSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DticFormFixture {
  const _DticFormFixture({
    required this.name,
    required this.fields,
    required this.required,
    required this.files,
  });

  final String name;
  final int fields;
  final int required;
  final int files;
}

class _DtcTicketFixture {
  const _DtcTicketFixture({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    required this.date,
    this.unread = false,
  });

  final String id;
  final String title;
  final int status;
  final String category;
  final String date;
  final bool unread;
}

const _dticForms = [
  _DticFormFixture(name: 'AJUDA - SEI', fields: 8, required: 5, files: 0),
  _DticFormFixture(name: 'INCIDENTE', fields: 12, required: 7, files: 1),
  _DticFormFixture(name: 'REQUISICAO', fields: 10, required: 6, files: 1),
  _DticFormFixture(name: 'IMPRESSORA', fields: 14, required: 9, files: 1),
];

const _dticTickets = [
  _DtcTicketFixture(
    id: '1042',
    title: 'Acesso ao sistema SEI',
    status: 1,
    category: 'Sistemas internos > SEI',
    date: '03/05/2026',
    unread: true,
  ),
  _DtcTicketFixture(
    id: '1039',
    title: 'Instalacao de impressora no gabinete',
    status: 2,
    category: 'Infraestrutura > Impressora',
    date: '02/05/2026',
  ),
  _DtcTicketFixture(
    id: '1034',
    title: 'Recuperacao de acesso ao email',
    status: 5,
    category: 'Office 365 > Email',
    date: '30/04/2026',
  ),
];
