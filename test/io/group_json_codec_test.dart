import 'dart:convert';

import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/group_snapshot.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:fairshare/io/group_json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  GroupSnapshot sample() {
    final g = testGroup(currency: Currencies.eur);
    final ms = members(['a', 'b', 'c']);
    final e1 = expense(
      amountMinor: 3000,
      paidBy: 'a',
      participants: ['a', 'b', 'c'],
      currency: Currencies.eur,
    ).copyWith(notes: 'Pizza "night", with commas');
    final e2 = expense(
      amountMinor: 1000,
      paidBy: 'b',
      participants: ['a', 'b'],
      currency: Currencies.gbp,
      rate: ConversionRate.parse('1.17'),
      splitType: SplitType.percentage,
      shares: const [
        ExpenseShare(memberId: 'a', amountMinor: 700, splitValue: 7000),
        ExpenseShare(memberId: 'b', amountMinor: 300, splitValue: 3000),
      ],
    );
    final t = RecurringTemplate(
      id: 'r1',
      groupId: g.id,
      description: 'Rent',
      amount: const Money(90000, Currencies.eur),
      paidByMemberId: 'a',
      category: ExpenseCategory.housing,
      splitType: SplitType.equal,
      shares: const [
        ExpenseShare(memberId: 'a', amountMinor: 30000),
        ExpenseShare(memberId: 'b', amountMinor: 30000),
        ExpenseShare(memberId: 'c', amountMinor: 30000),
      ],
      frequency: RecurrenceFrequency.monthly,
      interval: 1,
      nextDueDate: DateTime(2026, 11, 1),
      isActive: true,
      createdAt: t0,
      lastGeneratedAt: DateTime(2026, 10, 1, 9),
    );
    final e3 = expense(
      amountMinor: 90000,
      paidBy: 'a',
      participants: ['a', 'b', 'c'],
      currency: Currencies.eur,
    ).copyWith(recurringTemplateId: 'r1');
    return GroupSnapshot(
      group: g,
      members: ms,
      expenses: [e3, e2, e1],
      settlements: [settlement(from: 'b', to: 'a', amountMinor: 500, currency: Currencies.eur)],
      templates: [t],
    );
  }

  group('GroupJsonCodec', () {
    test('round-trips a full group byte-for-byte in domain terms', () {
      final s = sample();
      final text = GroupJsonCodec.encodeToString(s, exportedAt: DateTime.utc(2026, 10, 9));
      expect(text, contains('"schemaVersion": 1'));
      final decoded = GroupJsonCodec.decodeString(text);
      expect(decoded.group, s.group);
      expect(decoded.members, s.members);
      expect(decoded.expenses, s.expenses);
      expect(decoded.settlements, s.settlements);
      expect(decoded.templates, s.templates);
    });

    test('money is integer minor units plus ISO code; rates are decimal strings', () {
      final json = GroupJsonCodec.encode(sample(), exportedAt: DateTime.utc(2026));
      final expenses = json['expenses']! as List;
      final gbp = expenses.cast<Map<String, Object?>>().firstWhere((e) => (e['amount']! as Map)['currency'] == 'GBP');
      expect(gbp['amount'], {'minorUnits': 1000, 'currency': 'GBP'});
      expect(gbp['conversionRate'], '1.17');
      expect(gbp['date'], '2026-01-01');
    });

    Map<String, Object?> valid() => GroupJsonCodec.encode(sample(), exportedAt: DateTime.utc(2026));

    void expectRejected(Object? doc, String messagePart, {String? path}) {
      expect(
        () => GroupJsonCodec.decode(doc),
        throwsA(
          isA<ImportException>()
              .having((e) => e.message, 'message', contains(messagePart))
              .having((e) => e.path, 'path', path == null ? anything : contains(path)),
        ),
      );
    }

    test('rejects documents that are not FairShare exports', () {
      expect(
        () => GroupJsonCodec.decodeString('not json'),
        throwsA(isA<ImportException>().having((e) => e.message, 'm', contains('not valid JSON'))),
      );
      expectRejected([], 'Expected an object');
      expectRejected({'app': 'other'}, 'not a FairShare export');
      expectRejected({...valid(), 'schemaVersion': 2}, 'Unsupported schema version 2');
      expectRejected({...valid(), 'schemaVersion': 'x'}, 'schemaVersion');
    });

    test('rejects bad group and members', () {
      final v = valid();
      expectRejected(
        {
          ...v,
          'group': {...(v['group']! as Map), 'baseCurrency': 'XXX'},
        },
        'Unsupported currency',
        path: 'group.baseCurrency',
      );
      expectRejected({
        ...v,
        'group': {...(v['group']! as Map), 'name': '  '},
      }, 'name is empty');
      expectRejected({...v, 'members': <Object?>[]}, 'no members');
      final dup = [...(v['members']! as List)];
      dup.add({...(dup.first as Map)});
      expectRejected({...v, 'members': dup}, 'Duplicate member id');
      final dupName = [...(v['members']! as List)];
      dupName[1] = {...(dupName[1] as Map), 'name': (dupName[0] as Map)['name']};
      expectRejected({...v, 'members': dupName}, 'Duplicate member name');
    });

    test('rejects inconsistent expenses with a precise path', () {
      final v = valid();
      List<Object?> withExpense(Map<String, Object?> Function(Map<String, Object?>) edit, [int index = 2]) {
        final list = [...(v['expenses']! as List)];
        list[index] = edit(Map<String, Object?>.of(list[index] as Map<String, Object?>));
        return list;
      }

      expectRejected(
        {
          ...v,
          'expenses': withExpense((e) => {...e, 'paidByMemberId': 'ghost'}),
        },
        'Unknown member reference',
        path: 'expenses[2].paidByMemberId',
      );
      expectRejected(
        {
          ...v,
          'expenses': withExpense(
            (e) => {
              ...e,
              'amount': {'minorUnits': 2999, 'currency': 'EUR'},
            },
          ),
        },
        'Shares add up to 3000',
        path: 'expenses[2].shares',
      );
      expectRejected({
        ...v,
        'expenses': withExpense(
          (e) => {
            ...e,
            'amount': {'minorUnits': 0, 'currency': 'EUR'},
          },
        ),
      }, 'greater than zero');
      expectRejected({
        ...v,
        'expenses': withExpense(
          (e) => {
            ...e,
            'amount': {'minorUnits': 30.5, 'currency': 'EUR'},
          },
        ),
      }, 'integer');
      expectRejected(
        {
          ...v,
          'expenses': withExpense((e) => {...e, 'date': '2026-02-30'}),
        },
        'Invalid date',
        path: 'expenses[2].date',
      );
      expectRejected({
        ...v,
        'expenses': withExpense((e) => {...e, 'splitType': 'magic'}),
      }, 'Unknown split type');
      expectRejected({
        ...v,
        'expenses': withExpense((e) => {...e, 'category': 'crypto'}),
      }, 'Unknown category');
      expectRejected(
        {
          ...v,
          'expenses': withExpense((e) => {...e, 'conversionRate': null}, 1),
        },
        'rate to EUR is required',
        path: 'expenses[1].conversionRate',
      );
      expectRejected({
        ...v,
        'expenses': withExpense((e) => {...e, 'conversionRate': '0'}, 1),
      }, 'Invalid rate');
      expectRejected({
        ...v,
        'expenses': withExpense((e) => {...e, 'shares': []}),
      }, 'At least one share');
      expectRejected({
        ...v,
        'expenses': withExpense(
          (e) => {
            ...e,
            'shares': [
              {'memberId': 'a', 'amountMinor': 3000},
              {'memberId': 'a', 'amountMinor': 0},
            ],
          },
        ),
      }, 'appears twice');
    });

    test('rejects bad settlements and templates', () {
      final v = valid();
      final s = Map<String, Object?>.of((v['settlements']! as List).first as Map<String, Object?>);
      expectRejected({
        ...v,
        'settlements': [
          {...s, 'toMemberId': 'b'},
        ],
      }, 'two different people');
      expectRejected({
        ...v,
        'settlements': [
          {
            ...s,
            'amount': {'minorUnits': -5, 'currency': 'EUR'},
          },
        ],
      }, 'greater than zero');
      final t = Map<String, Object?>.of((v['recurringTemplates']! as List).first as Map<String, Object?>);
      expectRejected({
        ...v,
        'recurringTemplates': [
          {...t, 'frequency': 'fortnightly'},
        ],
      }, 'Unknown frequency');
      expectRejected({
        ...v,
        'recurringTemplates': [
          {...t, 'interval': 0},
        ],
      }, 'at least 1');
    });

    test('a dangling recurringTemplateId is cleared, not rejected', () {
      final v = valid();
      final decoded = GroupJsonCodec.decode({...v, 'recurringTemplates': <Object?>[]});
      expect(decoded.expenses.every((e) => e.recurringTemplateId == null), isTrue);
    });

    test('optional sections may be omitted', () {
      final v = valid()
        ..remove('expenses')
        ..remove('settlements')
        ..remove('recurringTemplates');
      final decoded = GroupJsonCodec.decode(v);
      expect(decoded.expenses, isEmpty);
      expect(decoded.settlements, isEmpty);
      expect(decoded.templates, isEmpty);
    });

    test('exported text is pretty-printed and parseable JSON', () {
      final text = GroupJsonCodec.encodeToString(sample(), exportedAt: DateTime.utc(2026));
      expect(text.split('\n').length, greaterThan(20));
      expect(jsonDecode(text), isA<Map<String, Object?>>());
    });
  });
}
