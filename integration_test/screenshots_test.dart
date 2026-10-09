import 'dart:io';
import 'dart:ui' as ui;

import 'package:fairshare/app/app.dart';
import 'package:fairshare/app/providers.dart';
import 'package:fairshare/app/router.dart';
import 'package:fairshare/data/db/app_database.dart';
import 'package:fairshare/features/demo/demo_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/app_harness.dart';

/// Renders the app with the synthetic demo group and saves PNG screenshots
/// for the README. Runs on a desktop target (`-d macos`); files land in the
/// app's temp directory (sandbox-safe) and the path is printed.
///
///   flutter test integration_test/screenshots_test.dart -d macos
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory outDir;

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 900));
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${outDir.path}/$name.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    debugPrint('SCREENSHOT ${file.path}');
  }

  testWidgets('capture README screenshots', (tester) async {
    outDir = Directory('${Directory.systemTemp.path}/fairshare-screenshots');
    if (outDir.existsSync()) outDir.deleteSync(recursive: true);
    outDir.createSync(recursive: true);

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const FairShareApp()));
    await settle(tester);
    await capture(tester, 'empty-state');

    final groupId = await container.read(demoSeederProvider).seed();
    await settle(tester);
    container.read(routerProvider).go(Routes.group(groupId));
    await settle(tester);
    await capture(tester, 'group');

    container.read(routerProvider).go(Routes.dashboard);
    await settle(tester);
    await capture(tester, 'dashboard');

    container.read(routerProvider).go(Routes.settle(groupId));
    await settle(tester);
    await capture(tester, 'settle');

    container.read(routerProvider).go(Routes.newExpense(groupId));
    await settle(tester);
    await enterInto(tester, 'Description', 'Dinner at the fado house');
    await enterInto(tester, 'Amount', '96.50');
    await tapText(tester, 'Shares');
    await tapText(tester, 'Distribute evenly');
    await capture(tester, 'expense-editor');

    container.read(routerProvider).go(Routes.recurring(groupId));
    await settle(tester);
    await capture(tester, 'recurring');

    container.read(routerProvider).go(Routes.settings);
    await settle(tester);
    await capture(tester, 'settings');

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    container.read(routerProvider).go(Routes.dashboard);
    await settle(tester);
    await capture(tester, 'dashboard-dark');
    container.read(routerProvider).go(Routes.group(groupId));
    await settle(tester);
    await capture(tester, 'group-dark');

    // Phone layout.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    container.read(routerProvider).go(Routes.dashboard);
    await settle(tester);
    await capture(tester, 'phone-dashboard');
    container.read(routerProvider).go(Routes.group(groupId));
    await settle(tester);
    await capture(tester, 'phone-group');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
