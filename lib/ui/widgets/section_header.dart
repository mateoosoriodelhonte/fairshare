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
      child: trailing == null
          ? Text(title, style: context.text.titleMedium)
          : LayoutBuilder(
              builder: (context, constraints) {
                // Large text on narrow screens: let the action drop below the title.
                final stacked = constraints.maxWidth < 320 || MediaQuery.textScalerOf(context).scale(1) > 1.4;
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleMedium),
                      Align(alignment: Alignment.centerLeft, child: trailing),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: Text(title, style: context.text.titleMedium)),
                    Flexible(
                      child: Align(alignment: Alignment.centerRight, child: trailing),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
