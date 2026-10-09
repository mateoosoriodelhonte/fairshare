import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/money/money.dart';
import '../../domain/group_snapshot.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../groups/group_editor_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final snapshots = ref.watch(allSnapshotsProvider).value ?? const <GroupSnapshot>[];
    final compact = context.isCompact;

    return PageScaffold(
      title: 'Overview',
      showBack: false,
      leading: compact
          ? const Padding(
              padding: EdgeInsets.only(left: FsSpace.lg),
              child: Center(child: BrandMark(size: 26)),
            )
          : null,
      actions: [
        if (compact)
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.navigateTo(Routes.settings),
          ),
      ],
      fab: compact && (groups.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => showGroupEditor(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New group'),
            )
          : null,
      slivers: [
        groups.when(
          loading: () =>
              const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(icon: Icons.error_outline_rounded, title: 'Something went wrong', message: '$e'),
          ),
          data: (list) {
            if (list.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.group_add_rounded,
                  title: 'Split your first expense',
                  message:
                      'Create a group for your flat, a trip, or just the two of you. Everything stays on this device.',
                  action: FilledButton.icon(
                    onPressed: () => showGroupEditor(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New group'),
                  ),
                ),
              );
            }
            return SliverBox(
              children: [
                SectionHeader(
                  'Groups',
                  padding: const EdgeInsets.fromLTRB(FsSpace.xs, FsSpace.sm, FsSpace.xs, FsSpace.md),
                  trailing: compact
                      ? null
                      : TextButton.icon(
                          onPressed: () => showGroupEditor(context),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('New group'),
                        ),
                ),
                _GroupGrid(snapshots: snapshots),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.snapshots});

  final List<GroupSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 2 : 1;
        const gap = FsSpace.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < snapshots.length; i++)
              SizedBox(
                width: width,
                child: StaggeredEntrance(
                  index: i,
                  child: GroupCard(snapshot: snapshots[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class GroupCard extends StatelessWidget {
  const GroupCard({required this.snapshot, super.key});

  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final g = snapshot.group;
    final palette = context.palette;
    final outstanding = Money.sum(snapshot.balances.creditors.map((b) => b.balance), g.baseCurrency);
    final settled = outstanding.isZero;
    return FsCard(
      onTap: () => context.navigateTo(Routes.group(g.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _EmojiTile(emoji: g.emoji),
              const SizedBox(width: FsSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.name, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      '${snapshot.members.length} ${snapshot.members.length == 1 ? 'member' : 'members'} · ${g.baseCurrency.code}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              AvatarStack(members: snapshot.members),
            ],
          ),
          const SizedBox(height: FsSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL SPENT', style: context.text.labelSmall?.copyWith(letterSpacing: 0.6)),
                    const SizedBox(height: 2),
                    AnimatedMoneyText(snapshot.balances.totalSpent, style: context.text.titleLarge),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: settled ? palette.positiveContainer : palette.warningContainer,
                  borderRadius: BorderRadius.circular(FsRadius.pill),
                ),
                child: Text(
                  settled ? 'All settled' : '${outstanding.format()} outstanding',
                  style: context.text.labelMedium
                      ?.copyWith(color: settled ? palette.positive : palette.warning)
                      .tabular,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(FsRadius.md),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 22, height: 1)),
    );
  }
}
