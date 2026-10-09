import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../domain/accounting/accounting.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import 'balance_bars.dart';
import 'settlement_sheet.dart';

class SettleScreen extends ConsumerWidget {
  const SettleScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(groupSnapshotProvider(groupId));
    return snapshot.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline_rounded, title: 'Could not load', message: '$e'),
      ),
      data: (s) => s == null
          ? Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Group not found',
                message: 'It may have been deleted.',
              ),
            )
          : _SettleBody(snapshot: s),
    );
  }
}

class _SettleBody extends ConsumerWidget {
  const _SettleBody({required this.snapshot});

  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).value ?? const AppPreferences();
    final mode = prefs.settlementMode;
    final suggestions = snapshot.suggestions(mode);
    final settled = snapshot.balances.isSettled;
    final dateFormat = DateFormat.yMMMd();

    return PageScaffold(
      title: 'Settle up',
      subtitle: snapshot.group.name,
      actions: [
        // A wide labelled button would overlap the back button on phones.
        if (context.isCompact)
          IconButton(
            tooltip: 'Record payment',
            icon: const Icon(Icons.add_rounded),
            onPressed: snapshot.members.length < 2 ? null : () => showSettlementSheet(context, snapshot),
          )
        else
          FilledButton.tonalIcon(
            onPressed: snapshot.members.length < 2 ? null : () => showSettlementSheet(context, snapshot),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Record payment'),
          ),
      ],
      slivers: [
        SliverBox(
          children: [
            const SectionHeader('Balances'),
            FsCard(child: BalanceBars(snapshot: snapshot)),
            SectionHeader(
              'Suggested payments',
              trailing: SegmentedButton<SettlementMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: SettlementMode.simplified, label: Text('Simplified')),
                  ButtonSegment(value: SettlementMode.direct, label: Text('Direct')),
                ],
                selected: {mode},
                onSelectionChanged: (s) => ref.read(preferencesRepositoryProvider).setSettlementMode(s.first),
              ),
            ),
            if (settled)
              const Card(
                child: EmptyState(
                  compact: true,
                  icon: Icons.celebration_rounded,
                  title: 'Everyone is settled up',
                  message: 'No one owes anything right now.',
                ),
              )
            else ...[
              FsListCard(
                children: [
                  for (final t in suggestions)
                    SuggestionRow(
                      transfer: t,
                      snapshot: snapshot,
                      onRecord: () => showSettlementSheet(context, snapshot, prefill: t),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(FsSpace.xs, FsSpace.sm, FsSpace.xs, 0),
                child: Text(
                  mode == SettlementMode.simplified
                      ? '${suggestions.length} ${suggestions.length == 1 ? 'payment settles' : 'payments settle'} everyone. '
                            'Balances are exact; this plan is a practical suggestion, not a proven minimum.'
                      : 'Each line mirrors who actually paid for whom, netted per pair.',
                  style: context.text.bodySmall,
                ),
              ),
            ],
            const SectionHeader('Payment history'),
            if (snapshot.settlements.isEmpty)
              const Card(
                child: EmptyState(
                  compact: true,
                  icon: Icons.history_rounded,
                  title: 'No payments recorded',
                  message: 'Payments you record here reduce what people owe.',
                ),
              )
            else
              FsListCard(
                children: [
                  for (final s in snapshot.settlements)
                    ListTile(
                      leading: const Icon(Icons.swap_horiz_rounded),
                      title: Text('${snapshot.memberName(s.fromMemberId)} paid ${snapshot.memberName(s.toMemberId)}'),
                      subtitle: Text('${dateFormat.format(s.date)}${s.note == null ? '' : ' · ${s.note}'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MoneyText(s.amount, style: context.text.titleMedium),
                                if (s.amount.currency != snapshot.group.baseCurrency)
                                  Text(
                                    '≈ ${BalanceCalculator.convertSettlement(s, snapshot.group.baseCurrency).format()}',
                                    style: context.text.bodySmall?.tabular,
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Payment options',
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            onSelected: (v) async {
                              switch (v) {
                                case 'edit':
                                  await showSettlementSheet(context, snapshot, existing: s);
                                case 'delete':
                                  final ok = await confirmDestructive(
                                    context,
                                    title: 'Delete this payment?',
                                    message: 'The amount will be owed again.',
                                  );
                                  if (ok) await ref.read(settlementRepositoryProvider).deleteSettlement(s.id);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class SuggestionRow extends StatelessWidget {
  const SuggestionRow({required this.transfer, required this.snapshot, required this.onRecord, super.key});

  final Transfer transfer;
  final GroupSnapshot snapshot;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final from = snapshot.memberById(transfer.fromMemberId);
    final to = snapshot.memberById(transfer.toMemberId);
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (from != null) MemberAvatar(member: from, size: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward_rounded, size: 16, color: context.colors.onSurfaceVariant),
          ),
          if (to != null) MemberAvatar(member: to, size: 30),
        ],
      ),
      title: Text('${from?.name ?? '?'} pays ${to?.name ?? '?'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoneyText(transfer.amount, style: context.text.titleMedium),
          const SizedBox(width: FsSpace.md),
          FilledButton.tonal(onPressed: onRecord, child: const Text('Record')),
        ],
      ),
    );
  }
}
