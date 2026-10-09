import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/models.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';
import '../demo/demo_actions.dart';
import '../groups/group_editor_sheet.dart';
import '../io/export_import.dart';

const String appVersion = '1.0.0';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).value ?? const AppPreferences();
    final repo = ref.read(preferencesRepositoryProvider);

    return PageScaffold(
      title: 'Settings',
      slivers: [
        SliverBox(
          children: [
            const SectionHeader('Appearance'),
            FsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: context.text.labelMedium),
                  const SizedBox(height: FsSpace.sm),
                  SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(value: AppThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
                    ],
                    selected: {prefs.themeMode},
                    onSelectionChanged: (s) => repo.setThemeMode(s.first),
                  ),
                ],
              ),
            ),
            const SectionHeader('Defaults'),
            FsCard(
              child: CurrencyField(
                value: prefs.defaultCurrency,
                label: 'Default currency for new groups',
                onChanged: repo.setDefaultCurrency,
              ),
            ),
            const SectionHeader('Settling up'),
            FsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suggestion style', style: context.text.labelMedium),
                  const SizedBox(height: FsSpace.sm),
                  SegmentedButton<SettlementMode>(
                    segments: const [
                      ButtonSegment(value: SettlementMode.simplified, label: Text('Simplified')),
                      ButtonSegment(value: SettlementMode.direct, label: Text('Direct')),
                    ],
                    selected: {prefs.settlementMode},
                    onSelectionChanged: (s) => repo.setSettlementMode(s.first),
                  ),
                  const SizedBox(height: FsSpace.md),
                  Text(
                    prefs.settlementMode == SettlementMode.simplified
                        ? 'Nets everyone\'s balance into a short list of transfers. It is a practical plan, not a proven minimum; balances themselves are always exact.'
                        : 'Shows exactly who paid for whom, pair by pair. Usually more transfers, but each one mirrors a real expense.',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            const SectionHeader('Recurring expenses'),
            FsListCard(
              children: [
                SwitchListTile(
                  isThreeLine: true,
                  value: prefs.autoGenerateRecurring,
                  onChanged: repo.setAutoGenerateRecurring,
                  title: const Text('Create due expenses on launch'),
                  subtitle: const Text('Templates that fall due are turned into ordinary expenses when the app opens.'),
                ),
              ],
            ),
            const SectionHeader('Your data'),
            FsListCard(
              children: [
                ListTile(
                  isThreeLine: true,
                  leading: const Icon(Icons.file_open_outlined),
                  title: const Text('Import a group from JSON'),
                  subtitle: const Text(
                    'Creates a new group from a FairShare export. Existing groups are never changed.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => importGroupFromFile(context, ref),
                ),
                ListTile(
                  isThreeLine: true,
                  leading: const Icon(Icons.auto_awesome_rounded),
                  title: const Text('Create demo group'),
                  subtitle: const Text(
                    'A fictional flat share with synthetic expenses, every split type, a foreign-currency bill and recurring rent.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => createDemoGroup(context, ref),
                ),
                const ListTile(
                  isThreeLine: true,
                  leading: Icon(Icons.lock_outline_rounded),
                  title: Text('Everything stays on this device'),
                  subtitle: Text(
                    'FairShare has no accounts, no sync and no analytics. Exports are files you choose to save; nothing is uploaded.',
                  ),
                ),
              ],
            ),
            const SectionHeader('About'),
            FsListCard(
              children: [
                const ListTile(
                  isThreeLine: true,
                  leading: BrandMark(size: 26),
                  title: Text('FairShare $appVersion'),
                  subtitle: Text('Split expenses, not friendships. Offline, no account, no tracking.'),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Open-source licenses'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      showLicensePage(context: context, applicationName: 'FairShare', applicationVersion: appVersion),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
