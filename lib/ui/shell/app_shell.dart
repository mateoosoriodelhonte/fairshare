import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';
import 'sidebar.dart';

/// Adaptive frame: a persistent sidebar on wide windows, nothing extra on
/// phones. Screens decide their own app bars.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < FsLayout.compactMax;
    if (compact) return child;
    final collapsed = width < FsLayout.expandedMin;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Sidebar(collapsed: collapsed),
          VerticalDivider(width: 1, color: context.palette.hairline),
          Expanded(child: ClipRect(child: child)),
        ],
      ),
    );
  }
}

/// Layout helpers shared by screens.
extension FsLayoutContext on BuildContext {
  bool get isCompact => MediaQuery.sizeOf(this).width < FsLayout.compactMax;

  /// Navigates in the way that feels right for the current form factor:
  /// pushing (with a back button) on phones, replacing on desktop where the
  /// sidebar is the primary navigation.
  void navigateTo(String location) {
    if (isCompact) {
      push(location);
    } else {
      go(location);
    }
  }
}
