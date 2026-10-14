import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/accounting/transfer.dart';
import 'package:fairshare/domain/group_snapshot.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:fairshare/features/settlements/settlement_plan_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  final snapshot = GroupSnapshot(
    group: testGroup(),
    members: members(['a', 'b', 'c']),
    expenses: [
      expense(amountMinor: 3000, paidBy: 'a', participants: ['a', 'b', 'c']),
    ],
    settlements: const [],
    templates: const [],
  );

  test('lists each transfer with names and formatted money', () {
    final text = settlementPlanText(
      snapshot,
      snapshot.suggestions(SettlementMode.simplified),
      SettlementMode.simplified,
    );
    expect(text.split('\n').first, 'Test · settle up (simplified)');
    expect(text, contains(r'B pays A $10.00'));
    expect(text, contains(r'C pays A $10.00'));
    expect(text, contains('the plan is a suggestion'));
  });

  test('says so when nobody owes anything', () {
    final text = settlementPlanText(snapshot, const <Transfer>[], SettlementMode.direct);
    expect(text, 'Test · settle up (direct)\nEveryone is settled up.');
  });

  test('uses the currency of the transfers', () {
    final text = settlementPlanText(snapshot, const [
      Transfer(fromMemberId: 'b', toMemberId: 'a', amount: Money(1250, Currencies.eur)),
    ], SettlementMode.simplified);
    expect(text, contains('B pays A €12.50'));
  });
}
