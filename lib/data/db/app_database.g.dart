// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta('baseCurrency');
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDemoMeta = const VerificationMeta('isDemo');
  @override
  late final GeneratedColumn<bool> isDemo = GeneratedColumn<bool>(
    'is_demo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_demo" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, baseCurrency, emoji, isDemo, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<GroupRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(_baseCurrencyMeta, baseCurrency.isAcceptableOrUnknown(data['base_currency']!, _baseCurrencyMeta));
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(_emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('is_demo')) {
      context.handle(_isDemoMeta, isDemo.isAcceptableOrUnknown(data['is_demo']!, _isDemoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      baseCurrency: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}base_currency'])!,
      emoji: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      isDemo: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_demo'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class GroupRow extends DataClass implements Insertable<GroupRow> {
  final String id;
  final String name;
  final String baseCurrency;
  final String emoji;
  final bool isDemo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GroupRow({
    required this.id,
    required this.name,
    required this.baseCurrency,
    required this.emoji,
    required this.isDemo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['emoji'] = Variable<String>(emoji);
    map['is_demo'] = Variable<bool>(isDemo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      baseCurrency: Value(baseCurrency),
      emoji: Value(emoji),
      isDemo: Value(isDemo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GroupRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      emoji: serializer.fromJson<String>(json['emoji']),
      isDemo: serializer.fromJson<bool>(json['isDemo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'emoji': serializer.toJson<String>(emoji),
      'isDemo': serializer.toJson<bool>(isDemo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GroupRow copyWith({
    String? id,
    String? name,
    String? baseCurrency,
    String? emoji,
    bool? isDemo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GroupRow(
    id: id ?? this.id,
    name: name ?? this.name,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    emoji: emoji ?? this.emoji,
    isDemo: isDemo ?? this.isDemo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GroupRow copyWithCompanion(GroupsCompanion data) {
    return GroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      baseCurrency: data.baseCurrency.present ? data.baseCurrency.value : this.baseCurrency,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      isDemo: data.isDemo.present ? data.isDemo.value : this.isDemo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('emoji: $emoji, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, baseCurrency, emoji, isDemo, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.baseCurrency == this.baseCurrency &&
          other.emoji == this.emoji &&
          other.isDemo == this.isDemo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupsCompanion extends UpdateCompanion<GroupRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> baseCurrency;
  final Value<String> emoji;
  final Value<bool> isDemo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    required String baseCurrency,
    required String emoji,
    this.isDemo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       baseCurrency = Value(baseCurrency),
       emoji = Value(emoji),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GroupRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? baseCurrency,
    Expression<String>? emoji,
    Expression<bool>? isDemo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (emoji != null) 'emoji': emoji,
      if (isDemo != null) 'is_demo': isDemo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? baseCurrency,
    Value<String>? emoji,
    Value<bool>? isDemo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      emoji: emoji ?? this.emoji,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (isDemo.present) {
      map['is_demo'] = Variable<bool>(isDemo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('emoji: $emoji, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorIndexMeta = const VerificationMeta('colorIndex');
  @override
  late final GeneratedColumn<int> colorIndex = GeneratedColumn<int>(
    'color_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, groupId, name, colorIndex, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<MemberRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_index')) {
      context.handle(_colorIndexMeta, colorIndex.isAcceptableOrUnknown(data['color_index']!, _colorIndexMeta));
    } else if (isInserting) {
      context.missing(_colorIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color_index'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String groupId;
  final String name;
  final int colorIndex;
  final DateTime createdAt;
  const MemberRow({
    required this.id,
    required this.groupId,
    required this.name,
    required this.colorIndex,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    map['color_index'] = Variable<int>(colorIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      colorIndex: Value(colorIndex),
      createdAt: Value(createdAt),
    );
  }

  factory MemberRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      colorIndex: serializer.fromJson<int>(json['colorIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'colorIndex': serializer.toJson<int>(colorIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemberRow copyWith({String? id, String? groupId, String? name, int? colorIndex, DateTime? createdAt}) => MemberRow(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    name: name ?? this.name,
    colorIndex: colorIndex ?? this.colorIndex,
    createdAt: createdAt ?? this.createdAt,
  );
  MemberRow copyWithCompanion(MembersCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      colorIndex: data.colorIndex.present ? data.colorIndex.value : this.colorIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, name, colorIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.colorIndex == this.colorIndex &&
          other.createdAt == this.createdAt);
}

class MembersCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<int> colorIndex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    required String groupId,
    required String name,
    required int colorIndex,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       name = Value(name),
       colorIndex = Value(colorIndex),
       createdAt = Value(createdAt);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<int>? colorIndex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (colorIndex != null) 'color_index': colorIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? name,
    Value<int>? colorIndex,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MembersCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorIndex.present) {
      map['color_index'] = Variable<int>(colorIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTemplatesTable extends RecurringTemplates
    with TableInfo<$RecurringTemplatesTable, RecurringTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByMemberIdMeta = const VerificationMeta('paidByMemberId');
  @override
  late final GeneratedColumn<String> paidByMemberId = GeneratedColumn<String>(
    'paid_by_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES members (id)'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitTypeMeta = const VerificationMeta('splitType');
  @override
  late final GeneratedColumn<String> splitType = GeneratedColumn<String>(
    'split_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversionRateScaledMeta = const VerificationMeta('conversionRateScaled');
  @override
  late final GeneratedColumn<int> conversionRateScaled = GeneratedColumn<int>(
    'conversion_rate_scaled',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastGeneratedAtMeta = const VerificationMeta('lastGeneratedAt');
  @override
  late final GeneratedColumn<DateTime> lastGeneratedAt = GeneratedColumn<DateTime>(
    'last_generated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    description,
    amountMinor,
    currency,
    paidByMemberId,
    category,
    splitType,
    conversionRateScaled,
    notes,
    frequency,
    interval,
    nextDueDate,
    isActive,
    createdAt,
    lastGeneratedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_templates';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringTemplateRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(_amountMinorMeta, amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta, currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('paid_by_member_id')) {
      context.handle(
        _paidByMemberIdMeta,
        paidByMemberId.isAcceptableOrUnknown(data['paid_by_member_id']!, _paidByMemberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paidByMemberIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('split_type')) {
      context.handle(_splitTypeMeta, splitType.isAcceptableOrUnknown(data['split_type']!, _splitTypeMeta));
    } else if (isInserting) {
      context.missing(_splitTypeMeta);
    }
    if (data.containsKey('conversion_rate_scaled')) {
      context.handle(
        _conversionRateScaledMeta,
        conversionRateScaled.isAcceptableOrUnknown(data['conversion_rate_scaled']!, _conversionRateScaledMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta, frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta, interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    } else if (isInserting) {
      context.missing(_intervalMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(_nextDueDateMeta, nextDueDate.isAcceptableOrUnknown(data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta, isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_generated_at')) {
      context.handle(
        _lastGeneratedAtMeta,
        lastGeneratedAt.isAcceptableOrUnknown(data['last_generated_at']!, _lastGeneratedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTemplateRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amountMinor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      paidByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_member_id'],
      )!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      splitType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}split_type'])!,
      conversionRateScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversion_rate_scaled'],
      ),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      frequency: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      interval: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      nextDueDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
      isActive: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastGeneratedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_generated_at'],
      ),
    );
  }

  @override
  $RecurringTemplatesTable createAlias(String alias) {
    return $RecurringTemplatesTable(attachedDatabase, alias);
  }
}

class RecurringTemplateRow extends DataClass implements Insertable<RecurringTemplateRow> {
  final String id;
  final String groupId;
  final String description;
  final int amountMinor;
  final String currency;
  final String paidByMemberId;
  final String category;
  final String splitType;
  final int? conversionRateScaled;
  final String? notes;
  final String frequency;
  final int interval;
  final DateTime nextDueDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastGeneratedAt;
  const RecurringTemplateRow({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.paidByMemberId,
    required this.category,
    required this.splitType,
    this.conversionRateScaled,
    this.notes,
    required this.frequency,
    required this.interval,
    required this.nextDueDate,
    required this.isActive,
    required this.createdAt,
    this.lastGeneratedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['description'] = Variable<String>(description);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['paid_by_member_id'] = Variable<String>(paidByMemberId);
    map['category'] = Variable<String>(category);
    map['split_type'] = Variable<String>(splitType);
    if (!nullToAbsent || conversionRateScaled != null) {
      map['conversion_rate_scaled'] = Variable<int>(conversionRateScaled);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['frequency'] = Variable<String>(frequency);
    map['interval'] = Variable<int>(interval);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastGeneratedAt != null) {
      map['last_generated_at'] = Variable<DateTime>(lastGeneratedAt);
    }
    return map;
  }

  RecurringTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTemplatesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      description: Value(description),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paidByMemberId: Value(paidByMemberId),
      category: Value(category),
      splitType: Value(splitType),
      conversionRateScaled: conversionRateScaled == null && nullToAbsent
          ? const Value.absent()
          : Value(conversionRateScaled),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      frequency: Value(frequency),
      interval: Value(interval),
      nextDueDate: Value(nextDueDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      lastGeneratedAt: lastGeneratedAt == null && nullToAbsent ? const Value.absent() : Value(lastGeneratedAt),
    );
  }

  factory RecurringTemplateRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      description: serializer.fromJson<String>(json['description']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paidByMemberId: serializer.fromJson<String>(json['paidByMemberId']),
      category: serializer.fromJson<String>(json['category']),
      splitType: serializer.fromJson<String>(json['splitType']),
      conversionRateScaled: serializer.fromJson<int?>(json['conversionRateScaled']),
      notes: serializer.fromJson<String?>(json['notes']),
      frequency: serializer.fromJson<String>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastGeneratedAt: serializer.fromJson<DateTime?>(json['lastGeneratedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'description': serializer.toJson<String>(description),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paidByMemberId': serializer.toJson<String>(paidByMemberId),
      'category': serializer.toJson<String>(category),
      'splitType': serializer.toJson<String>(splitType),
      'conversionRateScaled': serializer.toJson<int?>(conversionRateScaled),
      'notes': serializer.toJson<String?>(notes),
      'frequency': serializer.toJson<String>(frequency),
      'interval': serializer.toJson<int>(interval),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastGeneratedAt': serializer.toJson<DateTime?>(lastGeneratedAt),
    };
  }

  RecurringTemplateRow copyWith({
    String? id,
    String? groupId,
    String? description,
    int? amountMinor,
    String? currency,
    String? paidByMemberId,
    String? category,
    String? splitType,
    Value<int?> conversionRateScaled = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? frequency,
    int? interval,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? createdAt,
    Value<DateTime?> lastGeneratedAt = const Value.absent(),
  }) => RecurringTemplateRow(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    description: description ?? this.description,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    category: category ?? this.category,
    splitType: splitType ?? this.splitType,
    conversionRateScaled: conversionRateScaled.present ? conversionRateScaled.value : this.conversionRateScaled,
    notes: notes.present ? notes.value : this.notes,
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    lastGeneratedAt: lastGeneratedAt.present ? lastGeneratedAt.value : this.lastGeneratedAt,
  );
  RecurringTemplateRow copyWithCompanion(RecurringTemplatesCompanion data) {
    return RecurringTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      description: data.description.present ? data.description.value : this.description,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paidByMemberId: data.paidByMemberId.present ? data.paidByMemberId.value : this.paidByMemberId,
      category: data.category.present ? data.category.value : this.category,
      splitType: data.splitType.present ? data.splitType.value : this.splitType,
      conversionRateScaled: data.conversionRateScaled.present
          ? data.conversionRateScaled.value
          : this.conversionRateScaled,
      notes: data.notes.present ? data.notes.value : this.notes,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      nextDueDate: data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastGeneratedAt: data.lastGeneratedAt.present ? data.lastGeneratedAt.value : this.lastGeneratedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplateRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('description: $description, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('category: $category, ')
          ..write('splitType: $splitType, ')
          ..write('conversionRateScaled: $conversionRateScaled, ')
          ..write('notes: $notes, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastGeneratedAt: $lastGeneratedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    description,
    amountMinor,
    currency,
    paidByMemberId,
    category,
    splitType,
    conversionRateScaled,
    notes,
    frequency,
    interval,
    nextDueDate,
    isActive,
    createdAt,
    lastGeneratedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTemplateRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.description == this.description &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paidByMemberId == this.paidByMemberId &&
          other.category == this.category &&
          other.splitType == this.splitType &&
          other.conversionRateScaled == this.conversionRateScaled &&
          other.notes == this.notes &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.nextDueDate == this.nextDueDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.lastGeneratedAt == this.lastGeneratedAt);
}

class RecurringTemplatesCompanion extends UpdateCompanion<RecurringTemplateRow> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> description;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> paidByMemberId;
  final Value<String> category;
  final Value<String> splitType;
  final Value<int?> conversionRateScaled;
  final Value<String?> notes;
  final Value<String> frequency;
  final Value<int> interval;
  final Value<DateTime> nextDueDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastGeneratedAt;
  final Value<int> rowid;
  const RecurringTemplatesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.description = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paidByMemberId = const Value.absent(),
    this.category = const Value.absent(),
    this.splitType = const Value.absent(),
    this.conversionRateScaled = const Value.absent(),
    this.notes = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastGeneratedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTemplatesCompanion.insert({
    required String id,
    required String groupId,
    required String description,
    required int amountMinor,
    required String currency,
    required String paidByMemberId,
    required String category,
    required String splitType,
    this.conversionRateScaled = const Value.absent(),
    this.notes = const Value.absent(),
    required String frequency,
    required int interval,
    required DateTime nextDueDate,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.lastGeneratedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       description = Value(description),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       paidByMemberId = Value(paidByMemberId),
       category = Value(category),
       splitType = Value(splitType),
       frequency = Value(frequency),
       interval = Value(interval),
       nextDueDate = Value(nextDueDate),
       createdAt = Value(createdAt);
  static Insertable<RecurringTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? description,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paidByMemberId,
    Expression<String>? category,
    Expression<String>? splitType,
    Expression<int>? conversionRateScaled,
    Expression<String>? notes,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<DateTime>? nextDueDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastGeneratedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (description != null) 'description': description,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paidByMemberId != null) 'paid_by_member_id': paidByMemberId,
      if (category != null) 'category': category,
      if (splitType != null) 'split_type': splitType,
      if (conversionRateScaled != null) 'conversion_rate_scaled': conversionRateScaled,
      if (notes != null) 'notes': notes,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (lastGeneratedAt != null) 'last_generated_at': lastGeneratedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? description,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? paidByMemberId,
    Value<String>? category,
    Value<String>? splitType,
    Value<int?>? conversionRateScaled,
    Value<String?>? notes,
    Value<String>? frequency,
    Value<int>? interval,
    Value<DateTime>? nextDueDate,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastGeneratedAt,
    Value<int>? rowid,
  }) {
    return RecurringTemplatesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      category: category ?? this.category,
      splitType: splitType ?? this.splitType,
      conversionRateScaled: conversionRateScaled ?? this.conversionRateScaled,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paidByMemberId.present) {
      map['paid_by_member_id'] = Variable<String>(paidByMemberId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (splitType.present) {
      map['split_type'] = Variable<String>(splitType.value);
    }
    if (conversionRateScaled.present) {
      map['conversion_rate_scaled'] = Variable<int>(conversionRateScaled.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastGeneratedAt.present) {
      map['last_generated_at'] = Variable<DateTime>(lastGeneratedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('description: $description, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('category: $category, ')
          ..write('splitType: $splitType, ')
          ..write('conversionRateScaled: $conversionRateScaled, ')
          ..write('notes: $notes, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastGeneratedAt: $lastGeneratedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTemplateSharesTable extends RecurringTemplateShares
    with TableInfo<$RecurringTemplateSharesTable, RecurringTemplateShareRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTemplateSharesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _templateIdMeta = const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES recurring_templates (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES members (id)'),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitValueMeta = const VerificationMeta('splitValue');
  @override
  late final GeneratedColumn<int> splitValue = GeneratedColumn<int>(
    'split_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [templateId, memberId, amountMinor, splitValue, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_template_shares';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringTemplateShareRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('template_id')) {
      context.handle(_templateIdMeta, templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta, memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(_amountMinorMeta, amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('split_value')) {
      context.handle(_splitValueMeta, splitValue.isAcceptableOrUnknown(data['split_value']!, _splitValueMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {templateId, memberId};
  @override
  RecurringTemplateShareRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTemplateShareRow(
      templateId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      memberId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      amountMinor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      splitValue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}split_value']),
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $RecurringTemplateSharesTable createAlias(String alias) {
    return $RecurringTemplateSharesTable(attachedDatabase, alias);
  }
}

class RecurringTemplateShareRow extends DataClass implements Insertable<RecurringTemplateShareRow> {
  final String templateId;
  final String memberId;
  final int amountMinor;
  final int? splitValue;
  final int position;
  const RecurringTemplateShareRow({
    required this.templateId,
    required this.memberId,
    required this.amountMinor,
    this.splitValue,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['template_id'] = Variable<String>(templateId);
    map['member_id'] = Variable<String>(memberId);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || splitValue != null) {
      map['split_value'] = Variable<int>(splitValue);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  RecurringTemplateSharesCompanion toCompanion(bool nullToAbsent) {
    return RecurringTemplateSharesCompanion(
      templateId: Value(templateId),
      memberId: Value(memberId),
      amountMinor: Value(amountMinor),
      splitValue: splitValue == null && nullToAbsent ? const Value.absent() : Value(splitValue),
      position: Value(position),
    );
  }

  factory RecurringTemplateShareRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTemplateShareRow(
      templateId: serializer.fromJson<String>(json['templateId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      splitValue: serializer.fromJson<int?>(json['splitValue']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'templateId': serializer.toJson<String>(templateId),
      'memberId': serializer.toJson<String>(memberId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'splitValue': serializer.toJson<int?>(splitValue),
      'position': serializer.toJson<int>(position),
    };
  }

  RecurringTemplateShareRow copyWith({
    String? templateId,
    String? memberId,
    int? amountMinor,
    Value<int?> splitValue = const Value.absent(),
    int? position,
  }) => RecurringTemplateShareRow(
    templateId: templateId ?? this.templateId,
    memberId: memberId ?? this.memberId,
    amountMinor: amountMinor ?? this.amountMinor,
    splitValue: splitValue.present ? splitValue.value : this.splitValue,
    position: position ?? this.position,
  );
  RecurringTemplateShareRow copyWithCompanion(RecurringTemplateSharesCompanion data) {
    return RecurringTemplateShareRow(
      templateId: data.templateId.present ? data.templateId.value : this.templateId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      splitValue: data.splitValue.present ? data.splitValue.value : this.splitValue,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplateShareRow(')
          ..write('templateId: $templateId, ')
          ..write('memberId: $memberId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('splitValue: $splitValue, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(templateId, memberId, amountMinor, splitValue, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTemplateShareRow &&
          other.templateId == this.templateId &&
          other.memberId == this.memberId &&
          other.amountMinor == this.amountMinor &&
          other.splitValue == this.splitValue &&
          other.position == this.position);
}

class RecurringTemplateSharesCompanion extends UpdateCompanion<RecurringTemplateShareRow> {
  final Value<String> templateId;
  final Value<String> memberId;
  final Value<int> amountMinor;
  final Value<int?> splitValue;
  final Value<int> position;
  final Value<int> rowid;
  const RecurringTemplateSharesCompanion({
    this.templateId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.splitValue = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTemplateSharesCompanion.insert({
    required String templateId,
    required String memberId,
    required int amountMinor,
    this.splitValue = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : templateId = Value(templateId),
       memberId = Value(memberId),
       amountMinor = Value(amountMinor),
       position = Value(position);
  static Insertable<RecurringTemplateShareRow> custom({
    Expression<String>? templateId,
    Expression<String>? memberId,
    Expression<int>? amountMinor,
    Expression<int>? splitValue,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (templateId != null) 'template_id': templateId,
      if (memberId != null) 'member_id': memberId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (splitValue != null) 'split_value': splitValue,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTemplateSharesCompanion copyWith({
    Value<String>? templateId,
    Value<String>? memberId,
    Value<int>? amountMinor,
    Value<int?>? splitValue,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return RecurringTemplateSharesCompanion(
      templateId: templateId ?? this.templateId,
      memberId: memberId ?? this.memberId,
      amountMinor: amountMinor ?? this.amountMinor,
      splitValue: splitValue ?? this.splitValue,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (splitValue.present) {
      map['split_value'] = Variable<int>(splitValue.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTemplateSharesCompanion(')
          ..write('templateId: $templateId, ')
          ..write('memberId: $memberId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('splitValue: $splitValue, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidByMemberIdMeta = const VerificationMeta('paidByMemberId');
  @override
  late final GeneratedColumn<String> paidByMemberId = GeneratedColumn<String>(
    'paid_by_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES members (id)'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitTypeMeta = const VerificationMeta('splitType');
  @override
  late final GeneratedColumn<String> splitType = GeneratedColumn<String>(
    'split_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversionRateScaledMeta = const VerificationMeta('conversionRateScaled');
  @override
  late final GeneratedColumn<int> conversionRateScaled = GeneratedColumn<int>(
    'conversion_rate_scaled',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringTemplateIdMeta = const VerificationMeta('recurringTemplateId');
  @override
  late final GeneratedColumn<String> recurringTemplateId = GeneratedColumn<String>(
    'recurring_template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES recurring_templates (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    description,
    amountMinor,
    currency,
    paidByMemberId,
    category,
    date,
    splitType,
    conversionRateScaled,
    notes,
    recurringTemplateId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(_amountMinorMeta, amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta, currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('paid_by_member_id')) {
      context.handle(
        _paidByMemberIdMeta,
        paidByMemberId.isAcceptableOrUnknown(data['paid_by_member_id']!, _paidByMemberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paidByMemberIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta, category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('split_type')) {
      context.handle(_splitTypeMeta, splitType.isAcceptableOrUnknown(data['split_type']!, _splitTypeMeta));
    } else if (isInserting) {
      context.missing(_splitTypeMeta);
    }
    if (data.containsKey('conversion_rate_scaled')) {
      context.handle(
        _conversionRateScaledMeta,
        conversionRateScaled.isAcceptableOrUnknown(data['conversion_rate_scaled']!, _conversionRateScaledMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('recurring_template_id')) {
      context.handle(
        _recurringTemplateIdMeta,
        recurringTemplateId.isAcceptableOrUnknown(data['recurring_template_id']!, _recurringTemplateIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amountMinor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      paidByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_member_id'],
      )!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      splitType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}split_type'])!,
      conversionRateScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversion_rate_scaled'],
      ),
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      recurringTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_template_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final String groupId;
  final String description;
  final int amountMinor;
  final String currency;
  final String paidByMemberId;
  final String category;
  final DateTime date;
  final String splitType;
  final int? conversionRateScaled;
  final String? notes;
  final String? recurringTemplateId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExpenseRow({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amountMinor,
    required this.currency,
    required this.paidByMemberId,
    required this.category,
    required this.date,
    required this.splitType,
    this.conversionRateScaled,
    this.notes,
    this.recurringTemplateId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['description'] = Variable<String>(description);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['paid_by_member_id'] = Variable<String>(paidByMemberId);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    map['split_type'] = Variable<String>(splitType);
    if (!nullToAbsent || conversionRateScaled != null) {
      map['conversion_rate_scaled'] = Variable<int>(conversionRateScaled);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || recurringTemplateId != null) {
      map['recurring_template_id'] = Variable<String>(recurringTemplateId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      description: Value(description),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      paidByMemberId: Value(paidByMemberId),
      category: Value(category),
      date: Value(date),
      splitType: Value(splitType),
      conversionRateScaled: conversionRateScaled == null && nullToAbsent
          ? const Value.absent()
          : Value(conversionRateScaled),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      recurringTemplateId: recurringTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringTemplateId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpenseRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      description: serializer.fromJson<String>(json['description']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      paidByMemberId: serializer.fromJson<String>(json['paidByMemberId']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      splitType: serializer.fromJson<String>(json['splitType']),
      conversionRateScaled: serializer.fromJson<int?>(json['conversionRateScaled']),
      notes: serializer.fromJson<String?>(json['notes']),
      recurringTemplateId: serializer.fromJson<String?>(json['recurringTemplateId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'description': serializer.toJson<String>(description),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'paidByMemberId': serializer.toJson<String>(paidByMemberId),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'splitType': serializer.toJson<String>(splitType),
      'conversionRateScaled': serializer.toJson<int?>(conversionRateScaled),
      'notes': serializer.toJson<String?>(notes),
      'recurringTemplateId': serializer.toJson<String?>(recurringTemplateId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExpenseRow copyWith({
    String? id,
    String? groupId,
    String? description,
    int? amountMinor,
    String? currency,
    String? paidByMemberId,
    String? category,
    DateTime? date,
    String? splitType,
    Value<int?> conversionRateScaled = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> recurringTemplateId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExpenseRow(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    description: description ?? this.description,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    category: category ?? this.category,
    date: date ?? this.date,
    splitType: splitType ?? this.splitType,
    conversionRateScaled: conversionRateScaled.present ? conversionRateScaled.value : this.conversionRateScaled,
    notes: notes.present ? notes.value : this.notes,
    recurringTemplateId: recurringTemplateId.present ? recurringTemplateId.value : this.recurringTemplateId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      description: data.description.present ? data.description.value : this.description,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      paidByMemberId: data.paidByMemberId.present ? data.paidByMemberId.value : this.paidByMemberId,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      splitType: data.splitType.present ? data.splitType.value : this.splitType,
      conversionRateScaled: data.conversionRateScaled.present
          ? data.conversionRateScaled.value
          : this.conversionRateScaled,
      notes: data.notes.present ? data.notes.value : this.notes,
      recurringTemplateId: data.recurringTemplateId.present ? data.recurringTemplateId.value : this.recurringTemplateId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('description: $description, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('splitType: $splitType, ')
          ..write('conversionRateScaled: $conversionRateScaled, ')
          ..write('notes: $notes, ')
          ..write('recurringTemplateId: $recurringTemplateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    description,
    amountMinor,
    currency,
    paidByMemberId,
    category,
    date,
    splitType,
    conversionRateScaled,
    notes,
    recurringTemplateId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.description == this.description &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.paidByMemberId == this.paidByMemberId &&
          other.category == this.category &&
          other.date == this.date &&
          other.splitType == this.splitType &&
          other.conversionRateScaled == this.conversionRateScaled &&
          other.notes == this.notes &&
          other.recurringTemplateId == this.recurringTemplateId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> description;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> paidByMemberId;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<String> splitType;
  final Value<int?> conversionRateScaled;
  final Value<String?> notes;
  final Value<String?> recurringTemplateId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.description = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.paidByMemberId = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.splitType = const Value.absent(),
    this.conversionRateScaled = const Value.absent(),
    this.notes = const Value.absent(),
    this.recurringTemplateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String groupId,
    required String description,
    required int amountMinor,
    required String currency,
    required String paidByMemberId,
    required String category,
    required DateTime date,
    required String splitType,
    this.conversionRateScaled = const Value.absent(),
    this.notes = const Value.absent(),
    this.recurringTemplateId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       description = Value(description),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       paidByMemberId = Value(paidByMemberId),
       category = Value(category),
       date = Value(date),
       splitType = Value(splitType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? description,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? paidByMemberId,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? splitType,
    Expression<int>? conversionRateScaled,
    Expression<String>? notes,
    Expression<String>? recurringTemplateId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (description != null) 'description': description,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (paidByMemberId != null) 'paid_by_member_id': paidByMemberId,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (splitType != null) 'split_type': splitType,
      if (conversionRateScaled != null) 'conversion_rate_scaled': conversionRateScaled,
      if (notes != null) 'notes': notes,
      if (recurringTemplateId != null) 'recurring_template_id': recurringTemplateId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? description,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? paidByMemberId,
    Value<String>? category,
    Value<DateTime>? date,
    Value<String>? splitType,
    Value<int?>? conversionRateScaled,
    Value<String?>? notes,
    Value<String?>? recurringTemplateId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      category: category ?? this.category,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      conversionRateScaled: conversionRateScaled ?? this.conversionRateScaled,
      notes: notes ?? this.notes,
      recurringTemplateId: recurringTemplateId ?? this.recurringTemplateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paidByMemberId.present) {
      map['paid_by_member_id'] = Variable<String>(paidByMemberId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (splitType.present) {
      map['split_type'] = Variable<String>(splitType.value);
    }
    if (conversionRateScaled.present) {
      map['conversion_rate_scaled'] = Variable<int>(conversionRateScaled.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recurringTemplateId.present) {
      map['recurring_template_id'] = Variable<String>(recurringTemplateId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('description: $description, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('paidByMemberId: $paidByMemberId, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('splitType: $splitType, ')
          ..write('conversionRateScaled: $conversionRateScaled, ')
          ..write('notes: $notes, ')
          ..write('recurringTemplateId: $recurringTemplateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseSharesTable extends ExpenseShares with TableInfo<$ExpenseSharesTable, ExpenseShareRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseSharesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _expenseIdMeta = const VerificationMeta('expenseId');
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES expenses (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES members (id)'),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitValueMeta = const VerificationMeta('splitValue');
  @override
  late final GeneratedColumn<int> splitValue = GeneratedColumn<int>(
    'split_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [expenseId, memberId, amountMinor, splitValue, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_shares';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseShareRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('expense_id')) {
      context.handle(_expenseIdMeta, expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta));
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta, memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(_amountMinorMeta, amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('split_value')) {
      context.handle(_splitValueMeta, splitValue.isAcceptableOrUnknown(data['split_value']!, _splitValueMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta, position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {expenseId, memberId};
  @override
  ExpenseShareRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseShareRow(
      expenseId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}expense_id'])!,
      memberId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      amountMinor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      splitValue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}split_value']),
      position: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $ExpenseSharesTable createAlias(String alias) {
    return $ExpenseSharesTable(attachedDatabase, alias);
  }
}

class ExpenseShareRow extends DataClass implements Insertable<ExpenseShareRow> {
  final String expenseId;
  final String memberId;
  final int amountMinor;
  final int? splitValue;

  /// Preserves the participant order chosen in the editor.
  final int position;
  const ExpenseShareRow({
    required this.expenseId,
    required this.memberId,
    required this.amountMinor,
    this.splitValue,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['expense_id'] = Variable<String>(expenseId);
    map['member_id'] = Variable<String>(memberId);
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || splitValue != null) {
      map['split_value'] = Variable<int>(splitValue);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  ExpenseSharesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseSharesCompanion(
      expenseId: Value(expenseId),
      memberId: Value(memberId),
      amountMinor: Value(amountMinor),
      splitValue: splitValue == null && nullToAbsent ? const Value.absent() : Value(splitValue),
      position: Value(position),
    );
  }

  factory ExpenseShareRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseShareRow(
      expenseId: serializer.fromJson<String>(json['expenseId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      splitValue: serializer.fromJson<int?>(json['splitValue']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'expenseId': serializer.toJson<String>(expenseId),
      'memberId': serializer.toJson<String>(memberId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'splitValue': serializer.toJson<int?>(splitValue),
      'position': serializer.toJson<int>(position),
    };
  }

  ExpenseShareRow copyWith({
    String? expenseId,
    String? memberId,
    int? amountMinor,
    Value<int?> splitValue = const Value.absent(),
    int? position,
  }) => ExpenseShareRow(
    expenseId: expenseId ?? this.expenseId,
    memberId: memberId ?? this.memberId,
    amountMinor: amountMinor ?? this.amountMinor,
    splitValue: splitValue.present ? splitValue.value : this.splitValue,
    position: position ?? this.position,
  );
  ExpenseShareRow copyWithCompanion(ExpenseSharesCompanion data) {
    return ExpenseShareRow(
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      splitValue: data.splitValue.present ? data.splitValue.value : this.splitValue,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseShareRow(')
          ..write('expenseId: $expenseId, ')
          ..write('memberId: $memberId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('splitValue: $splitValue, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(expenseId, memberId, amountMinor, splitValue, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseShareRow &&
          other.expenseId == this.expenseId &&
          other.memberId == this.memberId &&
          other.amountMinor == this.amountMinor &&
          other.splitValue == this.splitValue &&
          other.position == this.position);
}

class ExpenseSharesCompanion extends UpdateCompanion<ExpenseShareRow> {
  final Value<String> expenseId;
  final Value<String> memberId;
  final Value<int> amountMinor;
  final Value<int?> splitValue;
  final Value<int> position;
  final Value<int> rowid;
  const ExpenseSharesCompanion({
    this.expenseId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.splitValue = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseSharesCompanion.insert({
    required String expenseId,
    required String memberId,
    required int amountMinor,
    this.splitValue = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : expenseId = Value(expenseId),
       memberId = Value(memberId),
       amountMinor = Value(amountMinor),
       position = Value(position);
  static Insertable<ExpenseShareRow> custom({
    Expression<String>? expenseId,
    Expression<String>? memberId,
    Expression<int>? amountMinor,
    Expression<int>? splitValue,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (expenseId != null) 'expense_id': expenseId,
      if (memberId != null) 'member_id': memberId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (splitValue != null) 'split_value': splitValue,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseSharesCompanion copyWith({
    Value<String>? expenseId,
    Value<String>? memberId,
    Value<int>? amountMinor,
    Value<int?>? splitValue,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return ExpenseSharesCompanion(
      expenseId: expenseId ?? this.expenseId,
      memberId: memberId ?? this.memberId,
      amountMinor: amountMinor ?? this.amountMinor,
      splitValue: splitValue ?? this.splitValue,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (splitValue.present) {
      map['split_value'] = Variable<int>(splitValue.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseSharesCompanion(')
          ..write('expenseId: $expenseId, ')
          ..write('memberId: $memberId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('splitValue: $splitValue, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementsTable extends Settlements with TableInfo<$SettlementsTable, SettlementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES "groups" (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _fromMemberIdMeta = const VerificationMeta('fromMemberId');
  @override
  late final GeneratedColumn<String> fromMemberId = GeneratedColumn<String>(
    'from_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES members (id)'),
  );
  static const VerificationMeta _toMemberIdMeta = const VerificationMeta('toMemberId');
  @override
  late final GeneratedColumn<String> toMemberId = GeneratedColumn<String>(
    'to_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES members (id)'),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversionRateScaledMeta = const VerificationMeta('conversionRateScaled');
  @override
  late final GeneratedColumn<int> conversionRateScaled = GeneratedColumn<int>(
    'conversion_rate_scaled',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    fromMemberId,
    toMemberId,
    amountMinor,
    currency,
    conversionRateScaled,
    date,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlements';
  @override
  VerificationContext validateIntegrity(Insertable<SettlementRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta, groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('from_member_id')) {
      context.handle(_fromMemberIdMeta, fromMemberId.isAcceptableOrUnknown(data['from_member_id']!, _fromMemberIdMeta));
    } else if (isInserting) {
      context.missing(_fromMemberIdMeta);
    }
    if (data.containsKey('to_member_id')) {
      context.handle(_toMemberIdMeta, toMemberId.isAcceptableOrUnknown(data['to_member_id']!, _toMemberIdMeta));
    } else if (isInserting) {
      context.missing(_toMemberIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(_amountMinorMeta, amountMinor.isAcceptableOrUnknown(data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta, currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('conversion_rate_scaled')) {
      context.handle(
        _conversionRateScaledMeta,
        conversionRateScaled.isAcceptableOrUnknown(data['conversion_rate_scaled']!, _conversionRateScaledMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettlementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettlementRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      fromMemberId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}from_member_id'])!,
      toMemberId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}to_member_id'])!,
      amountMinor: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      conversionRateScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversion_rate_scaled'],
      ),
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SettlementsTable createAlias(String alias) {
    return $SettlementsTable(attachedDatabase, alias);
  }
}

class SettlementRow extends DataClass implements Insertable<SettlementRow> {
  final String id;
  final String groupId;
  final String fromMemberId;
  final String toMemberId;
  final int amountMinor;
  final String currency;
  final int? conversionRateScaled;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  const SettlementRow({
    required this.id,
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountMinor,
    required this.currency,
    this.conversionRateScaled,
    required this.date,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['from_member_id'] = Variable<String>(fromMemberId);
    map['to_member_id'] = Variable<String>(toMemberId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || conversionRateScaled != null) {
      map['conversion_rate_scaled'] = Variable<int>(conversionRateScaled);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SettlementsCompanion toCompanion(bool nullToAbsent) {
    return SettlementsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      fromMemberId: Value(fromMemberId),
      toMemberId: Value(toMemberId),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      conversionRateScaled: conversionRateScaled == null && nullToAbsent
          ? const Value.absent()
          : Value(conversionRateScaled),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory SettlementRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettlementRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      fromMemberId: serializer.fromJson<String>(json['fromMemberId']),
      toMemberId: serializer.fromJson<String>(json['toMemberId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      conversionRateScaled: serializer.fromJson<int?>(json['conversionRateScaled']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'fromMemberId': serializer.toJson<String>(fromMemberId),
      'toMemberId': serializer.toJson<String>(toMemberId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'conversionRateScaled': serializer.toJson<int?>(conversionRateScaled),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SettlementRow copyWith({
    String? id,
    String? groupId,
    String? fromMemberId,
    String? toMemberId,
    int? amountMinor,
    String? currency,
    Value<int?> conversionRateScaled = const Value.absent(),
    DateTime? date,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => SettlementRow(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    fromMemberId: fromMemberId ?? this.fromMemberId,
    toMemberId: toMemberId ?? this.toMemberId,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    conversionRateScaled: conversionRateScaled.present ? conversionRateScaled.value : this.conversionRateScaled,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  SettlementRow copyWithCompanion(SettlementsCompanion data) {
    return SettlementRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      fromMemberId: data.fromMemberId.present ? data.fromMemberId.value : this.fromMemberId,
      toMemberId: data.toMemberId.present ? data.toMemberId.value : this.toMemberId,
      amountMinor: data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      conversionRateScaled: data.conversionRateScaled.present
          ? data.conversionRateScaled.value
          : this.conversionRateScaled,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettlementRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('fromMemberId: $fromMemberId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('conversionRateScaled: $conversionRateScaled, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    fromMemberId,
    toMemberId,
    amountMinor,
    currency,
    conversionRateScaled,
    date,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettlementRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.fromMemberId == this.fromMemberId &&
          other.toMemberId == this.toMemberId &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.conversionRateScaled == this.conversionRateScaled &&
          other.date == this.date &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class SettlementsCompanion extends UpdateCompanion<SettlementRow> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> fromMemberId;
  final Value<String> toMemberId;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int?> conversionRateScaled;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SettlementsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.fromMemberId = const Value.absent(),
    this.toMemberId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.conversionRateScaled = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementsCompanion.insert({
    required String id,
    required String groupId,
    required String fromMemberId,
    required String toMemberId,
    required int amountMinor,
    required String currency,
    this.conversionRateScaled = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       fromMemberId = Value(fromMemberId),
       toMemberId = Value(toMemberId),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<SettlementRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? fromMemberId,
    Expression<String>? toMemberId,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? conversionRateScaled,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (fromMemberId != null) 'from_member_id': fromMemberId,
      if (toMemberId != null) 'to_member_id': toMemberId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (conversionRateScaled != null) 'conversion_rate_scaled': conversionRateScaled,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementsCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? fromMemberId,
    Value<String>? toMemberId,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<int?>? conversionRateScaled,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SettlementsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      conversionRateScaled: conversionRateScaled ?? this.conversionRateScaled,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (fromMemberId.present) {
      map['from_member_id'] = Variable<String>(fromMemberId.value);
    }
    if (toMemberId.present) {
      map['to_member_id'] = Variable<String>(toMemberId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (conversionRateScaled.present) {
      map['conversion_rate_scaled'] = Variable<int>(conversionRateScaled.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('fromMemberId: $fromMemberId, ')
          ..write('toMemberId: $toMemberId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('conversionRateScaled: $conversionRateScaled, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries with TableInfo<$SettingEntriesTable, SettingEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SettingEntryRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntryRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntryRow extends DataClass implements Insertable<SettingEntryRow> {
  final String key;
  final String value;
  const SettingEntryRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntryRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntryRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SettingEntryRow copyWith({String? key, String? value}) =>
      SettingEntryRow(key: key ?? this.key, value: value ?? this.value);
  SettingEntryRow copyWithCompanion(SettingEntriesCompanion data) {
    return SettingEntryRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntryRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SettingEntryRow && other.key == this.key && other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingEntryRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SettingEntryRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingEntriesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $RecurringTemplatesTable recurringTemplates = $RecurringTemplatesTable(this);
  late final $RecurringTemplateSharesTable recurringTemplateShares = $RecurringTemplateSharesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ExpenseSharesTable expenseShares = $ExpenseSharesTable(this);
  late final $SettlementsTable settlements = $SettlementsTable(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    groups,
    members,
    recurringTemplates,
    recurringTemplateShares,
    expenses,
    expenseShares,
    settlements,
    settingEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('recurring_templates', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('recurring_templates', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('recurring_template_shares', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('recurring_templates', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('expenses', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('expense_shares', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('groups', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('settlements', kind: UpdateKind.delete)],
    ),
  ]);
}
