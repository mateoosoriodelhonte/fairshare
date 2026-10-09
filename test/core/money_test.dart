import 'package:fairshare/core/money/money_exports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const usd = Currencies.usd;
  const jpy = Currencies.jpy;
  const kwd = Currencies.kwd;

  group('Money arithmetic', () {
    test('adds and subtracts exactly', () {
      expect(const Money(1050, usd) + const Money(950, usd), const Money(2000, usd));
      expect(const Money(1, usd) - const Money(2, usd), const Money(-1, usd));
    });

    test('sums a list and handles the empty list', () {
      expect(Money.sum(const [Money(1, usd), Money(2, usd)], usd), const Money(3, usd));
      expect(Money.sum(const [], usd), const Money(0, usd));
    });

    test('scales by integers only', () {
      expect(const Money(333, usd) * 3, const Money(999, usd));
    });

    test('refuses to mix currencies', () {
      expect(() => const Money(1, usd) + const Money(1, jpy), throwsA(isA<CurrencyMismatchError>()));
      expect(() => const Money(1, usd).compareTo(const Money(1, jpy)), throwsA(isA<CurrencyMismatchError>()));
      expect(() => Money.sum(const [Money(1, usd), Money(1, jpy)], usd), throwsA(isA<CurrencyMismatchError>()));
    });

    test('no float drift: 0.1 + 0.2 == 0.3', () {
      expect(Money.parse('0.1', usd) + Money.parse('0.2', usd), Money.parse('0.3', usd));
    });

    test('comparisons and predicates', () {
      expect(const Money(5, usd) > const Money(4, usd), isTrue);
      expect(const Money(5, usd) <= const Money(5, usd), isTrue);
      expect(const Money(0, usd).isZero, isTrue);
      expect(const Money(-1, usd).isNegative, isTrue);
      expect(const Money(-7, usd).abs(), const Money(7, usd));
      expect(-const Money(7, usd), const Money(-7, usd));
    });
  });

  group('Money.parse', () {
    test('parses common decimal input', () {
      expect(Money.parse('12.50', usd), const Money(1250, usd));
      expect(Money.parse('12', usd), const Money(1200, usd));
      expect(Money.parse('12.5', usd), const Money(1250, usd));
      expect(Money.parse('0.07', usd), const Money(7, usd));
    });

    test('accepts comma decimal separators and grouping', () {
      expect(Money.parse('12,50', Currencies.eur), const Money(1250, Currencies.eur));
      expect(Money.parse('1,234.56', usd), const Money(123456, usd));
      expect(Money.parse('1.234,56', Currencies.eur), const Money(123456, Currencies.eur));
      expect(Money.parse('1 234,56', Currencies.eur), const Money(123456, Currencies.eur));
      expect(Money.parse('1,234', usd), const Money(123400, usd));
      expect(Money.parse('1.234.567', Currencies.eur), const Money(123456700, Currencies.eur));
      expect(Money.parse('1,234,567.89', usd), const Money(123456789, usd));
      expect(Money.parse('1,250', kwd), const Money(1250, kwd));
      expect(Money.parse('-1,234.50', usd), const Money(-123450, usd));
    });

    test('ignores symbol, code and whitespace', () {
      expect(Money.parse(r' $ 42.00 ', usd), const Money(4200, usd));
      expect(Money.parse('42.00 USD', usd), const Money(4200, usd));
    });

    test('parses negatives (used for balances and corrections)', () {
      expect(Money.parse('-3.25', usd), const Money(-325, usd));
    });

    test('respects currency decimal digits', () {
      expect(Money.parse('500', jpy), const Money(500, jpy));
      expect(Money.parse('1.250', kwd), const Money(1250, kwd));
      expect(Money.parse('1.2', kwd), const Money(1200, kwd));
    });

    test('rejects too many decimals instead of rounding', () {
      expect(() => Money.parse('1.234', usd), throwsFormatException);
      expect(() => Money.parse('1.5', jpy), throwsFormatException);
      expect(() => Money.parse('1.2345', kwd), throwsFormatException);
    });

    test('rejects garbage', () {
      for (final bad in [
        '',
        '   ',
        'abc',
        '1.2.3.4',
        '1,2,3',
        '12,345,6',
        '--1',
        '1e5',
        'NaN',
        '∞',
        '12.',
        '.',
        '.5',
        '1.,5',
        '1,.5',
      ]) {
        expect(() => Money.parse(bad, usd), throwsFormatException, reason: '"$bad" should be rejected');
        expect(Money.tryParse(bad, usd), isNull, reason: '"$bad" should be rejected');
      }
    });

    test('round-trips through toDecimalString', () {
      for (final v in [0, 1, 99, 100, 101, 123456789, -5, -123456789]) {
        final m = Money(v, usd);
        expect(Money.parse(m.toDecimalString(), usd), m);
      }
      for (final v in [0, 7, 500, -1200]) {
        final m = Money(v, jpy);
        expect(Money.parse(m.toDecimalString(), jpy), m);
      }
      for (final v in [0, 1, 999, 1001, -2500]) {
        final m = Money(v, kwd);
        expect(Money.parse(m.toDecimalString(), kwd), m);
      }
    });
  });

  group('Money.format', () {
    test('formats with grouping and symbol', () {
      expect(const Money(123456, usd).format(), r'$1,234.56');
      expect(const Money(-1200, Currencies.eur).format(), '-€12.00');
      expect(const Money(500, jpy).format(), '¥500');
      expect(const Money(1234567, jpy).format(), '¥1,234,567');
      expect(const Money(1250, kwd).format(), 'KD1.250');
      expect(const Money(0, usd).format(), r'$0.00');
    });

    test('optional sign and code', () {
      expect(const Money(100, usd).format(showSign: true), r'+$1.00');
      expect(const Money(0, usd).format(showSign: true), r'$0.00');
      expect(const Money(100, usd).format(showCode: true), r'$1.00 USD');
      expect(const Money(100, usd).format(symbol: false), '1.00');
    });

    test('toDecimalString has no grouping or symbol', () {
      expect(const Money(123456, usd).toDecimalString(), '1234.56');
      expect(const Money(-5, usd).toDecimalString(), '-0.05');
      expect(const Money(7, jpy).toDecimalString(), '7');
    });
  });

  group('Currencies', () {
    test('lookup is case-insensitive and rejects unknown codes', () {
      expect(Currencies.byCode('usd'), usd);
      expect(Currencies.byCode(' EUR '), Currencies.eur);
      expect(Currencies.byCode('XXX'), isNull);
      expect(() => Currencies.require('XXX'), throwsArgumentError);
    });

    test('codes are unique', () {
      final codes = Currencies.all.map((c) => c.code).toSet();
      expect(codes.length, Currencies.all.length);
    });

    test('minor units per major', () {
      expect(usd.minorUnitsPerMajor, 100);
      expect(jpy.minorUnitsPerMajor, 1);
      expect(kwd.minorUnitsPerMajor, 1000);
    });
  });
}
