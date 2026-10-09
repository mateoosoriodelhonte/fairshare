import 'package:fairshare/core/money/currency.dart';
import 'package:fairshare/features/expenses/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  Future<void> openNewExpense(WidgetTester tester) async {
    await tapText(tester, 'Add expense', of: FilledButton);
    expect(pageTitle('New expense'), findsOneWidget);
  }

  testWidgets('records an equal split and updates balances', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    expect(find.text('No expenses yet'), findsOneWidget);

    await openNewExpense(tester);
    await enterInto(tester, 'Description', 'Dinner');
    await enterInto(tester, 'Amount', '90');
    expect(find.text(r'$45.00'), findsNWidgets(2), reason: 'live preview per participant');
    await tapText(tester, 'Add expense', of: FilledButton);

    expect(pageTitle('Flat'), findsOneWidget);
    expect(find.byType(ExpenseTile), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text(r'$90.00'), findsWidgets);
    expect(find.text('Is owed'), findsOneWidget);
    expect(find.text('Owes'), findsOneWidget);
    expect(find.text(r'$45.00'), findsNWidgets(3), reason: 'two member rows and the outstanding stat');
    await disposeApp(tester);
  });

  testWidgets('validation blocks an empty form and explains each problem', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openNewExpense(tester);
    await tapText(tester, 'Add expense', of: FilledButton);
    expect(pageTitle('New expense'), findsOneWidget, reason: 'stays on the editor');
    expect(find.text('Describe the expense.'), findsOneWidget);
    expect(find.text('Enter an amount.'), findsOneWidget);

    await enterInto(tester, 'Amount', '1.234');
    expect(find.text('USD supports at most 2 decimal places'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('percentage split validates the total and can be distributed evenly', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openNewExpense(tester);
    await enterInto(tester, 'Description', 'Taxi');
    await enterInto(tester, 'Amount', '50');
    await tapText(tester, 'Percent');
    expect(find.text('Enter a percentage for Ana.'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('split-input-0')), '60');
    await tester.enterText(find.byKey(const ValueKey('split-input-1')), '30');
    await settle(tester);
    expect(find.text('Percentages must add up to 100% (currently 90%).'), findsOneWidget);

    await tapText(tester, 'Distribute evenly');
    expect(find.text(r'$25.00'), findsNWidgets(2));
    await tapText(tester, 'Add expense', of: FilledButton);
    expect(find.byType(ExpenseTile), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('exact split reports shortfall in money terms', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openNewExpense(tester);
    await enterInto(tester, 'Amount', '10');
    await tapText(tester, 'Exact');
    await tester.enterText(find.byKey(const ValueKey('split-input-0')), '4');
    await tester.enterText(find.byKey(const ValueKey('split-input-1')), '5.50');
    await settle(tester);
    expect(find.text(r'Amounts are $0.50 short of the total.'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('expenses can be edited and deleted', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openNewExpense(tester);
    await enterInto(tester, 'Description', 'Groceries');
    await enterInto(tester, 'Amount', '20');
    await tapText(tester, 'Add expense', of: FilledButton);

    await tester.tap(find.byType(ExpenseTile));
    await settle(tester);
    expect(pageTitle('Edit expense'), findsOneWidget);
    await enterInto(tester, 'Amount', '30');
    await tapText(tester, 'Save', of: FilledButton);
    expect(find.text(r'$30.00'), findsWidgets);
    expect(find.text(r'$15.00'), findsNWidgets(3));

    await tester.tap(find.byType(ExpenseTile));
    await settle(tester);
    await tapTooltip(tester, 'Delete expense');
    await tapText(tester, 'Delete', of: FilledButton);
    expect(find.byType(ExpenseTile), findsNothing);
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('Settled up'), findsNWidgets(2));
    await disposeApp(tester);
  });

  testWidgets('foreign currency asks for a rate and previews the converted total', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openNewExpense(tester);
    await enterInto(tester, 'Description', 'Tapas');
    await enterInto(tester, 'Amount', '90');

    await tester.tap(find.byType(DropdownMenu<Currency>));
    await settle(tester);
    await tester.tap(find.text('EUR').last);
    await settle(tester);
    expect(find.text('Rate: 1 EUR = ? USD'), findsOneWidget);

    await tapText(tester, 'Add expense', of: FilledButton);
    expect(find.text('Enter the rate to USD.'), findsOneWidget);

    await enterInto(tester, 'Rate: 1 EUR = ? USD', '1.1');
    expect(find.text(r'€90.00 ≈ $99.00 USD'), findsOneWidget);
    await tapText(tester, 'Add expense', of: FilledButton);
    expect(find.text('€90.00'), findsOneWidget);
    expect(find.text(r'≈ $99.00'), findsOneWidget);
    expect(find.text(r'$49.50'), findsNWidgets(3));
    await disposeApp(tester);
  });
}
