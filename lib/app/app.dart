import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/models.dart';
import '../ui/theme/theme.dart';
import 'bootstrap.dart';
import 'providers.dart';
import 'router.dart';

class FairShareApp extends ConsumerWidget {
  const FairShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kick off startup work (recurring generation, demo seeding). The UI never
    // waits for it; streams update as rows land.
    ref.watch(bootstrapProvider);
    final themeMode = ref.watch(preferencesProvider).value?.themeMode ?? AppThemeMode.system;
    return MaterialApp.router(
      title: 'FairShare',
      debugShowCheckedModeBanner: false,
      theme: FsTheme.light(),
      darkTheme: FsTheme.dark(),
      themeMode: switch (themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
