import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.trailing, this.padding, super.key});

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(FsSpace.xs, FsSpace.xl, FsSpace.xs, FsSpace.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
          ?trailing,
        ],
      ),
    );
  }
}
