import 'package:fairshare/features/expenses/expense_list.dart';
import 'package:fairshare/features/settlements/settle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app_harness.dart';

/// End-to-end: the first expense-splitting flow on a real device/desktop
/// window, against an in-memory database so the user's data is untouched.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create a group, add members, record an expense, settle up', (tester) async {
    await pumpApp(tester, size: const Size(1280, 820));
    expect(find.text('Split your first expense'), findsOneWidget);

    await createGroupWithMembers(tester, 'Lisbon trip', ['Ana', 'Ben', 'Cleo']);
    expect(find.text('3 members · USD'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await enterInto(tester, 'Description', 'Dinner at the fado house');
    await enterInto(tester, 'Amount', '100');
    await tapText(tester, 'Add expense', of: FilledButton);

    expect(find.byType(ExpenseTile), findsOneWidget);
    expect(find.text(r'$100.00'), findsWidgets);
    // 100.00 split three ways: 33.34 / 33.33 / 33.33; Ana paid.
    expect(find.text(r'$66.66'), findsNWidgets(2), reason: 'Ana is owed 100 - 33.34: member row and outstanding stat');
    expect(find.text(r'$33.33'), findsNWidgets(2), reason: 'Ben and Cleo each owe 33.33');

    await tapText(tester, 'Settle up', of: FilledButton);
    expect(find.byType(SuggestionRow), findsNWidgets(2));
    await tapText(tester, 'Record', of: FilledButton);
    await tapText(tester, 'Record', of: FilledButton, last: true);
    expect(find.byType(SuggestionRow), findsOneWidget);
    await tapText(tester, 'Record', of: FilledButton);
    await tapText(tester, 'Record', of: FilledButton, last: true);
    expect(find.text('Everyone is settled up'), findsOneWidget);
    await disposeApp(tester);
  });
}
