import '../core/money/money.dart';
import '../domain/accounting/accounting.dart';
import '../domain/group_snapshot.dart';

/// Readable CSV reports. RFC 4180 quoting, CRLF line endings, and a UTF-8
/// byte-order mark so spreadsheets show currency symbols correctly.
class CsvExport {
  CsvExport._();

  static const String bom = '﻿';

  static String expenses(GroupSnapshot s) {
    final base = s.group.baseCurrency;
    final members = s.members;
    final header = [
      'Date',
      'Description',
      'Category',
      'Paid by',
      'Currency',
      'Amount',
      'Rate to ${base.code}',
      'Amount (${base.code})',
      'Split',
      for (final m in members) 'Share ${m.name} (${base.code})',
      'Notes',
    ];
    final rows = <List<String>>[header];
    final ordered = [...s.expenses]
      ..sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        return cmp != 0 ? cmp : a.createdAt.compareTo(b.createdAt);
      });
    for (final e in ordered) {
      final converted = BalanceCalculator.convertExpense(e, base);
      rows.add([
        _date(e.date),
        e.description,
        e.category.label,
        s.memberName(e.paidByMemberId),
        e.amount.currency.code,
        e.amount.toDecimalString(),
        e.conversionRate?.toDecimalString() ?? '',
        converted.total.toDecimalString(),
        e.splitType.label,
        for (final m in members) (converted.shares[m.id] ?? Money.zero(base)).toDecimalString(),
        e.notes ?? '',
      ]);
    }
    return _render(rows);
  }

  static String balances(GroupSnapshot s) {
    final rows = <List<String>>[
      ['Member', 'Paid', 'Owed', 'Paid out in settlements', 'Received in settlements', 'Balance', 'Currency'],
      for (final m in s.members)
        () {
          final b = s.balances.byMember[m.id];
          return [
            m.name,
            (b?.paid ?? Money.zero(s.group.baseCurrency)).toDecimalString(),
            (b?.owed ?? Money.zero(s.group.baseCurrency)).toDecimalString(),
            (b?.settledOut ?? Money.zero(s.group.baseCurrency)).toDecimalString(),
            (b?.settledIn ?? Money.zero(s.group.baseCurrency)).toDecimalString(),
            (b?.balance ?? Money.zero(s.group.baseCurrency)).toDecimalString(),
            s.group.baseCurrency.code,
          ];
        }(),
    ];
    return _render(rows);
  }

  static String settlements(GroupSnapshot s) {
    final base = s.group.baseCurrency;
    final rows = <List<String>>[
      ['Date', 'From', 'To', 'Currency', 'Amount', 'Rate to ${base.code}', 'Amount (${base.code})', 'Note'],
      for (final t in [...s.settlements]..sort((a, b) => a.date.compareTo(b.date)))
        [
          _date(t.date),
          s.memberName(t.fromMemberId),
          s.memberName(t.toMemberId),
          t.amount.currency.code,
          t.amount.toDecimalString(),
          t.conversionRate?.toDecimalString() ?? '',
          BalanceCalculator.convertSettlement(t, base).toDecimalString(),
          t.note ?? '',
        ],
    ];
    return _render(rows);
  }

  static String _render(List<List<String>> rows) => '$bom${rows.map((r) => r.map(escape).join(',')).join('\r\n')}\r\n';

  /// Quotes a field when it contains a comma, quote, or line break.
  static String escape(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n') || field.contains('\r')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
