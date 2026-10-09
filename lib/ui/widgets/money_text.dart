import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../theme/theme.dart';

/// Renders a [Money] with tabular figures. Optionally colours by sign and
/// shows an explicit `+`.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.money, {
    this.style,
    this.signed = false,
    this.colored = false,
    this.showCode = false,
    this.textAlign,
    super.key,
  });

  final Money money;
  final TextStyle? style;
  final bool signed;
  final bool colored;
  final bool showCode;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? context.text.bodyLarge ?? const TextStyle()).tabular;
    final color = colored
        ? context.palette.forSign(money.minorUnits, neutral: base.color ?? context.colors.onSurface)
        : null;
    final text = money.format(showSign: signed, showCode: showCode);
    return Text(
      text,
      style: color == null ? base : base.copyWith(color: color),
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: '${money.toDecimalString()} ${money.currency.code}',
    );
  }
}

/// Counts from the previous value to the new one. Respects reduced motion.
class AnimatedMoneyText extends StatelessWidget {
  const AnimatedMoneyText(
    this.money, {
    this.style,
    this.signed = false,
    this.colored = false,
    this.duration = FsMotion.slow,
    super.key,
  });

  final Money money;
  final TextStyle? style;
  final bool signed;
  final bool colored;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: money.minorUnits, end: money.minorUnits),
      duration: reduce ? Duration.zero : duration,
      curve: FsMotion.emphasized,
      builder: (context, value, _) =>
          MoneyText(Money(value, money.currency), style: style, signed: signed, colored: colored),
    );
  }
}
