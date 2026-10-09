import 'package:fairshare/app/app.dart';
import 'package:fairshare/app/providers.dart';
import 'package:fairshare/data/db/app_database.dart';
import 'package:fairshare/features/dashboard/dashboard_screen.dart';
import 'package:fairshare/features/io/export_import.dart';
import 'package:fairshare/io/group_json_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_file_gateway.dart';

void main() {
  late FakeFileGateway gateway;

  Future<AppDatabase> pump(WidgetTester tester) async {
    gateway = FakeFileGateway();
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    tester.view.physicalSize = const Size(1280, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), fileGatewayProvider.overrideWithValue(gateway)],
        child: const FairShareApp(),
      ),
    );
    await settle(tester);
    return db;
  }

  Future<void> openGroupMenu(WidgetTester tester) async {
    await tapTooltip(tester, 'Group options');
  }

  testWidgets('exports JSON and CSV through the group menu', (tester) async {
    await pump(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await tapText(tester, 'Add expense', of: FilledButton);
    await enterInto(tester, 'Description', 'Dinner, "the good one"');
    await enterInto(tester, 'Amount', '90');
    await tapText(tester, 'Add expense', of: FilledButton);

    await openGroupMenu(tester);
    await tapText(tester, 'Export group (JSON)');
    expect(gateway.saved, hasLength(1));
    expect(gateway.saved.last.name, startsWith('fairshare-flat-'));
    expect(gateway.saved.last.name, endsWith('.json'));
    expect(gateway.saved.last.mimeType, 'application/json');
    final decoded = GroupJsonCodec.decodeString(gateway.saved.last.contents);
    expect(decoded.group.name, 'Flat');
    expect(decoded.expenses.single.description, 'Dinner, "the good one"');
    expect(find.textContaining('Exported Flat to /fake/'), findsOneWidget);

    await openGroupMenu(tester);
    await tapText(tester, 'Export expenses (CSV)');
    expect(gateway.saved, hasLength(2));
    expect(gateway.saved.last.mimeType, 'text/csv');
    expect(gateway.saved.last.contents, contains('"Dinner, ""the good one"""'));
    expect(gateway.saved.last.contents, contains('Share Ana (USD),Share Ben (USD)'));

    await openGroupMenu(tester);
    await tapText(tester, 'Export balances (CSV)');
    expect(gateway.saved.last.contents, contains('Ana,90.00,45.00,0.00,0.00,45.00,USD'));

    gateway.acceptSaves = false;
    await openGroupMenu(tester);
    await tapText(tester, 'Export payments (CSV)');
    expect(gateway.saved, hasLength(3), reason: 'a cancelled save writes nothing');
    await disposeApp(tester);
  });

  testWidgets('imports a valid export as a new group and navigates to it', (tester) async {
    await pump(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await tapText(tester, 'Add expense', of: FilledButton);
    await enterInto(tester, 'Description', 'Dinner');
    await enterInto(tester, 'Amount', '90');
    await tapText(tester, 'Add expense', of: FilledButton);
    await openGroupMenu(tester);
    await tapText(tester, 'Export group (JSON)');
    final exported = gateway.saved.single.contents;

    await tapText(tester, 'Overview');
    gateway.nextPickedJson = exported;
    await tapText(tester, 'Import', of: TextButton);

    expect(pageTitle('Flat (imported)'), findsOneWidget);
    expect(find.textContaining('Imported Flat (imported): 2 members, 1 expenses'), findsOneWidget);
    expect(find.text('Is owed'), findsOneWidget);
    expect(find.text(r'$45.00'), findsNWidgets(3));

    await tapText(tester, 'Overview');
    expect(find.byType(GroupCard), findsNWidgets(2));
    await disposeApp(tester);
  });

  testWidgets('a corrupt file is rejected with the exact location and nothing changes', (tester) async {
    await pump(tester);
    gateway.nextPickedJson = '{"app":"fairshare","schemaVersion":1,"group":{"id":"g","name":"X","baseCurrency":"USD","emoji":"x","createdAt":"2026-01-01T00:00:00","updatedAt":"2026-01-01T00:00:00"},"members":[{"id":"a","name":"Ana","createdAt":"2026-01-01T00:00:00"}],"expenses":[{"id":"e","description":"d","amount":{"minorUnits":100,"currency":"USD"},"paidByMemberId":"a","category":"food","date":"2026-01-01","splitType":"equal","shares":[{"memberId":"a","amountMinor":99}],"createdAt":"2026-01-01T00:00:00","updatedAt":"2026-01-01T00:00:00"}]}';
    await tapText(tester, 'Import a group', of: TextButton);
    expect(find.text('Could not import this file'), findsOneWidget);
    expect(find.text('Shares add up to 99 minor units but the amount is 100.'), findsOneWidget);
    expect(find.text('At: expenses[0].shares'), findsOneWidget);
    await tapText(tester, 'OK', of: FilledButton);
    expect(find.text('Split your first expense'), findsOneWidget, reason: 'still no groups');

    gateway.nextPickedJson = 'not json at all';
    await tapText(tester, 'Import a group', of: TextButton);
    expect(find.textContaining('not valid JSON'), findsOneWidget);
    await tapText(tester, 'OK', of: FilledButton);

    gateway.nextPickedJson = null;
    await tapText(tester, 'Import a group', of: TextButton);
    expect(find.text('Could not import this file'), findsNothing, reason: 'cancel is silent');
    await disposeApp(tester);
  });
}
