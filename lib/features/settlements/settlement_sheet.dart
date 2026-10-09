import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/ids.dart';
import '../../core/money/money_exports.dart';
import '../../data/repositories/errors.dart';
import '../../domain/accounting/transfer.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../groups/group_editor_sheet.dart';

/// Records that money changed hands outside the app. [prefill] seeds the
/// form from a suggestion; [existing] edits a recorded settlement.
Future<void> showSettlementSheet(
  BuildContext context,
  GroupSnapshot snapshot, {
  Transfer? prefill,
  Settlement? existing,
}) {
  return showAdaptiveSheet<void>(
    context,
    builder: (_) => _SettlementEditor(snapshot: snapshot, prefill: prefill, existing: existing),
  );
}

class _SettlementEditor extends ConsumerStatefulWidget {
  const _SettlementEditor({required this.snapshot, required this.prefill, required this.existing});

  final GroupSnapshot snapshot;
  final Transfer? prefill;
  final Settlement? existing;

  @override
  ConsumerState<_SettlementEditor> createState() => _SettlementEditorState();
}

class _SettlementEditorState extends ConsumerState<_SettlementEditor> {
  late String? _from = widget.existing?.fromMemberId ?? widget.prefill?.fromMemberId;
  late String? _to = widget.existing?.toMemberId ?? widget.prefill?.toMemberId;
  late Currency _currency = widget.existing?.amount.currency ?? widget.prefill?.amount.currency ?? _base;
  late final TextEditingController _amount = TextEditingController(
    text: widget.existing?.amount.toDecimalString() ?? widget.prefill?.amount.toDecimalString() ?? '',
  );
  late final TextEditingController _rate = TextEditingController(
    text: widget.existing?.conversionRate?.toDecimalString() ?? '',
  );
  late final TextEditingController _note = TextEditingController(text: widget.existing?.note ?? '');
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  String? _amountError;
  String? _rateError;
  String? _peopleError;
  bool _saving = false;

  Currency get _base => widget.snapshot.group.baseCurrency;
  bool get _needsRate => _currency != _base;

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _amountError = null;
      _rateError = null;
      _peopleError = null;
    });
    Money? amount;
    try {
      amount = Money.parse(_amount.text, _currency);
      if (!amount.isPositive) {
        setState(() => _amountError = 'Amount must be greater than zero.');
        return;
      }
    } on FormatException catch (e) {
      setState(() => _amountError = _amount.text.trim().isEmpty ? 'Enter an amount.' : e.message);
      return;
    }
    ConversionRate? rate;
    if (_needsRate) {
      rate = ConversionRate.tryParse(_rate.text);
      if (rate == null) {
        setState(() => _rateError = 'Enter the rate to ${_base.code}.');
        return;
      }
    }
    if (_from == null || _to == null) {
      setState(() => _peopleError = 'Choose who paid and who received.');
      return;
    }
    if (_from == _to) {
      setState(() => _peopleError = 'Choose two different people.');
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final settlement = Settlement(
      id: widget.existing?.id ?? Ids.next(),
      groupId: widget.snapshot.group.id,
      fromMemberId: _from!,
      toMemberId: _to!,
      amount: amount,
      conversionRate: rate,
      date: DateTime(_date.year, _date.month, _date.day),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
    );
    try {
      await ref.read(settlementRepositoryProvider).upsertSettlement(settlement);
      if (mounted) Navigator.of(context).pop();
    } on DomainRuleException catch (e) {
      setState(() {
        _saving = false;
        _peopleError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.snapshot.members;
    final editing = widget.existing != null;
    return SheetFrame(
      title: editing ? 'Edit payment' : 'Record a payment',
      subtitle: 'Nothing is transferred. This only notes that money changed hands.',
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: Text(editing ? 'Save' : 'Record')),
      ],
      children: [
        _PeoplePicker(
          label: 'Paid by',
          members: members,
          selected: _from,
          onSelected: (id) => setState(() => _from = id),
        ),
        const SizedBox(height: FsSpace.lg),
        _PeoplePicker(
          label: 'Received by',
          members: members,
          selected: _to,
          onSelected: (id) => setState(() => _to = id),
        ),
        if (_peopleError != null) ...[
          const SizedBox(height: FsSpace.sm),
          Text(_peopleError!, style: context.text.bodySmall?.copyWith(color: context.colors.error)),
        ],
        const SizedBox(height: FsSpace.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _amount,
                autofocus: widget.prefill == null && !editing,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]'))],
                style: context.text.titleLarge?.tabular,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${_currency.symbol} ',
                  errorText: _amountError,
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(width: FsSpace.sm),
            CurrencyField(value: _currency, compact: true, onChanged: (c) => setState(() => _currency = c)),
          ],
        ),
        if (_needsRate) ...[
          const SizedBox(height: FsSpace.md),
          TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            decoration: InputDecoration(
              labelText: 'Rate: 1 ${_currency.code} = ? ${_base.code}',
              errorText: _rateError,
            ),
          ),
        ],
        const SizedBox(height: FsSpace.md),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(DateFormat.yMMMd().format(_date)),
            ),
          ],
        ),
        const SizedBox(height: FsSpace.md),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Note (optional)', hintText: 'Cash at dinner'),
        ),
      ],
    );
  }
}

class _PeoplePicker extends StatelessWidget {
  const _PeoplePicker({required this.label, required this.members, required this.selected, required this.onSelected});

  final String label;
  final List<Member> members;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.labelMedium),
        const SizedBox(height: FsSpace.sm),
        Wrap(
          spacing: FsSpace.sm,
          runSpacing: FsSpace.sm,
          children: [
            for (final m in members)
              ChoiceChip(
                key: ValueKey('$label-${m.name}'),
                selected: selected == m.id,
                avatar: MemberAvatar(member: m, size: 22),
                label: Text(m.name),
                onSelected: (_) => onSelected(m.id),
              ),
          ],
        ),
      ],
    );
  }
}
