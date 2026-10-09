import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Surface container with hairline border; tappable when [onTap] is set.
class FsCard extends StatelessWidget {
  const FsCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(FsSpace.lg),
    this.color,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
    return card;
  }
}

/// A card that groups rows separated by hairlines.
class FsListCard extends StatelessWidget {
  const FsListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: FsSpace.lg, endIndent: FsSpace.lg),
            children[i],
          ],
        ],
      ),
    );
  }
}
