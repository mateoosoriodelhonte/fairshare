import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/group_snapshot.dart';
import 'package:fairshare/io/csv_export.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  late GroupSnapshot s;

  setUp(() {
    final g = testGroup();
    final ms = members(['a', 'b']);
    s = GroupSnapshot(
      group: g,
      members: ms,
      expenses: [
        expense(amountMinor: 1000, paidBy: 'a', participants: ['a', 'b']).copyWith(notes: 'Pizza "night", extra'),
        expense(
          amountMinor: 1000,
          paidBy: 'b',
          participants: ['a', 'b'],
          currency: Currencies.eur,
          rate: ConversionRate.parse('1.1'),
          date: DateTime(2026, 2, 3),
        ),
      ],
      settlements: [settlement(from: 'b', to: 'a', amountMinor: 250)],
      templates: const [],
    );
  });

  test('escape quotes commas, quotes and newlines', () {
    expect(CsvExport.escape('plain'), 'plain');
    expect(CsvExport.escape('a,b'), '"a,b"');
    expect(CsvExport.escape('say "hi"'), '"say ""hi"""');
    expect(CsvExport.escape('line\nbreak'), '"line\nbreak"');
  });

  test('expenses report has a header, per-member share columns, and converted amounts', () {
    final csv = CsvExport.expenses(s);
    expect(csv.startsWith(CsvExport.bom), isTrue);
    final lines = csv.substring(1).split('\r\n').where((l) => l.isNotEmpty).toList();
    expect(
      lines.first,
      'Date,Description,Category,Paid by,Currency,Amount,Rate to USD,Amount (USD),Split,Share A (USD),Share B (USD),Notes',
    );
    expect(lines.length, 3);
    // Oldest first.
    expect(lines[1], startsWith('2026-01-01,Expense '));
    expect(lines[1], contains(',USD,10.00,,10.00,Equally,5.00,5.00,"Pizza ""night"", extra"'));
    expect(lines[2], contains('2026-02-03'));
    expect(lines[2], contains(',EUR,10.00,1.1,11.00,Equally,5.50,5.50,'));
  });

  test('balances report sums to zero', () {
    final csv = CsvExport.balances(s).substring(1);
    final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();
    expect(lines.first, 'Member,Paid,Owed,Paid out in settlements,Received in settlements,Balance,Currency');
    expect(lines[1], 'A,10.00,10.50,0.00,2.50,-3.00,USD');
    expect(lines[2], 'B,11.00,10.50,2.50,0.00,3.00,USD');
  });

  test('settlements report', () {
    final csv = CsvExport.settlements(s).substring(1);
    final lines = csv.split('\r\n').where((l) => l.isNotEmpty).toList();
    expect(lines.first, 'Date,From,To,Currency,Amount,Rate to USD,Amount (USD),Note');
    expect(lines[1], '2026-01-01,B,A,USD,2.50,,2.50,');
  });
}
