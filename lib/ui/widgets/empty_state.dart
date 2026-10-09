import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A friendly, centred empty state with an optional call to action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  /// Smaller variant for use inside cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? FsSpace.xl : FsSpace.xxxl, horizontal: FsSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 52 : 72,
                height: compact ? 52 : 72,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: compact ? 24 : 32, color: colors.primary),
              ),
              SizedBox(height: compact ? FsSpace.lg : FsSpace.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: compact ? context.text.titleMedium : context.text.headlineSmall,
              ),
              const SizedBox(height: FsSpace.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (action != null) ...[const SizedBox(height: FsSpace.xl), action!],
            ],
          ),
        ),
      ),
    );
  }
}
