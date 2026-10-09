import 'package:fairshare/features/expenses/expense_list.dart';
import 'package:fairshare/ui/shell/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

/// Layout and accessibility checks. Any RenderFlex overflow surfaces as a
/// test failure, so these walk the main screens at phone width and with
/// enlarged text.
void main() {
  Future<void> walkMainScreens(WidgetTester tester, {required bool compact}) async {
    await tapText(tester, 'Explore with demo data', of: TextButton);
    expect(pageTitle('Casa Verde'), findsOneWidget);
    await scrollTo(tester, find.byType(ExpenseTile));
    expect(find.byType(ExpenseTile), findsWidgets);

    await tester.tap(find.byType(FloatingActionButton));
    await settle(tester);
    expect(pageTitle('New expense'), findsOneWidget);
    await tapText(tester, 'Percent');
    await scrollTo(tester, find.text('Distribute evenly'));
    await tapText(tester, 'Distribute evenly');
    if (compact) {
      await tapTooltip(tester, 'Back');
    } else {
      await tapText(tester, 'Casa Verde');
    }

    await scrollTo(tester, find.text('Settle up'));
    await tapText(tester, 'Settle up', of: FilledButton);
    expect(pageTitle('Settle up'), findsOneWidget);
    await scrollTo(tester, find.text('Payment history'));
    if (compact) {
      await tapTooltip(tester, 'Back');
    } else {
      await tapText(tester, 'Casa Verde');
    }

    await scrollTo(tester, find.text('Spending'));
    expect(find.text('Spending by category'), findsOneWidget);
    await scrollTo(tester, find.text('Recurring (2)'));
    await tapVisible(tester, find.widgetWithText(TextButton, 'Recurring (2)'));
    expect(pageTitle('Recurring'), findsOneWidget);
    if (compact) {
      await tapTooltip(tester, 'Back');
      await tapTooltip(tester, 'Back');
      await tapTooltip(tester, 'Settings');
    } else {
      await tapText(tester, 'Overview');
      await scrollTo(tester, find.text('Last 6 months'));
      await tapText(tester, 'Settings');
    }
    expect(pageTitle('Settings'), findsOneWidget);
    await scrollTo(tester, find.text('Open-source licenses'));
  }

  testWidgets('phone width at 130% text scale renders every main screen without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, size: const Size(360, 740));
    expect(find.byType(Sidebar), findsNothing);
    await walkMainScreens(tester, compact: true);
    await disposeApp(tester);
  });

  testWidgets('desktop at 150% text scale renders every main screen without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, size: const Size(1100, 760));
    expect(find.byType(Sidebar), findsOneWidget);
    await walkMainScreens(tester, compact: false);
    await disposeApp(tester);
  });

  testWidgets('narrow desktop window collapses the sidebar to a rail', (tester) async {
    await pumpApp(tester, size: const Size(900, 700));
    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.text('FairShare'), findsNothing, reason: 'brand text hidden in rail mode');
    await disposeApp(tester);
  });

  testWidgets('key controls expose semantics labels', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);
    expect(find.bySemanticsLabel(RegExp('Ana')), findsWidgets, reason: 'avatars are labelled with the name');
    await scrollTo(tester, find.text('Settle up'));
    await tapText(tester, 'Settle up', of: FilledButton);
    expect(
      find.bySemanticsLabel(RegExp(r'is owed|owes|settled up')),
      findsWidgets,
      reason: 'balance bars narrate the balance',
    );
    await tapText(tester, 'Overview');
    expect(find.bySemanticsLabel(RegExp('Spending by category')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Monthly spending')), findsOneWidget);
    handle.dispose();
    await disposeApp(tester);
  });
}
