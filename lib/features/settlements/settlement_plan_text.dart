import '../../domain/accounting/transfer.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/app_preferences.dart';

/// Plain-text rendering of a settlement plan, suitable for pasting into a
/// group chat. Pure Dart so it is unit-testable.
String settlementPlanText(GroupSnapshot snapshot, List<Transfer> transfers, SettlementMode mode) {
  final buffer = StringBuffer('${snapshot.group.name} · settle up (${mode.key})');
  if (transfers.isEmpty) {
    buffer.write('\nEveryone is settled up.');
    return buffer.toString();
  }
  for (final t in transfers) {
    buffer.write(
      '\n${snapshot.memberName(t.fromMemberId)} pays ${snapshot.memberName(t.toMemberId)} ${t.amount.format()}',
    );
  }
  buffer.write('\n\nShared from FairShare. Balances are exact; the plan is a suggestion.');
  return buffer.toString();
}
