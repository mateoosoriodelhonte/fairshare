import 'package:meta/meta.dart';

import 'currency.dart';
import 'money.dart';

/// A user-entered exchange rate expressed as a fixed-point decimal with six
/// fractional digits ("micro" scale). `1 EUR = 1.0850 USD` is stored as
/// `scaled = 1085000`.
///
/// FairShare never fetches rates. Each foreign-currency expense carries the
/// rate the user typed when recording it, so a group's books are reproducible
/// and auditable.
@immutable
class ConversionRate {
  const ConversionRate.fromScaled(this.scaled) : assert(scaled > 0, 'rate must be positive');

  /// One unit of the source currency equals exactly one unit of the target.
  static const identity = ConversionRate.fromScaled(scale);

  /// Fixed-point scale: 10^6.
  static const int scale = 1000000;
  static const int fractionDigits = 6;

  /// Rate × 10^6.
  final int scaled;

  bool get isIdentity => scaled == scale;

  static final RegExp _pattern = RegExp(r'^(\d{1,9})(?:[.,](\d{1,6}))?$');

  /// Parses a decimal string such as `1.0850` or `0,92`. Up to six fractional
  /// digits are supported; more is a [FormatException].
  static ConversionRate parse(String input) {
    final text = input.trim().replaceAll(RegExp(r'\s'), '');
    final match = _pattern.firstMatch(text);
    if (match == null) {
      throw FormatException('Not a valid rate: "$input"');
    }
    final whole = int.parse(match.group(1)!);
    final frac = (match.group(2) ?? '').padRight(fractionDigits, '0');
    final scaled = whole * scale + int.parse(frac);
    if (scaled <= 0) {
      throw const FormatException('Rate must be greater than zero');
    }
    return ConversionRate.fromScaled(scaled);
  }

  static ConversionRate? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }

  /// Decimal representation with trailing zeros trimmed (at least one
  /// fractional digit is kept), e.g. `1.085`.
  String toDecimalString() {
    final whole = scaled ~/ scale;
    var frac = (scaled % scale).toString().padLeft(fractionDigits, '0');
    frac = frac.replaceFirst(RegExp(r'0+$'), '');
    if (frac.isEmpty) frac = '0';
    return '$whole.$frac';
  }

  /// Converts [amount] (in [amount.currency]) into [target] using this rate,
  /// where the rate is "1 source major unit = rate target major units".
  ///
  /// Rounding is half-up on the absolute value (away from zero), done exactly
  /// once, using big-integer arithmetic so there is no overflow or float drift.
  Money convert(Money amount, Currency target) {
    if (amount.currency == target && isIdentity) return amount;
    final from = amount.currency;
    // targetMinor = amountMinor * scaled / scale * 10^(target.digits - from.digits)
    final numerator =
        BigInt.from(amount.minorUnits.abs()) * BigInt.from(scaled) * BigInt.from(target.minorUnitsPerMajor);
    final denominator = BigInt.from(scale) * BigInt.from(from.minorUnitsPerMajor);
    final rounded = _divRoundHalfUp(numerator, denominator);
    final value = rounded.toInt();
    return Money(amount.minorUnits < 0 ? -value : value, target);
  }

  static BigInt _divRoundHalfUp(BigInt numerator, BigInt denominator) {
    final twice = numerator * BigInt.two + denominator;
    return twice ~/ (denominator * BigInt.two);
  }

  @override
  bool operator ==(Object other) => other is ConversionRate && other.scaled == scaled;

  @override
  int get hashCode => scaled.hashCode;

  @override
  String toString() => 'ConversionRate(${toDecimalString()})';
}
