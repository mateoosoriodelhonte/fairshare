import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/ids.dart';
import '../../data/repositories/errors.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../expenses/expense_draft.dart';
import '../expenses/expense_form_fields.dart';

/// Creates or edits a recurring template: an expense definition plus a
/// schedule.
class TemplateEditorScreen extends ConsumerWidget {
  const TemplateEditorScreen({required this.groupId, this.templateId, super.key});

  final String groupId;
  final String? templateId;

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
        RecurringTemplate? existing;
        if (templateId != null) {
          for (final t in s.templates) {
            if (t.id == templateId) existing = t;
          }
          if (existing == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Template not found',
                message: 'It may have been deleted.',
              ),
            );
          }
        }
        return _TemplateForm(key: ValueKey(existing?.id ?? 'new'), snapshot: s, existing: existing);
      },
    );
  }
}

class _TemplateForm extends ConsumerStatefulWidget {
  const _TemplateForm({required this.snapshot, required this.existing, super.key});

  final GroupSnapshot snapshot;
  final RecurringTemplate? existing;

  @override
  ConsumerState<_TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends ConsumerState<_TemplateForm> {
  late final ExpenseDraft _draft = widget.existing == null
      ? ExpenseDraft.create(
          group: widget.snapshot.group,
          members: widget.snapshot.members,
          today: DateTime.now(),
          category: ExpenseCategory.housing,
        )
      : ExpenseDraft.fromTemplate(
          group: widget.snapshot.group,
          members: widget.snapshot.members,
          template: widget.existing!,
        );

  late RecurrenceFrequency _frequency = widget.existing?.frequency ?? RecurrenceFrequency.monthly;
  late final TextEditingController _interval = TextEditingController(text: (widget.existing?.interval ?? 1).toString());
  late DateTime _nextDue = widget.existing?.nextDueDate ?? _today;
  late bool _active = widget.existing?.isActive ?? true;
  Map<DraftField, String> _errors = const {};
  String? _scheduleError;
  bool _saving = false;

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _interval.dispose();
    super.dispose();
  }

  void _clearError(DraftField field) {
    if (!_errors.containsKey(field)) return;
    setState(() => _errors = Map.of(_errors)..remove(field));
  }

  Future<void> _save() async {
    final interval = int.tryParse(_interval.text.trim());
    final now = DateTime.now();
    final result = _draft.build(id: 'template', now: now);
    final scheduleError = interval == null || interval < 1 || interval > 365 ? 'Repeat every 1 to 365 units.' : null;
    if (!result.isValid || scheduleError != null) {
      setState(() {
        _errors = result.errors;
        _scheduleError = scheduleError;
      });
      return;
    }
    final e = result.expense!;
    final template = RecurringTemplate(
      id: widget.existing?.id ?? Ids.next(),
      groupId: e.groupId,
      description: e.description,
      amount: e.amount,
      paidByMemberId: e.paidByMemberId,
      category: e.category,
      splitType: e.splitType,
      shares: e.shares,
      conversionRate: e.conversionRate,
      notes: e.notes,
      frequency: _frequency,
      interval: interval!,
      nextDueDate: _nextDue,
      isActive: _active,
      createdAt: widget.existing?.createdAt ?? now,
      lastGeneratedAt: widget.existing?.lastGeneratedAt,
    );
    setState(() {
      _saving = true;
      _errors = const {};
      _scheduleError = null;
    });
    try {
      await ref.read(recurringRepositoryProvider).upsertTemplate(template);
      if (mounted) context.pop();
    } on DomainRuleException catch (err) {
      setState(() {
        _saving = false;
        _errors = {DraftField.split: err.message};
      });
    }
  }

  Future<void> _delete() async {
    final ok = await confirmDestructive(
      context,
      title: 'Delete this template?',
      message: 'Expenses it already created stay in the group.',
    );
    if (!ok || !mounted) return;
    await ref.read(recurringRepositoryProvider).deleteTemplate(widget.existing!.id);
    if (mounted) context.pop();
  }

  Future<void> _pickNextDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDue,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _nextDue = DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return PageScaffold(
      title: editing ? 'Edit template' : 'New recurring expense',
      subtitle: widget.snapshot.group.name,
      actions: [
        if (editing)
          IconButton(
            tooltip: 'Delete template',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _saving ? null : _delete,
          ),
        FilledButton(onPressed: _saving ? null : _save, child: Text(editing ? 'Save' : 'Create')),
      ],
      slivers: [
        SliverBox(
          children: [
            const SectionHeader('Schedule', padding: EdgeInsets.fromLTRB(FsSpace.xs, 0, FsSpace.xs, FsSpace.sm)),
            FsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<RecurrenceFrequency>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: RecurrenceFrequency.daily, label: Text('Daily')),
                      ButtonSegment(value: RecurrenceFrequency.weekly, label: Text('Weekly')),
                      ButtonSegment(value: RecurrenceFrequency.monthly, label: Text('Monthly')),
                      ButtonSegment(value: RecurrenceFrequency.yearly, label: Text('Yearly')),
                    ],
                    selected: {_frequency},
                    onSelectionChanged: (s) => setState(() => _frequency = s.first),
                  ),
                  const SizedBox(height: FsSpace.md),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _interval,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(labelText: 'Repeat every', errorText: _scheduleError),
                          onChanged: (_) => setState(() => _scheduleError = null),
                        ),
                      ),
                      const SizedBox(width: FsSpace.md),
                      Expanded(
                        child: Text(
                          _frequency.label(int.tryParse(_interval.text) ?? 1).toLowerCase(),
                          style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FsSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickNextDue,
                          icon: const Icon(Icons.event_repeat_rounded, size: 18),
                          label: Text('Next on ${DateFormat.yMMMd().format(_nextDue)}'),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                    title: const Text('Active'),
                    subtitle: const Text('Paused templates keep their schedule but create nothing.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FsSpace.lg),
            ExpenseFormFields(
              snapshot: widget.snapshot,
              draft: _draft,
              errors: _errors,
              onChanged: () => setState(() {}),
              onClearError: _clearError,
              showDate: false,
              autofocus: !editing,
            ),
            const SizedBox(height: FsSpace.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(editing ? 'Save changes' : 'Create template'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
