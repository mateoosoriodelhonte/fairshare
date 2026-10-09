/// ISO 4217 currency metadata used throughout FairShare.
///
/// Amounts are always stored as integers in the currency's minor unit
/// (cents for USD, yen for JPY, fils for KWD). [decimalDigits] tells us how
/// many minor units make up one major unit (10^decimalDigits).
class Currency {
  const Currency({required this.code, required this.name, required this.symbol, required this.decimalDigits})
    : assert(decimalDigits >= 0 && decimalDigits <= 4);

  /// Three-letter ISO 4217 code, e.g. `USD`.
  final String code;

  /// Human readable name, e.g. `US Dollar`.
  final String name;

  /// Display symbol, e.g. `$`. Falls back to the code where no symbol exists.
  final String symbol;

  /// Number of decimal digits in the major unit (2 for USD, 0 for JPY, 3 for KWD).
  final int decimalDigits;

  /// Number of minor units in one major unit (100 for USD, 1 for JPY, 1000 for KWD).
  int get minorUnitsPerMajor => _pow10(decimalDigits);

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

int _pow10(int n) {
  var result = 1;
  for (var i = 0; i < n; i++) {
    result *= 10;
  }
  return result;
}

/// Registry of supported currencies. Deliberately a curated static list:
/// FairShare works offline and never fetches currency data.
class Currencies {
  Currencies._();

  static const usd = Currency(code: 'USD', name: 'US Dollar', symbol: r'$', decimalDigits: 2);
  static const eur = Currency(code: 'EUR', name: 'Euro', symbol: '€', decimalDigits: 2);
  static const gbp = Currency(code: 'GBP', name: 'British Pound', symbol: '£', decimalDigits: 2);
  static const jpy = Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', decimalDigits: 0);
  static const chf = Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', decimalDigits: 2);
  static const cad = Currency(code: 'CAD', name: 'Canadian Dollar', symbol: r'CA$', decimalDigits: 2);
  static const aud = Currency(code: 'AUD', name: 'Australian Dollar', symbol: r'A$', decimalDigits: 2);
  static const nzd = Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$', decimalDigits: 2);
  static const sek = Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', decimalDigits: 2);
  static const nok = Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', decimalDigits: 2);
  static const dkk = Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', decimalDigits: 2);
  static const pln = Currency(code: 'PLN', name: 'Polish Złoty', symbol: 'zł', decimalDigits: 2);
  static const czk = Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', decimalDigits: 2);
  static const huf = Currency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', decimalDigits: 2);
  static const ron = Currency(code: 'RON', name: 'Romanian Leu', symbol: 'lei', decimalDigits: 2);
  static const mxn = Currency(code: 'MXN', name: 'Mexican Peso', symbol: r'MX$', decimalDigits: 2);
  static const brl = Currency(code: 'BRL', name: 'Brazilian Real', symbol: r'R$', decimalDigits: 2);
  static const ars = Currency(code: 'ARS', name: 'Argentine Peso', symbol: r'AR$', decimalDigits: 2);
  static const clp = Currency(code: 'CLP', name: 'Chilean Peso', symbol: r'CL$', decimalDigits: 0);
  static const cop = Currency(code: 'COP', name: 'Colombian Peso', symbol: r'CO$', decimalDigits: 2);
  static const pen = Currency(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', decimalDigits: 2);
  static const inr = Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', decimalDigits: 2);
  static const cny = Currency(code: 'CNY', name: 'Chinese Yuan', symbol: 'CN¥', decimalDigits: 2);
  static const hkd = Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$', decimalDigits: 2);
  static const twd = Currency(code: 'TWD', name: 'New Taiwan Dollar', symbol: r'NT$', decimalDigits: 2);
  static const sgd = Currency(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', decimalDigits: 2);
  static const krw = Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', decimalDigits: 0);
  static const thb = Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', decimalDigits: 2);
  static const vnd = Currency(code: 'VND', name: 'Vietnamese Đồng', symbol: '₫', decimalDigits: 0);
  static const idr = Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', decimalDigits: 2);
  static const myr = Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', decimalDigits: 2);
  static const php = Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', decimalDigits: 2);
  static const zar = Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', decimalDigits: 2);
  static const ngn = Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', decimalDigits: 2);
  static const kes = Currency(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', decimalDigits: 2);
  static const egp = Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', decimalDigits: 2);
  static const mad = Currency(code: 'MAD', name: 'Moroccan Dirham', symbol: 'MAD', decimalDigits: 2);
  static const try_ = Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', decimalDigits: 2);
  static const ils = Currency(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪', decimalDigits: 2);
  static const aed = Currency(code: 'AED', name: 'UAE Dirham', symbol: 'AED', decimalDigits: 2);
  static const sar = Currency(code: 'SAR', name: 'Saudi Riyal', symbol: 'SAR', decimalDigits: 2);
  static const kwd = Currency(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KD', decimalDigits: 3);
  static const bhd = Currency(code: 'BHD', name: 'Bahraini Dinar', symbol: 'BD', decimalDigits: 3);
  static const jod = Currency(code: 'JOD', name: 'Jordanian Dinar', symbol: 'JD', decimalDigits: 3);
  static const tnd = Currency(code: 'TND', name: 'Tunisian Dinar', symbol: 'DT', decimalDigits: 3);
  static const isk = Currency(code: 'ISK', name: 'Icelandic Króna', symbol: 'kr', decimalDigits: 0);

  /// All supported currencies, roughly ordered by how often they appear in
  /// shared-expense apps. The order is used by currency pickers.
  static const List<Currency> all = [
    usd,
    eur,
    gbp,
    jpy,
    chf,
    cad,
    aud,
    nzd,
    sek,
    nok,
    dkk,
    pln,
    czk,
    huf,
    ron,
    mxn,
    brl,
    ars,
    clp,
    cop,
    pen,
    inr,
    cny,
    hkd,
    twd,
    sgd,
    krw,
    thb,
    vnd,
    idr,
    myr,
    php,
    zar,
    ngn,
    kes,
    egp,
    mad,
    try_,
    ils,
    aed,
    sar,
    kwd,
    bhd,
    jod,
    tnd,
    isk,
  ];

  static final Map<String, Currency> _byCode = {for (final c in all) c.code: c};

  /// Looks up a currency by ISO code (case-insensitive). Returns null when the
  /// code is not supported.
  static Currency? byCode(String code) => _byCode[code.trim().toUpperCase()];

  /// Like [byCode] but throws an [ArgumentError] for unknown codes.
  static Currency require(String code) {
    final c = byCode(code);
    if (c == null) {
      throw ArgumentError.value(code, 'code', 'Unsupported currency code');
    }
    return c;
  }

  static bool isSupported(String code) => byCode(code) != null;
}
