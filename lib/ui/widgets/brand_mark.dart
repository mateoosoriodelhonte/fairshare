import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// The app mark: two overlapping rounded squares, suggesting a shared bill.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 28, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: size * 0.18,
            child: Container(
              width: size * 0.62,
              height: size * 0.62,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: size * 0.66,
              height: size * 0.66,
              decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(size * 0.2)),
            ),
          ),
        ],
      ),
    );
  }
}
