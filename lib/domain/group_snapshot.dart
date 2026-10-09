import 'package:meta/meta.dart';

import 'accounting/accounting.dart';
import 'models/models.dart';

/// Everything about one group, loaded together: the inputs to every screen
/// and to export. Balances are derived here exactly once.
@immutable
class GroupSnapshot {
  GroupSnapshot({
    required this.group,
    required this.members,
    required this.expenses,
    required this.settlements,
    required this.templates,
  }) : balances = BalanceCalculator.compute(
         group: group,
         members: members,
         expenses: expenses,
         settlements: settlements,
       );

  final Group group;
  final List<Member> members;
  final List<Expense> expenses;
  final List<Settlement> settlements;
  final List<RecurringTemplate> templates;
  final BalanceSheet balances;

  Member? memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  String memberName(String id) => memberById(id)?.name ?? 'Unknown';

  bool get isEmpty => expenses.isEmpty && settlements.isEmpty;

  /// Settlement suggestions for the current balances.
  List<Transfer> suggestions(SettlementMode mode) => switch (mode) {
    SettlementMode.simplified => DebtSimplifier.simplify({
      for (final b in balances.byMember.values) b.memberId: b.balance.minorUnits,
    }, group.baseCurrency),
    SettlementMode.direct => BalanceCalculator.pairwiseDebts(
      group: group,
      expenses: expenses,
      settlements: settlements,
    ),
  };
}
