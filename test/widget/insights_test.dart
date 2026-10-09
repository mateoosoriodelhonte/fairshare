import 'package:fairshare/ui/charts/donut_chart.dart';
import 'package:fairshare/ui/charts/monthly_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('dashboard shows insights once a group has expenses', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);
    await scrollTo(tester, find.text('Spending'));
    expect(find.text('Spending'), findsOneWidget, reason: 'group screen insights section');
    expect(find.byType(DonutChart), findsOneWidget);
    expect(find.byType(MonthlyBarChart), findsOneWidget);

    await tapText(tester, 'Overview');
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('TOTAL SPENT'), findsWidgets);
    expect(find.text('THIS MONTH'), findsOneWidget);
    expect(find.text('OUTSTANDING'), findsOneWidget);
    expect(find.text('TOP CATEGORY'), findsOneWidget);
    expect(find.text('Spending by category'), findsOneWidget);
    expect(find.text('Last 6 months'), findsOneWidget);
    expect(find.byType(DonutChart), findsOneWidget);
    expect(find.textContaining('%'), findsWidgets, reason: 'legend percentages');
    await disposeApp(tester);
  });

  testWidgets('a group without expenses shows no spending section', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    expect(find.text('Spending'), findsNothing);
    await tapText(tester, 'Overview');
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget, reason: 'top category caption');
    await disposeApp(tester);
  });

  testWidgets('currency chips appear when groups use different currencies', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);
    await tapText(tester, 'Overview');
    await tapText(tester, 'New group', of: TextButton);
    await enterInto(tester, 'Name', 'Dollars');
    await tapText(tester, 'Create', of: FilledButton);
    await tapText(tester, 'Overview');
    expect(find.widgetWithText(ChoiceChip, 'EUR'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'USD'), findsOneWidget);
    await tapText(tester, 'USD', of: ChoiceChip);
    expect(find.text(r'$0.00'), findsWidgets);
    await disposeApp(tester);
  });
}
