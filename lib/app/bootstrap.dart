import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// One-time startup tasks. Kept tiny and idempotent so a crash mid-way is
/// harmless: everything here can safely run again on the next launch.
final bootstrapProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.read(preferencesRepositoryProvider).get();
  if (prefs.autoGenerateRecurring) {
    await ref.read(recurringRepositoryProvider).generateDue();
  }
});
