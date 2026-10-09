import 'package:drift/drift.dart';

/// Drift table definitions. Money is stored as integer minor units next to an
/// ISO 4217 code; dates as ISO-8601 text (see `AppDatabase.options`).
///
/// Foreign keys are enforced (`PRAGMA foreign_keys = ON`). Deleting a group
/// cascades to everything it owns. Member references from expenses and
/// settlements deliberately have *no* cascade: a member with history cannot
/// be deleted, which keeps every ledger entry attributable.

@DataClassName('GroupRow')
class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get baseCurrency => text().withLength(min: 3, max: 3)();
  TextColumn get emoji => text()();
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get colorIndex => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurringTemplateRow')
class RecurringTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get paidByMemberId => text().references(Members, #id)();
  TextColumn get category => text()();
  TextColumn get splitType => text()();
  IntColumn get conversionRateScaled => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get frequency => text()();
  IntColumn get interval => integer()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastGeneratedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RecurringTemplateShareRow')
class RecurringTemplateShares extends Table {
  TextColumn get templateId => text().references(RecurringTemplates, #id, onDelete: KeyAction.cascade)();
  TextColumn get memberId => text().references(Members, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get splitValue => integer().nullable()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {templateId, memberId};
}

@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  TextColumn get paidByMemberId => text().references(Members, #id)();
  TextColumn get category => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get splitType => text()();
  IntColumn get conversionRateScaled => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get recurringTemplateId =>
      text().nullable().references(RecurringTemplates, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ExpenseShareRow')
class ExpenseShares extends Table {
  TextColumn get expenseId => text().references(Expenses, #id, onDelete: KeyAction.cascade)();
  TextColumn get memberId => text().references(Members, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get splitValue => integer().nullable()();

  /// Preserves the participant order chosen in the editor.
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {expenseId, memberId};
}

@DataClassName('SettlementRow')
class Settlements extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get fromMemberId => text().references(Members, #id)();
  TextColumn get toMemberId => text().references(Members, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  IntColumn get conversionRateScaled => integer().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SettingEntryRow')
class SettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
