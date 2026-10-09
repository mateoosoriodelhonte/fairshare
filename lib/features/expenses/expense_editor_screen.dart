import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/ids.dart';
import '../../core/money/money_exports.dart';
import '../../data/repositories/errors.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/category_icons.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../groups/group_editor_sheet.dart';
import 'expense_draft.dart';

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

  late final TextEditingController _description = TextEditingController(text: _draft.description);
  late final TextEditingController _amount = TextEditingController(text: _draft.amountText);
  late final TextEditingController _rate = TextEditingController(text: _draft.rateText);
  late final TextEditingController _notes = TextEditingController(text: _draft.notes);
  final Map<String, TextEditingController> _participantControllers = {};

  Map<DraftField, String> _errors = const {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final p in _draft.participants) {
      _participantControllers[p.memberId] = TextEditingController(text: p.text)
        ..addListener(() {
          p.text = _participantControllers[p.memberId]!.text;
          _refresh();
        });
    }
    _description.addListener(() {
      _draft.description = _description.text;
      _clearError(DraftField.description);
    });
    _amount.addListener(() {
      _draft.amountText = _amount.text;
      _clearError(DraftField.amount);
    });
    _rate.addListener(() {
      _draft.rateText = _rate.text;
      _clearError(DraftField.rate);
    });
    _notes.addListener(() => _draft.notes = _notes.text);
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _rate.dispose();
    _notes.dispose();
    for (final c in _participantControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// Editing a field dismisses the error raised for it at submit time; live
  /// validation takes over from there.
  void _clearError(DraftField field) {
    if (!mounted) return;
    setState(() {
      if (_errors.containsKey(field)) _errors = Map.of(_errors)..remove(field);
    });
  }

  void _syncParticipantControllers() {
    for (final p in _draft.participants) {
      final c = _participantControllers[p.memberId]!;
      if (c.text != p.text) c.text = p.text;
    }
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _draft.date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final editing = _draft.isEditing;
    final preview = _draft.preview();
    final previewByMember = {for (final s in preview.shares ?? const <ExpenseShare>[]) s.memberId: s.amountMinor};

    return PageScaffold(
      title: editing ? 'Edit expense' : 'New expense',
      subtitle: snapshot.group.name,
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
            FsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _description,
                    autofocus: !editing,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Dinner at Café Lisboa',
                      errorText: _errors[DraftField.description],
                    ),
                  ),
                  const SizedBox(height: FsSpace.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]'))],
                          style: context.text.titleLarge?.tabular,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            prefixText: '${_draft.currency.symbol} ',
                            errorText: _errors[DraftField.amount] ?? (_amount.text.isEmpty ? null : _draft.amountError),
                          ),
                        ),
                      ),
                      const SizedBox(width: FsSpace.sm),
                      CurrencyField(
                        value: _draft.currency,
                        compact: true,
                        label: 'Currency',
                        onChanged: (c) => setState(() {
                          _draft.currency = c;
                          if (!_draft.needsRate) {
                            _rate.text = '';
                          }
                        }),
                      ),
                    ],
                  ),
                  if (_draft.needsRate) ...[
                    const SizedBox(height: FsSpace.md),
                    TextField(
                      controller: _rate,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      decoration: InputDecoration(
                        labelText: 'Rate: 1 ${_draft.currency.code} = ? ${snapshot.group.baseCurrency.code}',
                        helperText: _draft.convertedTotal == null
                            ? 'Enter the rate you want to use. FairShare never fetches rates.'
                            : '${_draft.amount!.format()} ≈ ${_draft.convertedTotal!.format(showCode: true)}',
                        errorText: _errors[DraftField.rate] ?? (_rate.text.isEmpty ? null : _draft.rateError),
                      ),
                    ),
                  ],
                  const SizedBox(height: FsSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_rounded, size: 18),
                          label: Text(DateFormat.yMMMd().format(_draft.date)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SectionHeader('Category'),
            FsCard(
              padding: const EdgeInsets.all(FsSpace.md),
              child: Wrap(
                spacing: FsSpace.sm,
                runSpacing: FsSpace.sm,
                children: [
                  for (final c in ExpenseCategory.values)
                    ChoiceChip(
                      selected: _draft.category == c,
                      avatar: Icon(categoryIcon(c), size: 16, color: context.palette.category(c)),
                      label: Text(c.label),
                      onSelected: (_) => setState(() => _draft.category = c),
                    ),
                ],
              ),
            ),
            const SectionHeader('Paid by'),
            FsCard(
              padding: const EdgeInsets.all(FsSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: FsSpace.sm,
                    runSpacing: FsSpace.sm,
                    children: [
                      for (final m in snapshot.members)
                        ChoiceChip(
                          selected: _draft.paidByMemberId == m.id,
                          avatar: MemberAvatar(member: m, size: 22),
                          label: Text(m.name),
                          onSelected: (_) => setState(() => _draft.paidByMemberId = m.id),
                        ),
                    ],
                  ),
                  if (_errors[DraftField.payer] != null) ...[
                    const SizedBox(height: FsSpace.sm),
                    Text(
                      _errors[DraftField.payer]!,
                      style: context.text.bodySmall?.copyWith(color: context.colors.error),
                    ),
                  ],
                ],
              ),
            ),
            SectionHeader(
              'Split',
              trailing: _draft.splitType == SplitType.equal
                  ? null
                  : TextButton(
                      onPressed: () => setState(() {
                        _draft.distributeEvenly();
                        _syncParticipantControllers();
                      }),
                      child: const Text('Distribute evenly'),
                    ),
            ),
            FsCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(FsSpace.md),
                    child: SegmentedButton<SplitType>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: SplitType.equal, label: Text('Equally')),
                        ButtonSegment(value: SplitType.percentage, label: Text('Percent')),
                        ButtonSegment(value: SplitType.shares, label: Text('Shares')),
                        ButtonSegment(value: SplitType.exact, label: Text('Exact')),
                      ],
                      selected: {_draft.splitType},
                      onSelectionChanged: (s) => setState(() {
                        _draft.changeSplitType(s.first);
                        _syncParticipantControllers();
                      }),
                    ),
                  ),
                  const Divider(),
                  for (final (i, p) in _draft.participants.indexed)
                    _ParticipantRow(
                      key: ValueKey('split-row-$i'),
                      index: i,
                      member: snapshot.memberById(p.memberId),
                      input: p,
                      splitType: _draft.splitType,
                      currency: _draft.currency,
                      controller: _participantControllers[p.memberId]!,
                      share: previewByMember[p.memberId],
                      onIncludedChanged: (v) => setState(() => p.included = v),
                    ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(FsSpace.lg, FsSpace.md, FsSpace.lg, FsSpace.lg),
                    child: _SplitSummary(
                      draft: _draft,
                      preview: preview,
                      error: _errors[DraftField.split] ?? _errors[DraftField.participants],
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader('Notes'),
            FsCard(
              child: TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Optional', border: InputBorder.none, filled: false),
              ),
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

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.index,
    required this.member,
    required this.input,
    required this.splitType,
    required this.currency,
    required this.controller,
    required this.share,
    required this.onIncludedChanged,
    super.key,
  });

  final int index;
  final Member? member;
  final ParticipantInput input;
  final SplitType splitType;
  final Currency currency;
  final TextEditingController controller;
  final int? share;
  final ValueChanged<bool> onIncludedChanged;

  @override
  Widget build(BuildContext context) {
    final name = member?.name ?? 'Unknown';
    final muted = context.colors.onSurfaceVariant;
    final String? suffix = switch (splitType) {
      SplitType.equal => null,
      SplitType.percentage => '%',
      SplitType.shares => 'shares',
      SplitType.exact => currency.code,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FsSpace.md, vertical: FsSpace.xs),
      child: Row(
        children: [
          Checkbox(
            key: ValueKey('split-include-$index'),
            value: input.included,
            onChanged: (v) => onIncludedChanged(v ?? false),
            semanticLabel: 'Include $name',
          ),
          if (member != null) MemberAvatar(member: member!, size: 30),
          const SizedBox(width: FsSpace.sm),
          Expanded(
            child: Text(
              name,
              style: context.text.bodyLarge?.copyWith(color: input.included ? null : muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (suffix != null && input.included) ...[
            SizedBox(
              width: 112,
              child: TextField(
                key: ValueKey('split-input-$index'),
                controller: controller,
                textAlign: TextAlign.end,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                style: context.text.bodyLarge?.tabular,
                decoration: InputDecoration(
                  isDense: true,
                  suffixText: suffix,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: FsSpace.md),
          ],
          SizedBox(
            width: 96,
            child: Text(
              input.included ? (share == null ? '–' : Money(share!, currency).format()) : '',
              textAlign: TextAlign.end,
              style: context.text.bodyLarge?.tabular.copyWith(color: share == null ? muted : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitSummary extends StatelessWidget {
  const _SplitSummary({required this.draft, required this.preview, required this.error});

  final ExpenseDraft draft;
  final SplitPreview preview;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = error ?? preview.error;
    if (message != null) {
      return Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.error),
          const SizedBox(width: FsSpace.sm),
          Expanded(
            child: Text(message, style: context.text.bodySmall?.copyWith(color: colors.error)),
          ),
        ],
      );
    }
    final n = draft.included.length;
    final detail = switch (draft.splitType) {
      SplitType.equal =>
        'Split equally between $n ${n == 1 ? 'person' : 'people'}. Leftover cents go to the first people listed.',
      SplitType.percentage => 'Percentages add up to 100%.',
      SplitType.shares => 'Proportional to share counts.',
      SplitType.exact => 'Amounts add up to the total.',
    };
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 18, color: context.palette.positive),
        const SizedBox(width: FsSpace.sm),
        Expanded(child: Text(detail, style: context.text.bodySmall)),
      ],
    );
  }
}
