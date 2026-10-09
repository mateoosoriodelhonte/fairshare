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

/// Taps the first (or, with [last], the last) widget matching [text].
/// Use [last] for buttons inside dialogs and sheets, which sit above the
/// page in the widget tree.
Future<void> tapText(WidgetTester tester, String text, {Type? of, bool last = false}) async {
  final finder = of == null ? find.text(text) : find.widgetWithText(of, text);
  expect(finder, findsAtLeastNWidgets(1), reason: '"$text" should be tappable');
  final target = last ? finder.last : finder.first;
  await revealIfNeeded(tester, target);
  await tester.tap(target);
  await settle(tester);
}

Future<void> tapTooltip(WidgetTester tester, String tooltip, {bool last = false}) async {
  final finder = find.byTooltip(tooltip);
  expect(finder, findsAtLeastNWidgets(1), reason: 'tooltip "$tooltip" should exist');
  final target = last ? finder.last : finder.first;
  await revealIfNeeded(tester, target);
  await tester.tap(target);
  await settle(tester);
}

/// Finds the large page title rendered by [PageScaffold].
Finder pageTitle(String text) =>
    find.descendant(of: find.byKey(const ValueKey('page-title')), matching: find.text(text));

/// Creates a group through the UI and adds [memberNames]; leaves the app on
/// the group screen.
Future<void> createGroupWithMembers(WidgetTester tester, String name, List<String> memberNames) async {
  await tapText(tester, 'New group', of: FilledButton);
  await enterInto(tester, 'Name', name);
  await tapText(tester, 'Create', of: FilledButton);
  for (var i = 0; i < memberNames.length; i++) {
    await tapText(tester, 'Add', of: TextButton);
    await enterInto(tester, 'Name', memberNames[i]);
    await tapText(tester, 'Add', of: FilledButton);
  }
  expect(pageTitle(name), findsOneWidget);
}

/// Scrolls [finder] into view and taps it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await revealIfNeeded(tester, finder);
  await tester.tap(finder);
  await settle(tester);
}

/// Scrolls [finder] into view only when it is outside the window. Unlike
/// `WidgetTester.ensureVisible`, this never moves content that is already
/// visible, so page titles are not scrolled out (and unmounted).
Future<void> revealIfNeeded(WidgetTester tester, Finder finder) async {
  final rect = tester.getRect(finder);
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final visible = rect.top >= 0 && rect.bottom <= size.height && rect.left >= 0 && rect.right <= size.width;
  if (visible) return;
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pump();
}

/// Scrolls the page's main scroll view until [finder] is built and visible,
/// for content in lazily built lists far below the fold.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  final scrollable = find.descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable)).first;
  await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
  await tester.pump();
}
