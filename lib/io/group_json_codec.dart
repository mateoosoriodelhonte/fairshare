import 'dart:convert';

import '../core/money/money_exports.dart';
import '../domain/accounting/accounting.dart';
import '../domain/group_snapshot.dart';
import '../domain/models/models.dart';

/// A validation failure while reading a FairShare JSON document. [path]
/// points at the offending element (e.g. `expenses[3].shares`).
class ImportException implements Exception {
  const ImportException(this.message, [this.path = '']);

  final String message;
  final String path;

  @override
  String toString() => path.isEmpty ? message : '$path: $message';
}

/// A fully validated group read from JSON, with the ids as they appear in
/// the document. [GroupImporter] assigns fresh ids when persisting.
class ImportedGroup {
  const ImportedGroup({
    required this.group,
    required this.members,
    required this.expenses,
    required this.settlements,
    required this.templates,
  });

  final Group group;
  final List<Member> members;
  final List<Expense> expenses;
  final List<Settlement> settlements;
  final List<RecurringTemplate> templates;
}

/// Serialises a group to a versioned, human-readable JSON document and
/// validates documents back into domain objects.
///
/// Money is written as integer minor units next to an ISO code; rates as
/// decimal strings; dates as ISO-8601. The format is documented in
/// `docs/DATA_FORMAT.md`.
class GroupJsonCodec {
  GroupJsonCodec._();

  static const String appName = 'fairshare';
  static const int schemaVersion = 1;

  // ---------------------------------------------------------------------------
  // Encoding
  // ---------------------------------------------------------------------------

  static String encodeToString(GroupSnapshot snapshot, {DateTime? exportedAt}) =>
      const JsonEncoder.withIndent('  ').convert(encode(snapshot, exportedAt: exportedAt));

  static Map<String, Object?> encode(GroupSnapshot snapshot, {DateTime? exportedAt}) {
    final g = snapshot.group;
    return {
      'app': appName,
      'schemaVersion': schemaVersion,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'group': {
        'id': g.id,
        'name': g.name,
        'baseCurrency': g.baseCurrency.code,
        'emoji': g.emoji,
        'isDemo': g.isDemo,
        'createdAt': g.createdAt.toIso8601String(),
        'updatedAt': g.updatedAt.toIso8601String(),
      },
      'members': [
        for (final m in snapshot.members)
          {'id': m.id, 'name': m.name, 'colorIndex': m.colorIndex, 'createdAt': m.createdAt.toIso8601String()},
      ],
      'expenses': [for (final e in snapshot.expenses) _encodeExpense(e)],
      'settlements': [
        for (final s in snapshot.settlements)
          {
            'id': s.id,
            'fromMemberId': s.fromMemberId,
            'toMemberId': s.toMemberId,
            'amount': _money(s.amount),
            'conversionRate': s.conversionRate?.toDecimalString(),
            'date': _date(s.date),
            'note': s.note,
            'createdAt': s.createdAt.toIso8601String(),
          },
      ],
      'recurringTemplates': [
        for (final t in snapshot.templates)
          {
            'id': t.id,
            'description': t.description,
            'amount': _money(t.amount),
            'paidByMemberId': t.paidByMemberId,
            'category': t.category.key,
            'splitType': t.splitType.key,
            'shares': [for (final s in t.shares) _share(s)],
            'conversionRate': t.conversionRate?.toDecimalString(),
            'notes': t.notes,
            'frequency': t.frequency.key,
            'interval': t.interval,
            'nextDueDate': _date(t.nextDueDate),
            'isActive': t.isActive,
            'createdAt': t.createdAt.toIso8601String(),
            'lastGeneratedAt': t.lastGeneratedAt?.toIso8601String(),
          },
      ],
    };
  }

  static Map<String, Object?> _encodeExpense(Expense e) => {
    'id': e.id,
    'description': e.description,
    'amount': _money(e.amount),
    'paidByMemberId': e.paidByMemberId,
    'category': e.category.key,
    'date': _date(e.date),
    'splitType': e.splitType.key,
    'shares': [for (final s in e.shares) _share(s)],
    'conversionRate': e.conversionRate?.toDecimalString(),
    'notes': e.notes,
    'recurringTemplateId': e.recurringTemplateId,
    'createdAt': e.createdAt.toIso8601String(),
    'updatedAt': e.updatedAt.toIso8601String(),
  };

  static Map<String, Object?> _money(Money m) => {'minorUnits': m.minorUnits, 'currency': m.currency.code};

  static Map<String, Object?> _share(ExpenseShare s) => {
    'memberId': s.memberId,
    'amountMinor': s.amountMinor,
    'splitValue': s.splitValue,
  };

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------------------
  // Decoding
  // ---------------------------------------------------------------------------

  static ImportedGroup decodeString(String text) {
    Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException catch (e) {
      throw ImportException('The file is not valid JSON (${e.message}).');
    }
    return decode(json);
  }

  static ImportedGroup decode(Object? json) {
    final root = _obj(json, 'document');
    final app = root['app'];
    if (app != appName) {
      throw const ImportException('This is not a FairShare export (missing "app": "fairshare").');
    }
    final version = root['schemaVersion'];
    if (version is! int) {
      throw const ImportException('Missing or invalid schemaVersion.', 'schemaVersion');
    }
    if (version != schemaVersion) {
      throw ImportException(
        'Unsupported schema version $version; this app reads version $schemaVersion.',
        'schemaVersion',
      );
    }

    final groupJson = _obj(root['group'], 'group');
    final name = _string(groupJson, 'name', 'group').trim();
    if (name.isEmpty) throw const ImportException('Group name is empty.', 'group.name');
    final currencyCode = _string(groupJson, 'baseCurrency', 'group');
    final base = Currencies.byCode(currencyCode);
    if (base == null) {
      throw ImportException('Unsupported currency "$currencyCode".', 'group.baseCurrency');
    }
    final group = Group(
      id: _string(groupJson, 'id', 'group'),
      name: name,
      baseCurrency: base,
      emoji: (groupJson['emoji'] as String?)?.trim().isNotEmpty == true ? groupJson['emoji'] as String : '👥',
      isDemo: groupJson['isDemo'] == true,
      createdAt: _dateTime(groupJson['createdAt'], 'group.createdAt'),
      updatedAt: _dateTime(groupJson['updatedAt'], 'group.updatedAt'),
    );

    final membersJson = _list(root['members'], 'members');
    final members = <Member>[];
    final memberIds = <String>{};
    final memberNames = <String>{};
    for (var i = 0; i < membersJson.length; i++) {
      final path = 'members[$i]';
      final m = _obj(membersJson[i], path);
      final id = _string(m, 'id', path);
      if (!memberIds.add(id)) {
        throw ImportException('Duplicate member id "$id".', path);
      }
      final memberName = _string(m, 'name', path).trim();
      if (memberName.isEmpty) {
        throw ImportException('Member name is empty.', '$path.name');
      }
      if (!memberNames.add(memberName.toLowerCase())) {
        throw ImportException('Duplicate member name "$memberName".', '$path.name');
      }
      members.add(
        Member(
          id: id,
          groupId: group.id,
          name: memberName,
          colorIndex: _intOr(m['colorIndex'], i, '$path.colorIndex'),
          createdAt: _dateTime(m['createdAt'], '$path.createdAt'),
        ),
      );
    }
    if (members.isEmpty) throw const ImportException('The group has no members.', 'members');

    String memberRef(Object? value, String path) {
      if (value is! String || !memberIds.contains(value)) {
        throw ImportException('Unknown member reference "$value".', path);
      }
      return value;
    }

    final expensesJson = _list(root['expenses'] ?? const [], 'expenses');
    final expenses = <Expense>[];
    final expenseIds = <String>{};
    for (var i = 0; i < expensesJson.length; i++) {
      final path = 'expenses[$i]';
      final e = _obj(expensesJson[i], path);
      final id = _string(e, 'id', path);
      if (!expenseIds.add(id)) {
        throw ImportException('Duplicate expense id "$id".', path);
      }
      final amount = _moneyValue(e['amount'], '$path.amount');
      if (!amount.isPositive) {
        throw ImportException('Amount must be greater than zero.', '$path.amount');
      }
      final splitType = _splitType(e['splitType'], '$path.splitType');
      final shares = _shares(e['shares'], '$path.shares', memberRef, amount);
      final rate = _rate(e['conversionRate'], amount.currency, base, '$path.conversionRate');
      expenses.add(
        Expense(
          id: id,
          groupId: group.id,
          description: _string(e, 'description', path),
          amount: amount,
          paidByMemberId: memberRef(e['paidByMemberId'], '$path.paidByMemberId'),
          category: _category(e['category'], '$path.category'),
          date: _dateOnly(e['date'], '$path.date'),
          splitType: splitType,
          shares: shares,
          conversionRate: rate,
          notes: e['notes'] as String?,
          recurringTemplateId: e['recurringTemplateId'] as String?,
          createdAt: _dateTime(e['createdAt'], '$path.createdAt'),
          updatedAt: _dateTime(e['updatedAt'], '$path.updatedAt'),
        ),
      );
    }

    final settlementsJson = _list(root['settlements'] ?? const [], 'settlements');
    final settlements = <Settlement>[];
    for (var i = 0; i < settlementsJson.length; i++) {
      final path = 'settlements[$i]';
      final s = _obj(settlementsJson[i], path);
      final amount = _moneyValue(s['amount'], '$path.amount');
      if (!amount.isPositive) {
        throw ImportException('Amount must be greater than zero.', '$path.amount');
      }
      final from = memberRef(s['fromMemberId'], '$path.fromMemberId');
      final to = memberRef(s['toMemberId'], '$path.toMemberId');
      if (from == to) {
        throw ImportException('A settlement needs two different people.', path);
      }
      settlements.add(
        Settlement(
          id: _string(s, 'id', path),
          groupId: group.id,
          fromMemberId: from,
          toMemberId: to,
          amount: amount,
          conversionRate: _rate(s['conversionRate'], amount.currency, base, '$path.conversionRate'),
          date: _dateOnly(s['date'], '$path.date'),
          note: s['note'] as String?,
          createdAt: _dateTime(s['createdAt'], '$path.createdAt'),
        ),
      );
    }

    final templatesJson = _list(root['recurringTemplates'] ?? const [], 'recurringTemplates');
    final templates = <RecurringTemplate>[];
    final templateIds = <String>{};
    for (var i = 0; i < templatesJson.length; i++) {
      final path = 'recurringTemplates[$i]';
      final t = _obj(templatesJson[i], path);
      final id = _string(t, 'id', path);
      if (!templateIds.add(id)) {
        throw ImportException('Duplicate template id "$id".', path);
      }
      final amount = _moneyValue(t['amount'], '$path.amount');
      if (!amount.isPositive) {
        throw ImportException('Amount must be greater than zero.', '$path.amount');
      }
      final interval = _intOr(t['interval'], 1, '$path.interval');
      if (interval < 1) {
        throw ImportException('Interval must be at least 1.', '$path.interval');
      }
      final frequencyKey = _string(t, 'frequency', path);
      final RecurrenceFrequency frequency;
      try {
        frequency = RecurrenceFrequency.fromKey(frequencyKey);
      } on ArgumentError {
        throw ImportException('Unknown frequency "$frequencyKey".', '$path.frequency');
      }
      templates.add(
        RecurringTemplate(
          id: id,
          groupId: group.id,
          description: _string(t, 'description', path),
          amount: amount,
          paidByMemberId: memberRef(t['paidByMemberId'], '$path.paidByMemberId'),
          category: _category(t['category'], '$path.category'),
          splitType: _splitType(t['splitType'], '$path.splitType'),
          shares: _shares(t['shares'], '$path.shares', memberRef, amount),
          conversionRate: _rate(t['conversionRate'], amount.currency, base, '$path.conversionRate'),
          notes: t['notes'] as String?,
          frequency: frequency,
          interval: interval,
          nextDueDate: _dateOnly(t['nextDueDate'], '$path.nextDueDate'),
          isActive: t['isActive'] != false,
          createdAt: _dateTime(t['createdAt'], '$path.createdAt'),
          lastGeneratedAt: t['lastGeneratedAt'] == null
              ? null
              : _dateTime(t['lastGeneratedAt'], '$path.lastGeneratedAt'),
        ),
      );
    }
    // Expenses may point at templates; dangling references are cleared
    // rather than rejected, since templates can be deleted legitimately.
    final linked = [
      for (final e in expenses)
        if (e.recurringTemplateId != null && !templateIds.contains(e.recurringTemplateId))
          e.copyWith(clearRecurringTemplateId: true)
        else
          e,
    ];

    // Final sanity check: the ledger must balance exactly.
    final sheet = BalanceCalculator.compute(group: group, members: members, expenses: linked, settlements: settlements);
    if (!sheet.isBalanced) {
      throw const ImportException('The ledger does not balance; the file appears to be corrupted.');
    }

    return ImportedGroup(
      group: group,
      members: members,
      expenses: linked,
      settlements: settlements,
      templates: templates,
    );
  }

  // --- helpers ---------------------------------------------------------------

  static Map<String, Object?> _obj(Object? v, String path) {
    if (v is Map<String, Object?>) return v;
    if (v is Map) return v.cast<String, Object?>();
    throw ImportException('Expected an object.', path);
  }

  static List<Object?> _list(Object? v, String path) {
    if (v is List) return v;
    throw ImportException('Expected a list.', path);
  }

  static String _string(Map<String, Object?> m, String key, String path) {
    final v = m[key];
    if (v is String) return v;
    throw ImportException('Missing or invalid "$key".', '$path.$key');
  }

  static int _intOr(Object? v, int fallback, String path) {
    if (v == null) return fallback;
    if (v is int) return v;
    throw ImportException('Expected a whole number.', path);
  }

  static DateTime _dateTime(Object? v, String path) {
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed;
    }
    throw ImportException('Invalid date/time "$v".', path);
  }

  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static DateTime _dateOnly(Object? v, String path) {
    if (v is String) {
      final m = _datePattern.firstMatch(v);
      if (m != null) {
        final year = int.parse(m.group(1)!);
        final month = int.parse(m.group(2)!);
        final day = int.parse(m.group(3)!);
        final d = DateTime(year, month, day);
        // Dart rolls invalid dates over (Feb 30 -> Mar 2); reject those.
        if (d.year == year && d.month == month && d.day == day) return d;
        throw ImportException('Invalid date "$v" (expected YYYY-MM-DD).', path);
      }
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);
    }
    throw ImportException('Invalid date "$v" (expected YYYY-MM-DD).', path);
  }

  static Money _moneyValue(Object? v, String path) {
    final m = _obj(v, path);
    final minor = m['minorUnits'];
    if (minor is! int) {
      throw ImportException('minorUnits must be an integer.', '$path.minorUnits');
    }
    final code = m['currency'];
    final currency = code is String ? Currencies.byCode(code) : null;
    if (currency == null) {
      throw ImportException('Unsupported currency "$code".', '$path.currency');
    }
    return Money(minor, currency);
  }

  static ConversionRate? _rate(Object? v, Currency from, Currency base, String path) {
    if (from == base) return null;
    if (v is! String) {
      throw ImportException('A rate to ${base.code} is required for ${from.code} amounts.', path);
    }
    try {
      return ConversionRate.parse(v);
    } on FormatException catch (e) {
      throw ImportException('Invalid rate "$v" (${e.message}).', path);
    }
  }

  static SplitType _splitType(Object? v, String path) {
    if (v is String) {
      try {
        return SplitType.fromKey(v);
      } on ArgumentError {
        // fall through
      }
    }
    throw ImportException('Unknown split type "$v".', path);
  }

  static ExpenseCategory _category(Object? v, String path) {
    if (v is String && ExpenseCategory.values.any((c) => c.key == v)) return ExpenseCategory.fromKey(v);
    throw ImportException('Unknown category "$v".', path);
  }

  static List<ExpenseShare> _shares(Object? v, String path, String Function(Object?, String) memberRef, Money total) {
    final list = _list(v, path);
    if (list.isEmpty) {
      throw ImportException('At least one share is required.', path);
    }
    final shares = <ExpenseShare>[];
    final seen = <String>{};
    var sum = 0;
    for (var i = 0; i < list.length; i++) {
      final s = _obj(list[i], '$path[$i]');
      final memberId = memberRef(s['memberId'], '$path[$i].memberId');
      if (!seen.add(memberId)) {
        throw ImportException('Member "$memberId" appears twice.', '$path[$i]');
      }
      final amount = s['amountMinor'];
      if (amount is! int || amount < 0) {
        throw ImportException('amountMinor must be a non-negative integer.', '$path[$i].amountMinor');
      }
      final splitValue = s['splitValue'];
      if (splitValue != null && splitValue is! int) {
        throw ImportException('splitValue must be an integer.', '$path[$i].splitValue');
      }
      sum += amount;
      shares.add(ExpenseShare(memberId: memberId, amountMinor: amount, splitValue: splitValue as int?));
    }
    if (sum != total.minorUnits) {
      throw ImportException('Shares add up to $sum minor units but the amount is ${total.minorUnits}.', path);
    }
    return shares;
  }
}
