import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/ids.dart';
import '../../data/repositories/errors.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import 'expense_draft.dart';
import 'expense_form_fields.dart';

/// Creates or edits one expense.
class ExpenseEditorScreen extends ConsumerWidget {
  const ExpenseEditorScreen({required this.groupId, this.expenseId, super.key});

  final String groupId;
  final String? expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(groupSnapshotProvider(groupId));
    return snapshot.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline_rounded, title: 'Could not load', message: '$e'),
      ),
      data: (s) {
        if (s == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Group not found',
              message: 'It may have been deleted.',
            ),
          );
        }
        Expense? existing;
        if (expenseId != null) {
          for (final e in s.expenses) {
            if (e.id == expenseId) existing = e;
          }
          if (existing == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Expense not found',
                message: 'It may have been deleted.',
              ),
            );
          }
        }
        return _ExpenseForm(key: ValueKey(existing?.id ?? 'new'), snapshot: s, existing: existing);
      },
    );
  }
}

class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({required this.snapshot, required this.existing, super.key});

  final GroupSnapshot snapshot;
  final Expense? existing;

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  late final ExpenseDraft _draft = widget.existing == null
      ? ExpenseDraft.create(group: widget.snapshot.group, members: widget.snapshot.members, today: DateTime.now())
      : ExpenseDraft.edit(group: widget.snapshot.group, members: widget.snapshot.members, expense: widget.existing!);

  Map<DraftField, String> _errors = const {};
  bool _saving = false;

  void _clearError(DraftField field) {
    if (!_errors.containsKey(field)) return;
    setState(() => _errors = Map.of(_errors)..remove(field));
  }

  Future<void> _save() async {
    final result = _draft.build(id: widget.existing?.id ?? Ids.next(), now: DateTime.now());
    if (!result.isValid) {
      setState(() => _errors = result.errors);
      return;
    }
    setState(() {
      _saving = true;
      _errors = const {};
    });
    try {
      await ref.read(expenseRepositoryProvider).upsertExpense(result.expense!);
      if (!mounted) return;
      context.pop();
    } on DomainRuleException catch (e) {
      setState(() {
        _saving = false;
        _errors = {DraftField.split: e.message};
      });
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDestructive(
      context,
      title: 'Delete this expense?',
      message: 'Balances will update as if it never happened.',
    );
    if (!ok || !mounted) return;
    await ref.read(expenseRepositoryProvider).deleteExpense(widget.existing!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = _draft.isEditing;
    return PageScaffold(
      title: editing ? 'Edit expense' : 'New expense',
      subtitle: widget.snapshot.group.name,
      actions: [
        if (editing)
          IconButton(
            tooltip: 'Delete expense',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _saving ? null : _delete,
          ),
        FilledButton(onPressed: _saving ? null : _save, child: Text(editing ? 'Save' : 'Add expense')),
      ],
      slivers: [
        SliverBox(
          children: [
            ExpenseFormFields(
              snapshot: widget.snapshot,
              draft: _draft,
              errors: _errors,
              onChanged: () => setState(() {}),
              onClearError: _clearError,
              autofocus: !editing,
            ),
            const SizedBox(height: FsSpace.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(editing ? 'Save changes' : 'Add expense'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
