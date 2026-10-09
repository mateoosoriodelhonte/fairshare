import 'package:fairshare/ui/shell/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('empty overview invites the user to create a group', (tester) async {
    await pumpApp(tester);
    expect(pageTitle('Overview'), findsOneWidget);
    expect(find.text('Split your first expense'), findsOneWidget);
    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.text('No groups yet.'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('creating a group navigates to it and lists it in the sidebar', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'New group', of: FilledButton);
    expect(find.text('Name'), findsOneWidget);

    await enterInto(tester, 'Name', '  Lisbon trip ');
    await tapText(tester, 'Create', of: FilledButton);

    expect(pageTitle('Lisbon trip'), findsOneWidget);
    expect(find.text('Lisbon trip'), findsNWidgets(2), reason: 'headline and sidebar entry');
    expect(find.text('Nobody here yet'), findsOneWidget);
    expect(find.text('0 members · USD'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('empty group name is rejected inline', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'New group', of: FilledButton);
    await tapText(tester, 'Create', of: FilledButton);
    expect(find.text('Give the group a name.'), findsOneWidget);
    await tapText(tester, 'Cancel', of: TextButton);
    await disposeApp(tester);
  });

  testWidgets('members can be added, duplicates are refused, unused members removed', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'New group', of: FilledButton);
    await enterInto(tester, 'Name', 'Flat');
    await tapText(tester, 'Create', of: FilledButton);

    await tapText(tester, 'Add', of: TextButton);
    await enterInto(tester, 'Name', 'Ana');
    await tapText(tester, 'Add another', of: OutlinedButton);
    await enterInto(tester, 'Name', 'Ben');
    await tapText(tester, 'Add', of: FilledButton);

    expect(find.widgetWithText(ListTile, 'Ana'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Ben'), findsOneWidget);
    expect(find.text('2 members · USD'), findsOneWidget);
    expect(find.text('Settled up'), findsNWidgets(2));

    await tapText(tester, 'Add', of: TextButton);
    await enterInto(tester, 'Name', 'ana');
    await tapText(tester, 'Add', of: FilledButton);
    expect(find.text('"ana" is already in this group.'), findsOneWidget);
    await tapText(tester, 'Cancel', of: TextButton);

    // Remove Ben (unused, so allowed).
    await tapTooltip(tester, 'Member options', last: true);
    await tapText(tester, 'Remove');
    await tapText(tester, 'Remove', of: FilledButton);
    expect(find.widgetWithText(ListTile, 'Ben'), findsNothing);
    expect(find.text('1 member · USD'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('deleting a group returns to the overview', (tester) async {
    await pumpApp(tester);
    await tapText(tester, 'New group', of: FilledButton);
    await enterInto(tester, 'Name', 'Temporary');
    await tapText(tester, 'Create', of: FilledButton);

    await tapTooltip(tester, 'Group options');
    await tapText(tester, 'Delete group');
    await tapText(tester, 'Delete', of: FilledButton);

    expect(pageTitle('Overview'), findsOneWidget);
    expect(find.text('Split your first expense'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('compact layout has no sidebar and pushes settings with a back button', (tester) async {
    await pumpApp(tester, size: const Size(400, 820));
    expect(find.byType(Sidebar), findsNothing);
    await tapTooltip(tester, 'Settings');
    expect(pageTitle('Settings'), findsOneWidget);
    await tapTooltip(tester, 'Back');
    expect(pageTitle('Overview'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('theme preference switches the app theme and persists', (tester) async {
    final db = await pumpApp(tester);
    await tapText(tester, 'Settings');
    await tapText(tester, 'Dark');
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final rows = await db.select(db.settingEntries).get();
    expect(rows.any((r) => r.key == 'themeMode' && r.value == 'dark'), isTrue);
    await disposeApp(tester);
  });
}
