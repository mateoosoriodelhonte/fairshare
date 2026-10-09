import 'package:fairshare/features/expenses/expense_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  Future<void> openRecurring(WidgetTester tester) async {
    await tapText(tester, 'Recurring', of: TextButton);
    expect(pageTitle('Recurring'), findsOneWidget);
  }

  testWidgets('a template due today can be generated into an expense', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openRecurring(tester);
    expect(find.text('No recurring expenses'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Nothing due'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(pageTitle('New recurring expense'), findsOneWidget);
    await enterInto(tester, 'Description', 'Rent');
    await enterInto(tester, 'Amount', '1000');
    await tapText(tester, 'Create', of: FilledButton);

    expect(pageTitle('Recurring'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text(r'$1,000.00'), findsOneWidget);
    expect(find.textContaining('Every month · Next'), findsOneWidget);

    await tapText(tester, 'Generate 1 due', of: FilledButton);
    expect(find.text('Created 1 expense'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Nothing due'), findsOneWidget);

    await tapTooltip(tester, 'Back');
    expect(find.byType(ExpenseTile), findsOneWidget);
    expect(find.textContaining('Recurring'), findsWidgets);
    expect(find.text(r'$500.00'), findsNWidgets(3), reason: 'two member rows and outstanding');
    await disposeApp(tester);
  });

  testWidgets('schedule validation and pause', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openRecurring(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await enterInto(tester, 'Description', 'Cleaning');
    await enterInto(tester, 'Amount', '40');
    await enterInto(tester, 'Repeat every', '0');
    await tapText(tester, 'Create', of: FilledButton);
    expect(find.text('Repeat every 1 to 365 units.'), findsOneWidget);
    await enterInto(tester, 'Repeat every', '2');
    await tapText(tester, 'Weekly');
    expect(find.text('every 2 weeks'), findsOneWidget);
    await tapVisible(tester, find.byType(Switch));
    await tapText(tester, 'Create', of: FilledButton);

    expect(find.textContaining('Every 2 weeks · Next'), findsOneWidget);
    expect(find.textContaining('Paused'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Nothing due'), findsOneWidget, reason: 'paused templates are never due');

    await tapVisible(tester, find.byType(Switch));
    expect(find.textContaining('Paused'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Generate 1 due'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('templates can be edited and deleted', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await openRecurring(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    await enterInto(tester, 'Description', 'Internet');
    await enterInto(tester, 'Amount', '39.99');
    await tapText(tester, 'Create', of: FilledButton);

    await tapText(tester, 'Internet');
    expect(pageTitle('Edit template'), findsOneWidget);
    await enterInto(tester, 'Amount', '45');
    await tapText(tester, 'Save', of: FilledButton);
    expect(find.text(r'$45.00'), findsOneWidget);

    await tapText(tester, 'Internet');
    await tapTooltip(tester, 'Delete template');
    await tapText(tester, 'Delete', of: FilledButton);
    expect(find.text('No recurring expenses'), findsOneWidget);
    await disposeApp(tester);
  });
}
