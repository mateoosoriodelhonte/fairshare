import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Fades and lifts a child into place shortly after it is first built, with
/// a small delay per [index] so lists settle in a gentle cascade.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 30 * math.min(widget.index, 10));
    Future<void>.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) return widget.child;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: FsMotion.normal,
      curve: FsMotion.standard,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        duration: FsMotion.normal,
        curve: FsMotion.emphasized,
        child: widget.child,
      ),
    );
  }
}
