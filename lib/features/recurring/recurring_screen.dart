import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../domain/group_snapshot.dart';
import '../../ui/category_icons.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({required this.groupId, super.key});

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
          : _RecurringBody(snapshot: s),
    );
  }
}

class _RecurringBody extends ConsumerWidget {
  const _RecurringBody({required this.snapshot});

  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = snapshot.group;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = snapshot.templates.where((t) => t.isActive && !t.nextDueDate.isAfter(today)).length;
    final dateFormat = DateFormat.yMMMd();

    return PageScaffold(
      title: 'Recurring',
      subtitle: g.name,
      actions: [
        FilledButton.tonalIcon(
          onPressed: due == 0
              ? null
              : () async {
                  final created = await ref.read(recurringRepositoryProvider).generateDue(groupId: g.id);
                  if (context.mounted) {
                    showMessage(context, created == 1 ? 'Created 1 expense' : 'Created $created expenses');
                  }
                },
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(due == 0 ? 'Nothing due' : 'Generate $due due'),
        ),
      ],
      fab: snapshot.members.length < 2
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => context.navigateTo(Routes.newTemplate(g.id)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New template'),
            ),
      slivers: [
        SliverBox(
          children: [
            if (snapshot.templates.isEmpty)
              Card(
                child: EmptyState(
                  icon: Icons.event_repeat_rounded,
                  title: 'No recurring expenses',
                  message: snapshot.members.length < 2
                      ? 'Add at least two members first.'
                      : 'Rent, internet, cleaning: set it up once and FairShare records it on schedule.',
                  action: snapshot.members.length < 2
                      ? null
                      : FilledButton.tonal(
                          onPressed: () => context.navigateTo(Routes.newTemplate(g.id)),
                          child: const Text('New template'),
                        ),
                ),
              )
            else
              FsListCard(
                children: [
                  for (final t in snapshot.templates)
                    ListTile(
                      key: ValueKey('template-${t.id}'),
                      onTap: () => context.navigateTo(Routes.template(g.id, t.id)),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.palette.category(t.category).withValues(alpha: t.isActive ? 0.16 : 0.08),
                          borderRadius: BorderRadius.circular(FsRadius.md),
                        ),
                        child: Icon(
                          categoryIcon(t.category),
                          size: 20,
                          color: t.isActive ? context.palette.category(t.category) : context.colors.onSurfaceVariant,
                        ),
                      ),
                      title: Text(t.description),
                      subtitle: Text(
                        '${t.frequency.label(t.interval)} · Next ${dateFormat.format(t.nextDueDate)}'
                        '${t.isActive ? '' : ' · Paused'} · Paid by ${snapshot.memberName(t.paidByMemberId)}',
                        maxLines: 2,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MoneyText(t.amount, style: context.text.titleMedium),
                          const SizedBox(width: FsSpace.sm),
                          Switch(
                            value: t.isActive,
                            onChanged: (v) =>
                                ref.read(recurringRepositoryProvider).upsertTemplate(t.copyWith(isActive: v)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: FsSpace.md),
            Text(
              'Due templates are turned into ordinary expenses when the app opens (you can switch that off in Settings) or when you tap Generate. Each generated expense can be edited like any other.',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
