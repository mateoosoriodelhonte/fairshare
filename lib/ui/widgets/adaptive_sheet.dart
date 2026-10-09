import 'package:flutter/material.dart';

import '../shell/app_shell.dart';
import '../theme/theme.dart';

/// Shows [builder] as a bottom sheet on phones and a centred dialog on
/// larger screens.
Future<T?> showAdaptiveSheet<T>(BuildContext context, {required WidgetBuilder builder, double maxWidth = 520}) {
  if (context.isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SingleChildScrollView(child: builder(ctx)),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(FsSpace.xl),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.sizeOf(ctx).height - 2 * FsSpace.xl),
        child: SingleChildScrollView(child: builder(ctx)),
      ),
    ),
  );
}

/// Standard sheet body: title, content, and a right-aligned action row.
class SheetFrame extends StatelessWidget {
  const SheetFrame({required this.title, required this.children, required this.actions, this.subtitle, super.key});

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(FsSpace.xl, FsSpace.lg, FsSpace.xl, FsSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.headlineSmall),
          if (subtitle != null) ...[const SizedBox(height: FsSpace.xs), Text(subtitle!, style: context.text.bodySmall)],
          const SizedBox(height: FsSpace.xl),
          ...children,
          const SizedBox(height: FsSpace.xl),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: FsSpace.sm,
            overflowSpacing: FsSpace.sm,
            overflowAlignment: OverflowBarAlignment.end,
            children: actions,
          ),
        ],
      ),
    );
  }
}

/// Confirmation dialog for destructive actions. Returns true when confirmed.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: ctx.colors.error, foregroundColor: ctx.colors.onError),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
