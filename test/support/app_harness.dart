import 'package:fairshare/app/app.dart';
import 'package:fairshare/app/providers.dart';
import 'package:fairshare/data/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the real app against an in-memory database at a given window size.
///
/// Tests must finish with [disposeApp] so Drift's stream cleanup timers are
/// flushed before the framework checks for pending timers.
Future<AppDatabase> pumpApp(WidgetTester tester, {Size size = const Size(1280, 820)}) async {
  final db = AppDatabase.inMemory();
  addTearDown(db.close);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(overrides: [databaseProvider.overrideWithValue(db)], child: const FairShareApp()),
  );
  await settle(tester);
  return db;
}

/// Tears the app down and flushes zero-delay timers scheduled by disposal.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Pumps a fixed set of frames. We avoid `pumpAndSettle` because a focused
/// text field keeps scheduling frames and it never settles.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Enters text into the field labelled [label].
Future<void> enterInto(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextField, label);
  expect(field, findsOneWidget, reason: 'field "$label" should be visible');
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> tapText(WidgetTester tester, String text, {Type? of}) async {
  final finder = of == null ? find.text(text) : find.widgetWithText(of, text);
  expect(finder, findsAtLeastNWidgets(1), reason: '"$text" should be tappable');
  await tester.tap(finder.first);
  await settle(tester);
}

Future<void> tapTooltip(WidgetTester tester, String tooltip, {bool last = false}) async {
  final finder = find.byTooltip(tooltip);
  expect(finder, findsAtLeastNWidgets(1), reason: 'tooltip "$tooltip" should exist');
  await tester.tap(last ? finder.last : finder.first);
  await settle(tester);
}

/// Finds the large page title rendered by [PageScaffold].
Finder pageTitle(String text) =>
    find.descendant(of: find.byKey(const ValueKey('page-title')), matching: find.text(text));
