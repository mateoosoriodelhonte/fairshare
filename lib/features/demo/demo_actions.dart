import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../data/demo_seeder.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/widgets/widgets.dart';

final demoSeederProvider = Provider<DemoSeeder>(
  (ref) => DemoSeeder(
    groups: ref.watch(groupRepositoryProvider),
    expenses: ref.watch(expenseRepositoryProvider),
    settlements: ref.watch(settlementRepositoryProvider),
    recurring: ref.watch(recurringRepositoryProvider),
    preferences: ref.watch(preferencesRepositoryProvider),
  ),
);

/// Creates the synthetic demo group and opens it. Never runs on its own:
/// FairShare only adds data the user asked for.
Future<void> createDemoGroup(BuildContext context, WidgetRef ref) async {
  final id = await ref.read(demoSeederProvider).seed();
  if (!context.mounted) return;
  showMessage(context, 'Created the "${DemoSeeder.groupName}" demo group with synthetic data.');
  context.navigateTo(Routes.group(id));
}
