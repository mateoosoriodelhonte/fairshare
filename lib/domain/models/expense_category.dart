/// Expense categories. Kept as a closed enum so exports are stable and
/// reports can group reliably.
enum ExpenseCategory {
  food,
  groceries,
  drinks,
  transport,
  housing,
  utilities,
  entertainment,
  travel,
  shopping,
  health,
  gifts,
  other;

  String get key => name;

  String get label => switch (this) {
    ExpenseCategory.food => 'Food & dining',
    ExpenseCategory.groceries => 'Groceries',
    ExpenseCategory.drinks => 'Drinks',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.housing => 'Housing & rent',
    ExpenseCategory.utilities => 'Utilities',
    ExpenseCategory.entertainment => 'Entertainment',
    ExpenseCategory.travel => 'Travel',
    ExpenseCategory.shopping => 'Shopping',
    ExpenseCategory.health => 'Health',
    ExpenseCategory.gifts => 'Gifts',
    ExpenseCategory.other => 'Other',
  };

  static ExpenseCategory fromKey(String key) =>
      ExpenseCategory.values.firstWhere((e) => e.name == key, orElse: () => ExpenseCategory.other);
}
