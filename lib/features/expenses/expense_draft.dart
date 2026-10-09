import '../../core/money/money_exports.dart';
import '../../domain/accounting/accounting.dart';
import '../../domain/models/models.dart';

/// Fields the editor can flag with an error.
enum DraftField { description, amount, rate, payer, participants, split }

/// One member's row in the split section.
class ParticipantInput {
  ParticipantInput({required this.memberId, this.included = true, this.text = ''});

  final String memberId;
  bool included;

  /// Raw text for the current split type: percent ("33.33"), share count
  /// ("2") or exact amount ("12.50"). Ignored for equal splits.
  String text;
}

class SplitPreview {
  const SplitPreview({this.shares, this.error});

  final List<ExpenseShare>? shares;
  final String? error;

  bool get isValid => shares != null;
}

class DraftResult {
  const DraftResult({this.expense, this.errors = const {}});

  final Expense? expense;
  final Map<DraftField, String> errors;

  bool get isValid => expense != null;
}

/// Mutable, UI-agnostic state of the expense editor with all validation.
///
/// The screen binds text fields to these strings; everything numeric is
/// parsed through [Money] and [ConversionRate] so no float ever enters the
/// ledger. Kept free of Flutter imports so it is unit-testable.
class ExpenseDraft {
  ExpenseDraft._({
    required this.group,
    required this.members,
    required this.existing,
    required this.description,
    required this.amountText,
    required this.currency,
    required this.rateText,
    required this.paidByMemberId,
    required this.date,
    required this.category,
    required this.splitType,
    required this.participants,
    required this.notes,
  });

  factory ExpenseDraft.create({
    required Group group,
    required List<Member> members,
    required DateTime today,
    ExpenseCategory category = ExpenseCategory.food,
  }) => ExpenseDraft._(
    group: group,
    members: members,
    existing: null,
    description: '',
    amountText: '',
    currency: group.baseCurrency,
    rateText: '',
    paidByMemberId: members.isEmpty ? null : members.first.id,
    date: DateTime(today.year, today.month, today.day),
    category: category,
    splitType: SplitType.equal,
    participants: [for (final m in members) ParticipantInput(memberId: m.id)],
    notes: '',
  );

  factory ExpenseDraft.edit({required Group group, required List<Member> members, required Expense expense}) {
    final byMember = {for (final s in expense.shares) s.memberId: s};
    String textFor(ExpenseShare s) => switch (expense.splitType) {
      SplitType.equal => '',
      SplitType.percentage => formatPercent(s.splitValue ?? 0),
      SplitType.shares => (s.splitValue ?? 0).toString(),
      SplitType.exact => Money(s.splitValue ?? s.amountMinor, expense.amount.currency).toDecimalString(),
    };
    // Keep group member order, but include any share member that is somehow
    // missing from the member list so nothing is silently dropped.
    final ids = [
      ...members.map((m) => m.id),
      ...expense.shares.map((s) => s.memberId).where((id) => !members.any((m) => m.id == id)),
    ];
    return ExpenseDraft._(
      group: group,
      members: members,
      existing: expense,
      description: expense.description,
      amountText: expense.amount.toDecimalString(),
      currency: expense.amount.currency,
      rateText: expense.conversionRate?.toDecimalString() ?? '',
      paidByMemberId: expense.paidByMemberId,
      date: expense.date,
      category: expense.category,
      splitType: expense.splitType,
      participants: [
        for (final id in ids)
          ParticipantInput(
            memberId: id,
            included: byMember.containsKey(id),
            text: byMember[id] == null ? '' : textFor(byMember[id]!),
          ),
      ],
      notes: expense.notes ?? '',
    );
  }

  /// Edits a recurring template by treating it as an expense definition.
  factory ExpenseDraft.fromTemplate({
    required Group group,
    required List<Member> members,
    required RecurringTemplate template,
  }) {
    final asExpense = Expense(
      id: template.id,
      groupId: template.groupId,
      description: template.description,
      amount: template.amount,
      paidByMemberId: template.paidByMemberId,
      category: template.category,
      date: template.nextDueDate,
      splitType: template.splitType,
      shares: template.shares,
      conversionRate: template.conversionRate,
      notes: template.notes,
      createdAt: template.createdAt,
      updatedAt: template.createdAt,
    );
    return ExpenseDraft.edit(group: group, members: members, expense: asExpense);
  }

  final Group group;
  final List<Member> members;
  final Expense? existing;

  String description;
  String amountText;
  Currency currency;
  String rateText;
  String? paidByMemberId;
  DateTime date;
  ExpenseCategory category;
  SplitType splitType;
  final List<ParticipantInput> participants;
  String notes;

  bool get isEditing => existing != null;

  bool get needsRate => currency != group.baseCurrency;

  /// Parsed amount, or null when the text is not a valid positive amount.
  Money? get amount {
    final m = Money.tryParse(amountText, currency);
    if (m == null || !m.isPositive) return null;
    return m;
  }

  /// Why [amount] is null, in user terms, or null when it is fine.
  String? get amountError {
    if (amountText.trim().isEmpty) return 'Enter an amount.';
    try {
      final m = Money.parse(amountText, currency);
      if (m.isNegative) return 'Amount cannot be negative.';
      if (m.isZero) return 'Amount must be greater than zero.';
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }

  ConversionRate? get rate => needsRate ? ConversionRate.tryParse(rateText) : null;

  String? get rateError {
    if (!needsRate) return null;
    if (rateText.trim().isEmpty) return 'Enter the rate to ${group.baseCurrency.code}.';
    try {
      ConversionRate.parse(rateText);
      return null;
    } on FormatException catch (e) {
      return e.message;
    }
  }

  /// The amount in the group's base currency, when both inputs are valid.
  Money? get convertedTotal {
    final a = amount;
    if (a == null) return null;
    if (!needsRate) return a;
    final r = rate;
    if (r == null) return null;
    return r.convert(a, group.baseCurrency);
  }

  List<ParticipantInput> get included => participants.where((p) => p.included).toList();

  void setAllIncluded(bool value) {
    for (final p in participants) {
      p.included = value;
    }
  }

  /// Switches split type and clears per-member inputs (their meaning changes).
  void changeSplitType(SplitType type) {
    if (type == splitType) return;
    splitType = type;
    for (final p in participants) {
      p.text = '';
    }
  }

  /// Fills percentages or shares so they are evenly distributed, as a
  /// starting point the user can tweak.
  void distributeEvenly() {
    final inc = included;
    if (inc.isEmpty) return;
    switch (splitType) {
      case SplitType.equal:
        return;
      case SplitType.percentage:
        final bps = allocateEqually(basisPointsPer100Percent, inc.length);
        for (var i = 0; i < inc.length; i++) {
          inc[i].text = formatPercent(bps[i]);
        }
      case SplitType.shares:
        for (final p in inc) {
          p.text = '1';
        }
      case SplitType.exact:
        final a = amount;
        if (a == null) return;
        final parts = allocateEqually(a.minorUnits, inc.length);
        for (var i = 0; i < inc.length; i++) {
          inc[i].text = Money(parts[i], currency).toDecimalString();
        }
    }
  }

  /// Sum of entered percentages in basis points (ignores unparsable rows).
  int get enteredBasisPoints => included.fold(0, (acc, p) => acc + (parseBasisPoints(p.text) ?? 0));

  /// Sum of entered exact amounts in minor units (ignores unparsable rows).
  int get enteredExactMinor => included.fold(0, (acc, p) => acc + (Money.tryParse(p.text, currency)?.minorUnits ?? 0));

  /// Computes the shares for the current inputs, or explains why it cannot.
  SplitPreview preview() {
    final a = amount;
    if (a == null) return const SplitPreview(error: 'Enter a valid amount first.');
    final inc = included;
    if (inc.isEmpty) return const SplitPreview(error: 'Choose at least one person to split with.');
    final inputs = <SplitInput>[];
    for (final p in inc) {
      final name = _name(p.memberId);
      switch (splitType) {
        case SplitType.equal:
          inputs.add(SplitInput(p.memberId));
        case SplitType.percentage:
          final bps = parseBasisPoints(p.text);
          if (bps == null) return SplitPreview(error: 'Enter a percentage for $name.');
          inputs.add(SplitInput(p.memberId, bps));
        case SplitType.shares:
          final n = int.tryParse(p.text.trim());
          if (n == null || n < 0) return SplitPreview(error: 'Enter a whole number of shares for $name.');
          inputs.add(SplitInput(p.memberId, n));
        case SplitType.exact:
          final m = Money.tryParse(p.text, currency);
          if (m == null || m.isNegative) return SplitPreview(error: 'Enter an amount for $name.');
          inputs.add(SplitInput(p.memberId, m.minorUnits));
      }
    }
    try {
      return SplitPreview(
        shares: ExpenseSplitter.computeShares(type: splitType, totalMinor: a.minorUnits, inputs: inputs),
      );
    } on SplitValidationException catch (e) {
      return SplitPreview(error: _friendlySplitError(e.message, a));
    }
  }

  String _friendlySplitError(String message, Money total) {
    if (splitType == SplitType.exact) {
      final diff = enteredExactMinor - total.minorUnits;
      if (diff != 0) {
        final m = Money(diff.abs(), currency).format();
        return diff < 0 ? 'Amounts are $m short of the total.' : 'Amounts exceed the total by $m.';
      }
    }
    return message;
  }

  /// Validates everything and produces the [Expense] to persist.
  DraftResult build({required String id, required DateTime now}) {
    final errors = <DraftField, String>{};
    final desc = description.trim();
    if (desc.isEmpty) errors[DraftField.description] = 'Describe the expense.';
    final amountErr = amountError;
    if (amountErr != null) errors[DraftField.amount] = amountErr;
    final rateErr = rateError;
    if (rateErr != null) errors[DraftField.rate] = rateErr;
    if (paidByMemberId == null || !members.any((m) => m.id == paidByMemberId)) {
      errors[DraftField.payer] = 'Choose who paid.';
    }
    final split = preview();
    if (split.error != null) {
      if (included.isEmpty) {
        errors[DraftField.participants] = split.error!;
      } else if (amountErr == null) {
        errors[DraftField.split] = split.error!;
      }
    }
    if (errors.isNotEmpty) return DraftResult(errors: errors);

    final expense = Expense(
      id: id,
      groupId: group.id,
      description: desc,
      amount: amount!,
      paidByMemberId: paidByMemberId!,
      category: category,
      date: DateTime(date.year, date.month, date.day),
      splitType: splitType,
      shares: split.shares!,
      conversionRate: needsRate ? rate : null,
      notes: notes.trim().isEmpty ? null : notes.trim(),
      recurringTemplateId: existing?.recurringTemplateId,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    return DraftResult(expense: expense);
  }

  String _name(String memberId) {
    for (final m in members) {
      if (m.id == memberId) return m.name;
    }
    return 'this person';
  }

  static final RegExp _percentPattern = RegExp(r'^(\d{1,3})(?:[.,](\d{1,2}))?$');

  /// "33.33" -> 3333 basis points. Up to two decimals; null when invalid or
  /// above 100%.
  static int? parseBasisPoints(String text) {
    final m = _percentPattern.firstMatch(text.trim().replaceAll('%', '').replaceAll(RegExp(r'\s'), ''));
    if (m == null) return null;
    final whole = int.parse(m.group(1)!);
    final frac = (m.group(2) ?? '').padRight(2, '0');
    final bps = whole * 100 + int.parse(frac);
    return bps > basisPointsPer100Percent ? null : bps;
  }

  /// 3333 -> "33.33", 5000 -> "50".
  static String formatPercent(int basisPoints) {
    final whole = basisPoints ~/ 100;
    final frac = basisPoints % 100;
    if (frac == 0) return '$whole';
    final f = frac.toString().padLeft(2, '0').replaceFirst(RegExp(r'0$'), '');
    return '$whole.$f';
  }
}
