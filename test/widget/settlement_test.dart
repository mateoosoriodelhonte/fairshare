import 'package:fairshare/features/settlements/settle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  /// Adds an expense paid by the first member, split between everyone.
  Future<void> addExpense(
    WidgetTester tester,
    String description,
    String amount, {
    String? paidBy,
    List<int> exclude = const [],
  }) async {
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await enterInto(tester, 'Description', description);
    await enterInto(tester, 'Amount', amount);
    if (paidBy != null) await tapVisible(tester, find.widgetWithText(ChoiceChip, paidBy));
    for (final i in exclude) {
      await tapVisible(tester, find.byKey(ValueKey('split-include-$i')));
    }
    await tapText(tester, 'Add expense', of: FilledButton);
  }

  testWidgets('a suggested payment can be recorded and settles everyone', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await addExpense(tester, 'Dinner', '90');

    await tapText(tester, 'Settle up', of: FilledButton);
    expect(pageTitle('Settle up'), findsOneWidget);
    expect(find.byType(SuggestionRow), findsOneWidget);
    expect(find.text('Ben pays Ana'), findsOneWidget);
    expect(
      find.text(
        '1 payment settles everyone. Balances are exact; this plan is a practical suggestion, not a proven minimum.',
      ),
      findsOneWidget,
    );

    await tapText(tester, 'Record', of: FilledButton);
    expect(find.text('Record a payment'), findsOneWidget);
    expect(find.widgetWithText(TextField, '45.00'), findsOneWidget, reason: 'prefilled from the suggestion');
    await tapText(tester, 'Record', of: FilledButton, last: true);

    expect(find.text('Everyone is settled up'), findsOneWidget);
    expect(find.text('Ben paid Ana'), findsOneWidget);
    expect(find.byType(SuggestionRow), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('a manual partial payment leaves the remainder outstanding', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await addExpense(tester, 'Dinner', '90');
    await tapText(tester, 'Settle up', of: FilledButton);

    await tapText(tester, 'Record payment');
    await tester.tap(find.byKey(const ValueKey('Paid by-Ben')));
    await tester.tap(find.byKey(const ValueKey('Received by-Ana')));
    await settle(tester);
    await enterInto(tester, 'Amount', '20');
    await tapText(tester, 'Record', of: FilledButton, last: true);

    expect(find.text('Ben pays Ana'), findsOneWidget);
    expect(find.text(r'$25.00'), findsWidgets);
    expect(find.text(r'+$25.00'), findsOneWidget);
    expect(find.text(r'-$25.00'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('the sheet rejects paying yourself and bad amounts', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await addExpense(tester, 'Dinner', '90');
    await tapText(tester, 'Settle up', of: FilledButton);
    await tapText(tester, 'Record payment');
    await tapText(tester, 'Record', of: FilledButton, last: true);
    expect(find.text('Enter an amount.'), findsOneWidget);
    await enterInto(tester, 'Amount', '0');
    await tapText(tester, 'Record', of: FilledButton, last: true);
    expect(find.text('Amount must be greater than zero.'), findsOneWidget);
    await enterInto(tester, 'Amount', '5');
    await tester.tap(find.byKey(const ValueKey('Paid by-Ana')));
    await tester.tap(find.byKey(const ValueKey('Received by-Ana')));
    await tapText(tester, 'Record', of: FilledButton, last: true);
    expect(find.text('Choose two different people.'), findsOneWidget);
    await tapText(tester, 'Cancel', of: TextButton);
    await disposeApp(tester);
  });

  testWidgets('simplified and direct modes differ for chained debts', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Trip', ['Ana', 'Ben', 'Cleo']);
    // Ana pays 30 for all three: Ana +20, Ben -10, Cleo -10.
    await addExpense(tester, 'Lunch', '30');
    // Ben pays 20 for Ben and Cleo: Ben 0, Cleo -20, Ana +20.
    await addExpense(tester, 'Taxi', '20', paidBy: 'Ben', exclude: [0]);

    await tapText(tester, 'Settle up', of: FilledButton);
    expect(find.byType(SuggestionRow), findsOneWidget, reason: 'simplified: Cleo pays Ana 20');
    expect(find.text('Cleo pays Ana'), findsOneWidget);

    await tapText(tester, 'Direct');
    expect(find.byType(SuggestionRow), findsNWidgets(3), reason: 'direct: Ben→Ana 10, Cleo→Ana 10, Cleo→Ben 10');
    expect(find.text('Each line mirrors who actually paid for whom, netted per pair.'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('deleting a recorded payment restores the debt', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await addExpense(tester, 'Dinner', '90');
    await tapText(tester, 'Settle up', of: FilledButton);
    await tapText(tester, 'Record', of: FilledButton);
    await tapText(tester, 'Record', of: FilledButton, last: true);
    expect(find.text('Everyone is settled up'), findsOneWidget);

    await tapTooltip(tester, 'Payment options');
    await tapText(tester, 'Delete');
    await tapText(tester, 'Delete', of: FilledButton);
    expect(find.text('No payments recorded'), findsOneWidget);
    expect(find.text('Ben pays Ana'), findsOneWidget);
    await disposeApp(tester);
  });
}
