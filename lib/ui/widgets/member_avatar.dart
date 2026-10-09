import 'package:flutter/material.dart';

import '../../domain/models/member.dart';
import '../theme/theme.dart';

/// Initials in a soft tinted circle. Colour is stable per member.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({required this.member, this.size = 36, super.key});

  final Member member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: member.name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: palette.avatarBackground(member.colorIndex), shape: BoxShape.circle),
        child: Text(
          member.initials,
          style: TextStyle(
            fontFamily: FsType.fontFamily,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: palette.avatarForeground(member.colorIndex),
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// A row of overlapping avatars with a "+N" overflow.
class AvatarStack extends StatelessWidget {
  const AvatarStack({required this.members, this.size = 28, this.max = 4, super.key});

  final List<Member> members;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = members.take(max).toList();
    final overflow = members.length - shown.length;
    final overlap = size * 0.3;
    final width = shown.isEmpty ? 0.0 : size + (shown.length - 1 + (overflow > 0 ? 1 : 0)) * (size - overlap);
    final border = Theme.of(context).cardTheme.color ?? context.colors.surface;
    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(color: border, shape: BoxShape.circle),
                child: MemberAvatar(member: shown[i], size: size - 3),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Text('+$overflow', style: context.text.labelSmall?.copyWith(color: context.colors.onSurface)),
              ),
            ),
        ],
      ),
    );
  }
}
