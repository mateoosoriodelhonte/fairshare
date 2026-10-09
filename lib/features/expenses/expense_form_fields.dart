import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/money/money_exports.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/category_icons.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../groups/group_editor_sheet.dart';
import 'expense_draft.dart';

/// The shared body of the expense and recurring-template editors: every
/// field that describes *what* was paid and *how* it is split. Owns its text
/// controllers and writes straight into [draft].
class ExpenseFormFields extends StatefulWidget {
  const ExpenseFormFields({
    required this.snapshot,
    required this.draft,
    required this.errors,
    required this.onChanged,
    required this.onClearError,
    this.showDate = true,
    this.autofocus = true,
    super.key,
  });

  final GroupSnapshot snapshot;
  final ExpenseDraft draft;
  final Map<DraftField, String> errors;

  /// Called after any field changes so the parent can rebuild.
  final VoidCallback onChanged;

  /// Called when the user edits a field that carried a submit-time error.
  final ValueChanged<DraftField> onClearError;
  final bool showDate;
  final bool autofocus;

  @override
  State<ExpenseFormFields> createState() => _ExpenseFormFieldsState();
}

class _ExpenseFormFieldsState extends State<ExpenseFormFields> {
  ExpenseDraft get _draft => widget.draft;

  late final TextEditingController _description = TextEditingController(text: _draft.description);
  late final TextEditingController _amount = TextEditingController(text: _draft.amountText);
  late final TextEditingController _rate = TextEditingController(text: _draft.rateText);
  late final TextEditingController _notes = TextEditingController(text: _draft.notes);
  final Map<String, TextEditingController> _participantControllers = {};

  @override
  void initState() {
    super.initState();
    for (final p in _draft.participants) {
      _participantControllers[p.memberId] = TextEditingController(text: p.text)
        ..addListener(() {
          p.text = _participantControllers[p.memberId]!.text;
          widget.onChanged();
        });
    }
    _description.addListener(() {
      _draft.description = _description.text;
      widget.onClearError(DraftField.description);
      widget.onChanged();
    });
    _amount.addListener(() {
      _draft.amountText = _amount.text;
      widget.onClearError(DraftField.amount);
      widget.onChanged();
    });
    _rate.addListener(() {
      _draft.rateText = _rate.text;
      widget.onClearError(DraftField.rate);
      widget.onChanged();
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

  void _syncParticipantControllers() {
    for (final p in _draft.participants) {
      final c = _participantControllers[p.memberId]!;
      if (c.text != p.text) c.text = p.text;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _draft.date = picked;
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final errors = widget.errors;
    final preview = _draft.preview();
    final previewByMember = {for (final s in preview.shares ?? const <ExpenseShare>[]) s.memberId: s.amountMinor};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _description,
                autofocus: widget.autofocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Dinner at Café Lisboa',
                  errorText: errors[DraftField.description],
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
                        errorText: errors[DraftField.amount] ?? (_amount.text.isEmpty ? null : _draft.amountError),
                      ),
                    ),
                  ),
                  const SizedBox(width: FsSpace.sm),
                  CurrencyField(
                    value: _draft.currency,
                    compact: true,
                    label: 'Currency',
                    onChanged: (c) {
                      _draft.currency = c;
                      if (!_draft.needsRate) _rate.text = '';
                      widget.onChanged();
                    },
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
                    errorText: errors[DraftField.rate] ?? (_rate.text.isEmpty ? null : _draft.rateError),
                  ),
                ),
              ],
              if (widget.showDate) ...[
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
                  onSelected: (_) {
                    _draft.category = c;
                    widget.onChanged();
                  },
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
                      onSelected: (_) {
                        _draft.paidByMemberId = m.id;
                        widget.onClearError(DraftField.payer);
                        widget.onChanged();
                      },
                    ),
                ],
              ),
              if (errors[DraftField.payer] != null) ...[
                const SizedBox(height: FsSpace.sm),
                Text(errors[DraftField.payer]!, style: context.text.bodySmall?.copyWith(color: context.colors.error)),
              ],
            ],
          ),
        ),
        SectionHeader(
          'Split',
          trailing: _draft.splitType == SplitType.equal
              ? null
              : TextButton(
                  onPressed: () {
                    _draft.distributeEvenly();
                    _syncParticipantControllers();
                    widget.onChanged();
                  },
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
                  onSelectionChanged: (s) {
                    _draft.changeSplitType(s.first);
                    _syncParticipantControllers();
                    widget.onChanged();
                  },
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
                  onIncludedChanged: (v) {
                    p.included = v;
                    widget.onClearError(DraftField.participants);
                    widget.onChanged();
                  },
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(FsSpace.lg, FsSpace.md, FsSpace.lg, FsSpace.lg),
                child: _SplitSummary(
                  draft: _draft,
                  preview: preview,
                  error: errors[DraftField.split] ?? errors[DraftField.participants],
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
    final checkbox = Checkbox(
      key: ValueKey('split-include-$index'),
      value: input.included,
      onChanged: (v) => onIncludedChanged(v ?? false),
      semanticLabel: 'Include $name',
    );
    final nameText = Text(
      name,
      style: context.text.bodyLarge?.copyWith(color: input.included ? null : muted),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final shareText = Text(
      input.included ? (share == null ? '–' : Money(share!, currency).format()) : '',
      textAlign: TextAlign.end,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.text.bodyLarge?.tabular.copyWith(color: share == null ? muted : null),
    );
    final inputField = suffix == null || !input.included
        ? null
        : TextField(
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
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FsSpace.md, vertical: FsSpace.xs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 420;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    checkbox,
                    if (member != null) MemberAvatar(member: member!, size: 30),
                    const SizedBox(width: FsSpace.sm),
                    Expanded(child: nameText),
                    const SizedBox(width: FsSpace.sm),
                    Flexible(child: shareText),
                  ],
                ),
                if (inputField != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: FsSpace.sm),
                    child: inputField,
                  ),
              ],
            );
          }
          return Row(
            children: [
              checkbox,
              if (member != null) MemberAvatar(member: member!, size: 30),
              const SizedBox(width: FsSpace.sm),
              Expanded(child: nameText),
              if (inputField != null) ...[SizedBox(width: 112, child: inputField), const SizedBox(width: FsSpace.md)],
              SizedBox(width: 96, child: shareText),
            ],
          );
        },
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
