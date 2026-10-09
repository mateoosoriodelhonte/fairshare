/// How an expense's total is divided between participants.
enum SplitType {
  /// Everyone pays the same; remainder minor units go to the first participants.
  equal,

  /// Each participant is assigned a percentage expressed in basis points
  /// (1% = 100 bp). The percentages must sum to exactly 10,000 bp.
  percentage,

  /// Each participant holds an integer number of shares; the total is divided
  /// proportionally to the share count.
  shares,

  /// Each participant's amount is entered explicitly and must sum to the total.
  exact;

  String get key => name;

  String get label => switch (this) {
    SplitType.equal => 'Equally',
    SplitType.percentage => 'By percentage',
    SplitType.shares => 'By shares',
    SplitType.exact => 'Exact amounts',
  };

  static SplitType fromKey(String key) => SplitType.values.firstWhere(
    (e) => e.name == key,
    orElse: () => throw ArgumentError.value(key, 'key', 'Unknown split type'),
  );
}
