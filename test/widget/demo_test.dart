import 'package:fairshare/features/dashboard/dashboard_screen.dart';
import 'package:fairshare/features/expenses/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('the empty state can create the demo group and open it', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);

    expect(pageTitle('Casa Verde'), findsOneWidget);
    expect(find.text('4 members · EUR'), findsOneWidget);
    expect(find.textContaining('Created the "Casa Verde" demo group'), findsOneWidget);
    expect(find.byType(ExpenseTile), findsWidgets);
    expect(find.text('Recurring (2)'), findsOneWidget);
    expect(find.text('Is owed'), findsWidgets);
    expect(find.text('Owes'), findsWidgets);
    // A foreign-currency expense shows its converted amount.
    expect(find.textContaining('≈ €'), findsOneWidget);

    await tapText(tester, 'Overview');
    expect(find.byType(GroupCard), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
    expect(find.text('Split your first expense'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('settings can create the demo group again as a separate group', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);
    await tapText(tester, 'Settings');
    await scrollTo(tester, find.text('Create demo group'));
    await tapText(tester, 'Create demo group');
    expect(pageTitle('Casa Verde'), findsOneWidget);
    await tapText(tester, 'Overview');
    expect(find.byType(GroupCard), findsNWidgets(2));
    await disposeApp(tester);
  });

  testWidgets('the demo group settles like any other', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);
    await tapText(tester, 'Settle up', of: FilledButton);
    expect(find.textContaining('settle everyone. Balances are exact'), findsOneWidget);
    expect(find.text('Dev paid Ana'), findsOneWidget, reason: 'the seeded partial payment');
    await disposeApp(tester);
  });
}
