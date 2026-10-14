import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('Copy plan puts the suggested payments on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await pumpApp(tester);
    await tapText(tester, 'Explore with demo data', of: TextButton);
    await scrollTo(tester, find.text('Settle up'));
    await tapText(tester, 'Settle up', of: FilledButton);
    await tapTooltip(tester, 'Copy plan');

    expect(find.text('Plan copied. Paste it into your group chat.'), findsOneWidget);
    expect(copied, startsWith('Casa Verde · settle up (simplified)'));
    expect(copied, contains('Dev pays Ben €38.23'));
    expect(copied, contains('Chloe pays Ana €11.00'));
    await disposeApp(tester);
  });

  testWidgets('Copy plan is disabled when everyone is settled', (tester) async {
    await pumpApp(tester);
    await createGroupWithMembers(tester, 'Flat', ['Ana', 'Ben']);
    await tapText(tester, 'Settle up', of: FilledButton);
    final button = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.copy_rounded));
    expect(button.onPressed, isNull);
    await disposeApp(tester);
  });
}
