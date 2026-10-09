import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../domain/group_snapshot.dart';
import '../../io/csv_export.dart';
import '../../io/file_gateway.dart';
import '../../io/group_importer.dart';
import '../../io/group_json_codec.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';

/// Overridable in tests with an in-memory fake.
final fileGatewayProvider = Provider<FileGateway>((ref) => const FileSelectorGateway());

final groupImporterProvider = Provider<GroupImporter>(
  (ref) => GroupImporter(
    groups: ref.watch(groupRepositoryProvider),
    expenses: ref.watch(expenseRepositoryProvider),
    settlements: ref.watch(settlementRepositoryProvider),
    recurring: ref.watch(recurringRepositoryProvider),
  ),
);

String _slug(String name) {
  final s = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return s.isEmpty ? 'group' : s;
}

String _stamp(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

/// Export the whole group as JSON (re-importable).
Future<void> exportGroupJson(BuildContext context, WidgetRef ref, GroupSnapshot snapshot) async {
  final gateway = ref.read(fileGatewayProvider);
  final now = DateTime.now();
  final path = await gateway.saveTextFile(
    suggestedName: 'fairshare-${_slug(snapshot.group.name)}-${_stamp(now)}.json',
    contents: GroupJsonCodec.encodeToString(snapshot, exportedAt: now),
    mimeType: 'application/json',
  );
  if (path != null && context.mounted) showMessage(context, 'Exported ${snapshot.group.name} to $path');
}

enum CsvReport { expenses, balances, settlements }

Future<void> exportGroupCsv(BuildContext context, WidgetRef ref, GroupSnapshot snapshot, CsvReport report) async {
  final gateway = ref.read(fileGatewayProvider);
  final contents = switch (report) {
    CsvReport.expenses => CsvExport.expenses(snapshot),
    CsvReport.balances => CsvExport.balances(snapshot),
    CsvReport.settlements => CsvExport.settlements(snapshot),
  };
  final path = await gateway.saveTextFile(
    suggestedName: 'fairshare-${_slug(snapshot.group.name)}-${report.name}-${_stamp(DateTime.now())}.csv',
    contents: contents,
    mimeType: 'text/csv',
  );
  if (path != null && context.mounted) showMessage(context, 'Exported ${report.name} to $path');
}

/// Lets the user pick a FairShare JSON file and imports it as a new group.
/// Validation problems are shown in a dialog with the exact location.
Future<void> importGroupFromFile(BuildContext context, WidgetRef ref) async {
  final gateway = ref.read(fileGatewayProvider);
  final text = await gateway.pickJsonFile();
  if (text == null || !context.mounted) return;
  await importGroupFromText(context, ref, text);
}

Future<void> importGroupFromText(BuildContext context, WidgetRef ref, String text) async {
  ImportedGroup data;
  try {
    data = GroupJsonCodec.decodeString(text);
  } on ImportException catch (e) {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Could not import this file'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.message),
            if (e.path.isNotEmpty) ...[
              const SizedBox(height: FsSpace.sm),
              Text('At: ${e.path}', style: ctx.text.bodySmall?.copyWith(fontFamily: 'monospace')),
            ],
            const SizedBox(height: FsSpace.md),
            Text('Nothing was changed.', style: ctx.text.bodySmall),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ),
    );
    return;
  }
  final group = await ref.read(groupImporterProvider).import(data);
  if (!context.mounted) return;
  showMessage(
    context,
    'Imported ${group.name}: ${data.members.length} members, ${data.expenses.length} expenses, ${data.settlements.length} payments.',
  );
  context.navigateTo(Routes.group(group.id));
}
