import 'package:fairshare/core/money/money_exports.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/property.dart';

void main() {
  const usd = Currencies.usd;
  const eur = Currencies.eur;
  const jpy = Currencies.jpy;
  const kwd = Currencies.kwd;

  group('ConversionRate.parse', () {
    test('parses decimals up to six places', () {
      expect(ConversionRate.parse('1').scaled, 1000000);
      expect(ConversionRate.parse('1.085').scaled, 1085000);
      expect(ConversionRate.parse('0,92').scaled, 920000);
      expect(ConversionRate.parse('0.000001').scaled, 1);
      expect(ConversionRate.parse('149.123456').scaled, 149123456);
    });

    test('rejects zero, negatives, and too many digits', () {
      expect(() => ConversionRate.parse('0'), throwsFormatException);
      expect(() => ConversionRate.parse('-1'), throwsFormatException);
      expect(() => ConversionRate.parse('1.1234567'), throwsFormatException);
      expect(() => ConversionRate.parse('abc'), throwsFormatException);
      expect(ConversionRate.tryParse(''), isNull);
    });

    test('decimal string round-trips', () {
      for (final s in ['1.0', '1.085', '0.92', '149.5', '0.000001']) {
        final r = ConversionRate.parse(s);
        expect(ConversionRate.parse(r.toDecimalString()), r);
      }
      expect(ConversionRate.parse('2').toDecimalString(), '2.0');
    });
  });

  group('ConversionRate.convert', () {
    test('same-currency identity passes through', () {
      expect(ConversionRate.identity.convert(const Money(1234, usd), usd), const Money(1234, usd));
    });

    test('converts between two-decimal currencies with half-up rounding', () {
      final rate = ConversionRate.parse('1.085'); // 1 EUR = 1.085 USD
      expect(rate.convert(const Money(10000, eur), usd), const Money(10850, usd));
      // 1.085 * 1 = 1.085 cents -> rounds to 1
      expect(rate.convert(const Money(1, eur), usd), const Money(1, usd));
      // 0.5 cent rounds up (away from zero)
      expect(ConversionRate.parse('0.5').convert(const Money(1, eur), usd), const Money(1, usd));
      expect(ConversionRate.parse('0.5').convert(const Money(-1, eur), usd), const Money(-1, usd));
      expect(ConversionRate.parse('0.4999').convert(const Money(1, eur), usd), const Money(0, usd));
    });

    test('handles differing decimal digits (JPY <-> USD, KWD -> USD)', () {
      // 1 USD = 150 JPY: $12.34 -> ¥1851
      expect(ConversionRate.parse('150').convert(const Money(1234, usd), jpy), const Money(1851, jpy));
      // 1 JPY = 0.0066 USD: ¥1000 -> $6.60
      expect(ConversionRate.parse('0.0066').convert(const Money(1000, jpy), usd), const Money(660, usd));
      // 1 KWD = 3.25 USD: KD1.000 -> $3.25
      expect(ConversionRate.parse('3.25').convert(const Money(1000, kwd), usd), const Money(325, usd));
      // 1 USD = 0.3077 KWD: $10.00 -> KD3.077
      expect(ConversionRate.parse('0.3077').convert(const Money(1000, usd), kwd), const Money(3077, kwd));
    });

    test('is exact for huge amounts (no overflow)', () {
      final rate = ConversionRate.parse('999999.999999');
      final result = rate.convert(const Money(999999999999, usd), eur);
      expect(result.minorUnits, greaterThan(0));
      expect(result.currency, eur);
    });

    forAll('zero converts to zero and sign is preserved', (rng, _) {
      final rate = ConversionRate.fromScaled(rng.intBetween(1, 5000000000));
      final amount = rng.intBetween(-10000000, 10000000);
      final from = rng.pick(Currencies.all);
      final to = rng.pick(Currencies.all);
      final converted = rate.convert(Money(amount, from), to);
      expect(converted.currency, to);
      if (amount == 0) expect(converted.minorUnits, 0);
      if (amount > 0) expect(converted.minorUnits, greaterThanOrEqualTo(0));
      if (amount < 0) expect(converted.minorUnits, lessThanOrEqualTo(0));
      // Symmetry: converting -x gives -(convert x).
      expect(rate.convert(Money(-amount, from), to).minorUnits, -converted.minorUnits);
    });
  });
}
