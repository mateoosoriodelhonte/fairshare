import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/money/money.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/insights.dart';
import '../../domain/models/models.dart';
import '../../ui/charts/insights_panel.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../expenses/expense_list.dart';
import '../io/export_import.dart';
import 'group_editor_sheet.dart';
import 'member_sheets.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(groupSnapshotProvider(groupId));
    return snapshot.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline_rounded, title: 'Could not load group', message: '$e'),
      ),
      data: (s) {
        if (s == null) {
          return PageScaffold(
            title: 'Group not found',
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'This group no longer exists',
                  message: 'It may have been deleted.',
                  action: FilledButton(
                    onPressed: () => context.go(Routes.dashboard),
                    child: const Text('Back to overview'),
                  ),
                ),
              ),
            ],
          );
        }
        return _GroupBody(snapshot: s);
      },
    );
  }
}

class _GroupBody extends ConsumerWidget {
  const _GroupBody({required this.snapshot});

  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = snapshot.group;
    final canAddExpense = snapshot.members.length >= 2;
    return PageScaffold(
      title: g.name,
      fab: canAddExpense
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => context.navigateTo(Routes.newExpense(g.id)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            )
          : null,
      titleWidget: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(g.emoji, style: const TextStyle(fontSize: 30, height: 1)),
          const SizedBox(width: FsSpace.md),
          Expanded(
            child: Text(g.name, style: context.text.headlineLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      subtitle:
          '${snapshot.members.length} ${snapshot.members.length == 1 ? 'member' : 'members'} · ${g.baseCurrency.code}',
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Group options',
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                await showGroupEditor(context, existing: g, canChangeCurrency: snapshot.isEmpty);
              case 'export-json':
                await exportGroupJson(context, ref, snapshot);
              case 'export-expenses':
                await exportGroupCsv(context, ref, snapshot, CsvReport.expenses);
              case 'export-balances':
                await exportGroupCsv(context, ref, snapshot, CsvReport.balances);
              case 'export-settlements':
                await exportGroupCsv(context, ref, snapshot, CsvReport.settlements);
              case 'delete':
                final ok = await confirmDestructive(
                  context,
                  title: 'Delete ${g.name}?',
                  message:
                      'All ${snapshot.expenses.length} expenses and ${snapshot.settlements.length} settlements in this group will be deleted. This cannot be undone.',
                );
                if (!ok) return;
                await ref.read(groupRepositoryProvider).deleteGroup(g.id);
                if (context.mounted) context.go(Routes.dashboard);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit group')),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'export-json',
              child: ListTile(leading: Icon(Icons.ios_share_rounded), title: Text('Export group (JSON)')),
            ),
            PopupMenuItem(
              value: 'export-expenses',
              child: ListTile(leading: Icon(Icons.table_chart_outlined), title: Text('Export expenses (CSV)')),
            ),
            PopupMenuItem(
              value: 'export-balances',
              child: ListTile(leading: Icon(Icons.balance_rounded), title: Text('Export balances (CSV)')),
            ),
            PopupMenuItem(
              value: 'export-settlements',
              child: ListTile(leading: Icon(Icons.swap_horiz_rounded), title: Text('Export payments (CSV)')),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(leading: Icon(Icons.delete_outline_rounded), title: Text('Delete group')),
            ),
          ],
        ),
      ],
      slivers: [
        SliverBox(
          children: [
            _SummaryCard(snapshot: snapshot),
            SectionHeader(
              'Members',
              trailing: TextButton.icon(
                onPressed: () => showMemberEditor(context, groupId: g.id),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add'),
              ),
            ),
            if (snapshot.members.isEmpty)
              Card(
                child: EmptyState(
                  compact: true,
                  icon: Icons.people_outline_rounded,
                  title: 'Nobody here yet',
                  message: 'Add the people who will share expenses.',
                  action: FilledButton.tonal(
                    onPressed: () => showMemberEditor(context, groupId: g.id),
                    child: const Text('Add member'),
                  ),
                ),
              )
            else
              FsListCard(
                children: [for (final m in snapshot.members) _MemberRow(snapshot: snapshot, member: m)],
              ),
            SectionHeader(
              'Expenses',
              trailing: TextButton.icon(
                onPressed: () => context.navigateTo(Routes.recurring(g.id)),
                icon: const Icon(Icons.event_repeat_rounded, size: 18),
                label: Text(
                  snapshot.templates.isEmpty
                      ? 'Recurring'
                      : 'Recurring (${snapshot.templates.where((t) => t.isActive).length})',
                ),
              ),
            ),
            if (snapshot.expenses.isEmpty)
              Card(
                child: EmptyState(
                  compact: true,
                  icon: Icons.receipt_long_outlined,
                  title: 'No expenses yet',
                  message: canAddExpense
                      ? 'Record what someone paid and how it should be split.'
                      : 'Add at least two members to start splitting.',
                  action: canAddExpense
                      ? FilledButton.tonal(
                          onPressed: () => context.navigateTo(Routes.newExpense(g.id)),
                          child: const Text('Add expense'),
                        )
                      : null,
                ),
              )
            else
              ExpenseList(snapshot: snapshot),
            if (snapshot.expenses.isNotEmpty) ...[
              const SectionHeader('Spending'),
              InsightsPanel(
                insights: SpendingInsights.compute([snapshot], currency: g.baseCurrency, now: DateTime.now()),
                showStats: false,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.snapshot});

  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final b = snapshot.balances;
    final outstanding = Money.sum(b.creditors.map((c) => c.balance), b.currency);
    return FsCard(
      child: Row(
        children: [
          Expanded(
            child: _Stat(label: 'Total spent', money: b.totalSpent),
          ),
          Container(width: 1, height: 40, color: context.palette.hairline),
          const SizedBox(width: FsSpace.lg),
          Expanded(
            child: _Stat(
              label: 'Outstanding',
              money: outstanding,
              caption: outstanding.isZero ? 'Everyone is settled' : 'Across all members',
            ),
          ),
          if (snapshot.members.length >= 2)
            FilledButton.tonal(
              onPressed: () => context.navigateTo(Routes.settle(snapshot.group.id)),
              child: const Text('Settle up'),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.money, this.caption});

  final String label;
  final Money money;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: context.text.labelSmall?.copyWith(letterSpacing: 0.6)),
        const SizedBox(height: FsSpace.xs),
        AnimatedMoneyText(money, style: context.text.headlineSmall),
        if (caption != null) ...[const SizedBox(height: 2), Text(caption!, style: context.text.bodySmall)],
      ],
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.snapshot, required this.member});

  final GroupSnapshot snapshot;
  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = snapshot.balances.balanceOf(member.id);
    final String status;
    if (balance.isZero) {
      status = 'Settled up';
    } else if (balance.isPositive) {
      status = 'Is owed';
    } else {
      status = 'Owes';
    }
    return ListTile(
      leading: MemberAvatar(member: member),
      title: Text(member.name),
      subtitle: Text(status),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(balance.abs(), colored: !balance.isZero, style: context.text.titleMedium),
          PopupMenuButton<String>(
            tooltip: 'Member options',
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  showMemberEditor(context, groupId: member.groupId, existing: member);
                case 'remove':
                  deleteMemberWithConfirmation(context, ref, member);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }
}
