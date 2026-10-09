import 'package:meta/meta.dart';

import 'currency.dart';

/// Thrown when two [Money] values of different currencies are combined.
class CurrencyMismatchError extends Error {
  CurrencyMismatchError(this.left, this.right);

  final Currency left;
  final Currency right;

  @override
  String toString() => 'CurrencyMismatchError: cannot combine $left with $right';
}

/// An exact monetary amount: an integer count of the currency's minor unit.
///
/// FairShare never represents money as a floating point number. All
/// arithmetic on [Money] is integer arithmetic, so sums are exact and
/// associative, and rounding only ever happens in explicit allocation steps
/// (see `allocation.dart`).
@immutable
class Money implements Comparable<Money> {
  const Money(this.minorUnits, this.currency);

  const Money.zero(this.currency) : minorUnits = 0;

  /// Builds a [Money] from a major-unit integer, e.g. `Money.major(12, usd)`
  /// is $12.00.
  Money.major(int major, this.currency) : minorUnits = major * currency.minorUnitsPerMajor;

  /// Amount in minor units (cents, yen, fils...). May be negative.
  final int minorUnits;
  final Currency currency;

  bool get isZero => minorUnits == 0;
  bool get isPositive => minorUnits > 0;
  bool get isNegative => minorUnits < 0;

  Money abs() => Money(minorUnits.abs(), currency);

  Money operator -() => Money(-minorUnits, currency);

  Money operator +(Money other) {
    _check(other);
    return Money(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _check(other);
    return Money(minorUnits - other.minorUnits, currency);
  }

  /// Scales by an integer factor. Scaling by a non-integer is intentionally
  /// unsupported; use an allocation function instead so rounding is explicit.
  Money operator *(int factor) => Money(minorUnits * factor, currency);

  bool operator <(Money other) {
    _check(other);
    return minorUnits < other.minorUnits;
  }

  bool operator >(Money other) {
    _check(other);
    return minorUnits > other.minorUnits;
  }

  bool operator <=(Money other) => !(this > other);
  bool operator >=(Money other) => !(this < other);

  @override
  int compareTo(Money other) {
    _check(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _check(Money other) {
    if (other.currency != currency) {
      throw CurrencyMismatchError(currency, other.currency);
    }
  }

  /// Sums a list of same-currency amounts. An empty list yields zero in
  /// [currency].
  static Money sum(Iterable<Money> values, Currency currency) {
    var total = 0;
    for (final v in values) {
      if (v.currency != currency) throw CurrencyMismatchError(currency, v.currency);
      total += v.minorUnits;
    }
    return Money(total, currency);
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

  static final RegExp _pattern = RegExp(r'^(-)?(\d{1,15})(?:\.(\d{1,4}))?$');

  /// Parses a user-entered decimal string such as `12.50`, `-3`, `1 234,5`
  /// or `$1,234.56` into minor units of [currency].
  ///
  /// Rules:
  /// * Whitespace, the currency symbol and code are ignored.
  /// * Either `.` or `,` may be used as the decimal separator. When both
  ///   appear, the last one is treated as the decimal separator and the other
  ///   as a thousands separator.
  /// * More fractional digits than the currency supports is a [FormatException]
  ///   (we never silently round user input).
  /// * Returns null for empty input.
  static Money? tryParse(String input, Currency currency) {
    try {
      return parse(input, currency);
    } on FormatException {
      return null;
    }
  }

  static Money parse(String input, Currency currency) {
    var text = input.trim();
    if (text.isEmpty) {
      throw const FormatException('Amount is empty');
    }
    text = text.replaceAll(currency.symbol, '').replaceAll(currency.code, '');
    text = text.replaceAll(RegExp(r'\s'), '');

    final dots = '.'.allMatches(text).length;
    final commas = ','.allMatches(text).length;
    String? groupSep;
    String? decimalSep;
    if (dots > 0 && commas > 0) {
      // Both present: the one that appears last is the decimal separator.
      if (text.lastIndexOf('.') > text.lastIndexOf(',')) {
        decimalSep = '.';
        groupSep = ',';
      } else {
        decimalSep = ',';
        groupSep = '.';
      }
      if (text.split(decimalSep).length != 2) {
        throw FormatException('Not a valid amount: "$input"');
      }
    } else if (dots > 1) {
      groupSep = '.';
    } else if (commas > 1) {
      groupSep = ',';
    } else if (dots == 1) {
      decimalSep = '.';
    } else if (commas == 1) {
      // A lone comma is ambiguous. "1,234" reads as grouping for currencies
      // with fewer than three decimals; anything else ("12,50") is a decimal.
      final after = text.length - text.lastIndexOf(',') - 1;
      if (after == 3 && currency.decimalDigits < 3) {
        groupSep = ',';
      } else {
        decimalSep = ',';
      }
    }

    if (groupSep != null) {
      final integerPart = decimalSep == null ? text : text.substring(0, text.indexOf(decimalSep));
      final groups = integerPart.replaceFirst('-', '').split(groupSep);
      final validGroups =
          groups.isNotEmpty &&
          groups.first.isNotEmpty &&
          groups.first.length <= 3 &&
          groups.skip(1).every((g) => g.length == 3) &&
          groups.every((g) => RegExp(r'^\d+$').hasMatch(g));
      if (!validGroups) {
        throw FormatException('Not a valid amount: "$input"');
      }
      text = text.replaceAll(groupSep, '');
    }
    if (decimalSep == ',') {
      text = text.replaceAll(',', '.');
    }

    final match = _pattern.firstMatch(text);
    if (match == null) {
      throw FormatException('Not a valid amount: "$input"');
    }
    final negative = match.group(1) != null;
    final whole = match.group(2)!;
    final fraction = match.group(3) ?? '';
    if (fraction.length > currency.decimalDigits) {
      throw FormatException(
        '${currency.code} supports at most ${currency.decimalDigits} decimal place${currency.decimalDigits == 1 ? '' : 's'}',
      );
    }
    final paddedFraction = fraction.padRight(currency.decimalDigits, '0');
    final minor =
        int.parse(whole) * currency.minorUnitsPerMajor + (paddedFraction.isEmpty ? 0 : int.parse(paddedFraction));
    return Money(negative ? -minor : minor, currency);
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  /// Plain decimal representation without grouping or symbol, e.g. `-1234.56`.
  /// Suitable for CSV/JSON export and round-trips through [parse].
  String toDecimalString() {
    final digits = currency.decimalDigits;
    final absValue = minorUnits.abs();
    final whole = absValue ~/ currency.minorUnitsPerMajor;
    final frac = absValue % currency.minorUnitsPerMajor;
    final sign = minorUnits < 0 ? '-' : '';
    if (digits == 0) return '$sign$whole';
    return '$sign$whole.${frac.toString().padLeft(digits, '0')}';
  }

  /// Human readable formatting, e.g. `$1,234.56`, `-€12.00`, `¥500`.
  ///
  /// [showSign] forces a leading `+` for positive values (useful for balances).
  /// [showCode] appends the ISO code (`$1,234.56 USD`) which disambiguates
  /// currencies that share a symbol.
  String format({bool showSign = false, bool showCode = false, bool symbol = true}) {
    final digits = currency.decimalDigits;
    final absValue = minorUnits.abs();
    final whole = absValue ~/ currency.minorUnitsPerMajor;
    final frac = absValue % currency.minorUnitsPerMajor;
    final wholeText = _group(whole.toString());
    final fracText = digits == 0 ? '' : '.${frac.toString().padLeft(digits, '0')}';
    final sign = minorUnits < 0 ? '-' : (showSign && minorUnits > 0 ? '+' : '');
    final sym = symbol ? currency.symbol : '';
    final buffer = StringBuffer()
      ..write(sign)
      ..write(sym)
      ..write(wholeText)
      ..write(fracText);
    if (showCode) buffer.write(' ${currency.code}');
    return buffer.toString();
  }

  static String _group(String digits) {
    final buffer = StringBuffer();
    final len = digits.length;
    for (var i = 0; i < len; i++) {
      buffer.write(digits[i]);
      final remaining = len - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) => other is Money && other.minorUnits == minorUnits && other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  String toString() => '${toDecimalString()} ${currency.code}';
}
