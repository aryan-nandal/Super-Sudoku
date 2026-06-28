// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $KeyValueEntriesTable extends KeyValueEntries
    with TableInfo<$KeyValueEntriesTable, KeyValueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValueEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'key_value_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValueEntriesTable createAlias(String alias) {
    return $KeyValueEntriesTable(attachedDatabase, alias);
  }
}

class KeyValueEntry extends DataClass implements Insertable<KeyValueEntry> {
  final String key;
  final String value;
  const KeyValueEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValueEntriesCompanion toCompanion(bool nullToAbsent) {
    return KeyValueEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValueEntry copyWith({String? key, String? value}) =>
      KeyValueEntry(key: key ?? this.key, value: value ?? this.value);
  KeyValueEntry copyWithCompanion(KeyValueEntriesCompanion data) {
    return KeyValueEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class KeyValueEntriesCompanion extends UpdateCompanion<KeyValueEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValueEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValueEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValueEntry> custom({
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

  KeyValueEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValueEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
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
    return (StringBuffer('KeyValueEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSavesTable extends GameSaves
    with TableInfo<$GameSavesTable, GameSaveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSavesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puzzleMeta = const VerificationMeta('puzzle');
  @override
  late final GeneratedColumn<String> puzzle = GeneratedColumn<String>(
    'puzzle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _solutionMeta = const VerificationMeta(
    'solution',
  );
  @override
  late final GeneratedColumn<String> solution = GeneratedColumn<String>(
    'solution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cellValuesMeta = const VerificationMeta(
    'cellValues',
  );
  @override
  late final GeneratedColumn<String> cellValues = GeneratedColumn<String>(
    'cell_values',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesMeta = const VerificationMeta(
    'mistakes',
  );
  @override
  late final GeneratedColumn<int> mistakes = GeneratedColumn<int>(
    'mistakes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyIndexMeta = const VerificationMeta(
    'difficultyIndex',
  );
  @override
  late final GeneratedColumn<int> difficultyIndex = GeneratedColumn<int>(
    'difficulty_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDailyMeta = const VerificationMeta(
    'isDaily',
  );
  @override
  late final GeneratedColumn<bool> isDaily = GeneratedColumn<bool>(
    'is_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_daily" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
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
    puzzle,
    solution,
    cellValues,
    notes,
    mistakes,
    elapsedSeconds,
    difficultyIndex,
    isDaily,
    dayNumber,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_saves';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSaveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('puzzle')) {
      context.handle(
        _puzzleMeta,
        puzzle.isAcceptableOrUnknown(data['puzzle']!, _puzzleMeta),
      );
    } else if (isInserting) {
      context.missing(_puzzleMeta);
    }
    if (data.containsKey('solution')) {
      context.handle(
        _solutionMeta,
        solution.isAcceptableOrUnknown(data['solution']!, _solutionMeta),
      );
    } else if (isInserting) {
      context.missing(_solutionMeta);
    }
    if (data.containsKey('cell_values')) {
      context.handle(
        _cellValuesMeta,
        cellValues.isAcceptableOrUnknown(data['cell_values']!, _cellValuesMeta),
      );
    } else if (isInserting) {
      context.missing(_cellValuesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('mistakes')) {
      context.handle(
        _mistakesMeta,
        mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakesMeta);
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedSecondsMeta);
    }
    if (data.containsKey('difficulty_index')) {
      context.handle(
        _difficultyIndexMeta,
        difficultyIndex.isAcceptableOrUnknown(
          data['difficulty_index']!,
          _difficultyIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_difficultyIndexMeta);
    }
    if (data.containsKey('is_daily')) {
      context.handle(
        _isDailyMeta,
        isDaily.isAcceptableOrUnknown(data['is_daily']!, _isDailyMeta),
      );
    } else if (isInserting) {
      context.missing(_isDailyMeta);
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSaveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSaveRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      puzzle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}puzzle'],
      )!,
      solution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}solution'],
      )!,
      cellValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_values'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      mistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes'],
      )!,
      elapsedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_seconds'],
      )!,
      difficultyIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_index'],
      )!,
      isDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GameSavesTable createAlias(String alias) {
    return $GameSavesTable(attachedDatabase, alias);
  }
}

class GameSaveRow extends DataClass implements Insertable<GameSaveRow> {
  final String id;
  final String puzzle;
  final String solution;
  final String cellValues;
  final String notes;
  final int mistakes;
  final int elapsedSeconds;
  final int difficultyIndex;
  final bool isDaily;
  final int dayNumber;
  final DateTime updatedAt;
  const GameSaveRow({
    required this.id,
    required this.puzzle,
    required this.solution,
    required this.cellValues,
    required this.notes,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.difficultyIndex,
    required this.isDaily,
    required this.dayNumber,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['puzzle'] = Variable<String>(puzzle);
    map['solution'] = Variable<String>(solution);
    map['cell_values'] = Variable<String>(cellValues);
    map['notes'] = Variable<String>(notes);
    map['mistakes'] = Variable<int>(mistakes);
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['difficulty_index'] = Variable<int>(difficultyIndex);
    map['is_daily'] = Variable<bool>(isDaily);
    map['day_number'] = Variable<int>(dayNumber);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GameSavesCompanion toCompanion(bool nullToAbsent) {
    return GameSavesCompanion(
      id: Value(id),
      puzzle: Value(puzzle),
      solution: Value(solution),
      cellValues: Value(cellValues),
      notes: Value(notes),
      mistakes: Value(mistakes),
      elapsedSeconds: Value(elapsedSeconds),
      difficultyIndex: Value(difficultyIndex),
      isDaily: Value(isDaily),
      dayNumber: Value(dayNumber),
      updatedAt: Value(updatedAt),
    );
  }

  factory GameSaveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSaveRow(
      id: serializer.fromJson<String>(json['id']),
      puzzle: serializer.fromJson<String>(json['puzzle']),
      solution: serializer.fromJson<String>(json['solution']),
      cellValues: serializer.fromJson<String>(json['cellValues']),
      notes: serializer.fromJson<String>(json['notes']),
      mistakes: serializer.fromJson<int>(json['mistakes']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      difficultyIndex: serializer.fromJson<int>(json['difficultyIndex']),
      isDaily: serializer.fromJson<bool>(json['isDaily']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'puzzle': serializer.toJson<String>(puzzle),
      'solution': serializer.toJson<String>(solution),
      'cellValues': serializer.toJson<String>(cellValues),
      'notes': serializer.toJson<String>(notes),
      'mistakes': serializer.toJson<int>(mistakes),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'difficultyIndex': serializer.toJson<int>(difficultyIndex),
      'isDaily': serializer.toJson<bool>(isDaily),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GameSaveRow copyWith({
    String? id,
    String? puzzle,
    String? solution,
    String? cellValues,
    String? notes,
    int? mistakes,
    int? elapsedSeconds,
    int? difficultyIndex,
    bool? isDaily,
    int? dayNumber,
    DateTime? updatedAt,
  }) => GameSaveRow(
    id: id ?? this.id,
    puzzle: puzzle ?? this.puzzle,
    solution: solution ?? this.solution,
    cellValues: cellValues ?? this.cellValues,
    notes: notes ?? this.notes,
    mistakes: mistakes ?? this.mistakes,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    difficultyIndex: difficultyIndex ?? this.difficultyIndex,
    isDaily: isDaily ?? this.isDaily,
    dayNumber: dayNumber ?? this.dayNumber,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GameSaveRow copyWithCompanion(GameSavesCompanion data) {
    return GameSaveRow(
      id: data.id.present ? data.id.value : this.id,
      puzzle: data.puzzle.present ? data.puzzle.value : this.puzzle,
      solution: data.solution.present ? data.solution.value : this.solution,
      cellValues: data.cellValues.present
          ? data.cellValues.value
          : this.cellValues,
      notes: data.notes.present ? data.notes.value : this.notes,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      elapsedSeconds: data.elapsedSeconds.present
          ? data.elapsedSeconds.value
          : this.elapsedSeconds,
      difficultyIndex: data.difficultyIndex.present
          ? data.difficultyIndex.value
          : this.difficultyIndex,
      isDaily: data.isDaily.present ? data.isDaily.value : this.isDaily,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSaveRow(')
          ..write('id: $id, ')
          ..write('puzzle: $puzzle, ')
          ..write('solution: $solution, ')
          ..write('cellValues: $cellValues, ')
          ..write('notes: $notes, ')
          ..write('mistakes: $mistakes, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('difficultyIndex: $difficultyIndex, ')
          ..write('isDaily: $isDaily, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    puzzle,
    solution,
    cellValues,
    notes,
    mistakes,
    elapsedSeconds,
    difficultyIndex,
    isDaily,
    dayNumber,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSaveRow &&
          other.id == this.id &&
          other.puzzle == this.puzzle &&
          other.solution == this.solution &&
          other.cellValues == this.cellValues &&
          other.notes == this.notes &&
          other.mistakes == this.mistakes &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.difficultyIndex == this.difficultyIndex &&
          other.isDaily == this.isDaily &&
          other.dayNumber == this.dayNumber &&
          other.updatedAt == this.updatedAt);
}

class GameSavesCompanion extends UpdateCompanion<GameSaveRow> {
  final Value<String> id;
  final Value<String> puzzle;
  final Value<String> solution;
  final Value<String> cellValues;
  final Value<String> notes;
  final Value<int> mistakes;
  final Value<int> elapsedSeconds;
  final Value<int> difficultyIndex;
  final Value<bool> isDaily;
  final Value<int> dayNumber;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GameSavesCompanion({
    this.id = const Value.absent(),
    this.puzzle = const Value.absent(),
    this.solution = const Value.absent(),
    this.cellValues = const Value.absent(),
    this.notes = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.difficultyIndex = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSavesCompanion.insert({
    required String id,
    required String puzzle,
    required String solution,
    required String cellValues,
    required String notes,
    required int mistakes,
    required int elapsedSeconds,
    required int difficultyIndex,
    required bool isDaily,
    this.dayNumber = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       puzzle = Value(puzzle),
       solution = Value(solution),
       cellValues = Value(cellValues),
       notes = Value(notes),
       mistakes = Value(mistakes),
       elapsedSeconds = Value(elapsedSeconds),
       difficultyIndex = Value(difficultyIndex),
       isDaily = Value(isDaily),
       updatedAt = Value(updatedAt);
  static Insertable<GameSaveRow> custom({
    Expression<String>? id,
    Expression<String>? puzzle,
    Expression<String>? solution,
    Expression<String>? cellValues,
    Expression<String>? notes,
    Expression<int>? mistakes,
    Expression<int>? elapsedSeconds,
    Expression<int>? difficultyIndex,
    Expression<bool>? isDaily,
    Expression<int>? dayNumber,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (puzzle != null) 'puzzle': puzzle,
      if (solution != null) 'solution': solution,
      if (cellValues != null) 'cell_values': cellValues,
      if (notes != null) 'notes': notes,
      if (mistakes != null) 'mistakes': mistakes,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (difficultyIndex != null) 'difficulty_index': difficultyIndex,
      if (isDaily != null) 'is_daily': isDaily,
      if (dayNumber != null) 'day_number': dayNumber,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSavesCompanion copyWith({
    Value<String>? id,
    Value<String>? puzzle,
    Value<String>? solution,
    Value<String>? cellValues,
    Value<String>? notes,
    Value<int>? mistakes,
    Value<int>? elapsedSeconds,
    Value<int>? difficultyIndex,
    Value<bool>? isDaily,
    Value<int>? dayNumber,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GameSavesCompanion(
      id: id ?? this.id,
      puzzle: puzzle ?? this.puzzle,
      solution: solution ?? this.solution,
      cellValues: cellValues ?? this.cellValues,
      notes: notes ?? this.notes,
      mistakes: mistakes ?? this.mistakes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      difficultyIndex: difficultyIndex ?? this.difficultyIndex,
      isDaily: isDaily ?? this.isDaily,
      dayNumber: dayNumber ?? this.dayNumber,
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
    if (puzzle.present) {
      map['puzzle'] = Variable<String>(puzzle.value);
    }
    if (solution.present) {
      map['solution'] = Variable<String>(solution.value);
    }
    if (cellValues.present) {
      map['cell_values'] = Variable<String>(cellValues.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<int>(mistakes.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (difficultyIndex.present) {
      map['difficulty_index'] = Variable<int>(difficultyIndex.value);
    }
    if (isDaily.present) {
      map['is_daily'] = Variable<bool>(isDaily.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
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
    return (StringBuffer('GameSavesCompanion(')
          ..write('id: $id, ')
          ..write('puzzle: $puzzle, ')
          ..write('solution: $solution, ')
          ..write('cellValues: $cellValues, ')
          ..write('notes: $notes, ')
          ..write('mistakes: $mistakes, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('difficultyIndex: $difficultyIndex, ')
          ..write('isDaily: $isDaily, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyCompletionsTable extends DailyCompletions
    with TableInfo<$DailyCompletionsTable, DailyCompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyIndexMeta = const VerificationMeta(
    'difficultyIndex',
  );
  @override
  late final GeneratedColumn<int> difficultyIndex = GeneratedColumn<int>(
    'difficulty_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecondsMeta = const VerificationMeta(
    'timeSeconds',
  );
  @override
  late final GeneratedColumn<int> timeSeconds = GeneratedColumn<int>(
    'time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesMeta = const VerificationMeta(
    'mistakes',
  );
  @override
  late final GeneratedColumn<int> mistakes = GeneratedColumn<int>(
    'mistakes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsMeta = const VerificationMeta('hints');
  @override
  late final GeneratedColumn<int> hints = GeneratedColumn<int>(
    'hints',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    dayNumber,
    difficultyIndex,
    timeSeconds,
    mistakes,
    hints,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyCompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
    }
    if (data.containsKey('difficulty_index')) {
      context.handle(
        _difficultyIndexMeta,
        difficultyIndex.isAcceptableOrUnknown(
          data['difficulty_index']!,
          _difficultyIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_difficultyIndexMeta);
    }
    if (data.containsKey('time_seconds')) {
      context.handle(
        _timeSecondsMeta,
        timeSeconds.isAcceptableOrUnknown(
          data['time_seconds']!,
          _timeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSecondsMeta);
    }
    if (data.containsKey('mistakes')) {
      context.handle(
        _mistakesMeta,
        mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakesMeta);
    }
    if (data.containsKey('hints')) {
      context.handle(
        _hintsMeta,
        hints.isAcceptableOrUnknown(data['hints']!, _hintsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyCompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCompletionRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      difficultyIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_index'],
      )!,
      timeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_seconds'],
      )!,
      mistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes'],
      )!,
      hints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints'],
      )!,
    );
  }

  @override
  $DailyCompletionsTable createAlias(String alias) {
    return $DailyCompletionsTable(attachedDatabase, alias);
  }
}

class DailyCompletionRow extends DataClass
    implements Insertable<DailyCompletionRow> {
  final String date;
  final int dayNumber;
  final int difficultyIndex;
  final int timeSeconds;
  final int mistakes;
  final int hints;
  const DailyCompletionRow({
    required this.date,
    required this.dayNumber,
    required this.difficultyIndex,
    required this.timeSeconds,
    required this.mistakes,
    required this.hints,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['day_number'] = Variable<int>(dayNumber);
    map['difficulty_index'] = Variable<int>(difficultyIndex);
    map['time_seconds'] = Variable<int>(timeSeconds);
    map['mistakes'] = Variable<int>(mistakes);
    map['hints'] = Variable<int>(hints);
    return map;
  }

  DailyCompletionsCompanion toCompanion(bool nullToAbsent) {
    return DailyCompletionsCompanion(
      date: Value(date),
      dayNumber: Value(dayNumber),
      difficultyIndex: Value(difficultyIndex),
      timeSeconds: Value(timeSeconds),
      mistakes: Value(mistakes),
      hints: Value(hints),
    );
  }

  factory DailyCompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCompletionRow(
      date: serializer.fromJson<String>(json['date']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      difficultyIndex: serializer.fromJson<int>(json['difficultyIndex']),
      timeSeconds: serializer.fromJson<int>(json['timeSeconds']),
      mistakes: serializer.fromJson<int>(json['mistakes']),
      hints: serializer.fromJson<int>(json['hints']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'difficultyIndex': serializer.toJson<int>(difficultyIndex),
      'timeSeconds': serializer.toJson<int>(timeSeconds),
      'mistakes': serializer.toJson<int>(mistakes),
      'hints': serializer.toJson<int>(hints),
    };
  }

  DailyCompletionRow copyWith({
    String? date,
    int? dayNumber,
    int? difficultyIndex,
    int? timeSeconds,
    int? mistakes,
    int? hints,
  }) => DailyCompletionRow(
    date: date ?? this.date,
    dayNumber: dayNumber ?? this.dayNumber,
    difficultyIndex: difficultyIndex ?? this.difficultyIndex,
    timeSeconds: timeSeconds ?? this.timeSeconds,
    mistakes: mistakes ?? this.mistakes,
    hints: hints ?? this.hints,
  );
  DailyCompletionRow copyWithCompanion(DailyCompletionsCompanion data) {
    return DailyCompletionRow(
      date: data.date.present ? data.date.value : this.date,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      difficultyIndex: data.difficultyIndex.present
          ? data.difficultyIndex.value
          : this.difficultyIndex,
      timeSeconds: data.timeSeconds.present
          ? data.timeSeconds.value
          : this.timeSeconds,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      hints: data.hints.present ? data.hints.value : this.hints,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCompletionRow(')
          ..write('date: $date, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('difficultyIndex: $difficultyIndex, ')
          ..write('timeSeconds: $timeSeconds, ')
          ..write('mistakes: $mistakes, ')
          ..write('hints: $hints')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    dayNumber,
    difficultyIndex,
    timeSeconds,
    mistakes,
    hints,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCompletionRow &&
          other.date == this.date &&
          other.dayNumber == this.dayNumber &&
          other.difficultyIndex == this.difficultyIndex &&
          other.timeSeconds == this.timeSeconds &&
          other.mistakes == this.mistakes &&
          other.hints == this.hints);
}

class DailyCompletionsCompanion extends UpdateCompanion<DailyCompletionRow> {
  final Value<String> date;
  final Value<int> dayNumber;
  final Value<int> difficultyIndex;
  final Value<int> timeSeconds;
  final Value<int> mistakes;
  final Value<int> hints;
  final Value<int> rowid;
  const DailyCompletionsCompanion({
    this.date = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.difficultyIndex = const Value.absent(),
    this.timeSeconds = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.hints = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyCompletionsCompanion.insert({
    required String date,
    required int dayNumber,
    required int difficultyIndex,
    required int timeSeconds,
    required int mistakes,
    this.hints = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       dayNumber = Value(dayNumber),
       difficultyIndex = Value(difficultyIndex),
       timeSeconds = Value(timeSeconds),
       mistakes = Value(mistakes);
  static Insertable<DailyCompletionRow> custom({
    Expression<String>? date,
    Expression<int>? dayNumber,
    Expression<int>? difficultyIndex,
    Expression<int>? timeSeconds,
    Expression<int>? mistakes,
    Expression<int>? hints,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (dayNumber != null) 'day_number': dayNumber,
      if (difficultyIndex != null) 'difficulty_index': difficultyIndex,
      if (timeSeconds != null) 'time_seconds': timeSeconds,
      if (mistakes != null) 'mistakes': mistakes,
      if (hints != null) 'hints': hints,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyCompletionsCompanion copyWith({
    Value<String>? date,
    Value<int>? dayNumber,
    Value<int>? difficultyIndex,
    Value<int>? timeSeconds,
    Value<int>? mistakes,
    Value<int>? hints,
    Value<int>? rowid,
  }) {
    return DailyCompletionsCompanion(
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
      difficultyIndex: difficultyIndex ?? this.difficultyIndex,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      mistakes: mistakes ?? this.mistakes,
      hints: hints ?? this.hints,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (difficultyIndex.present) {
      map['difficulty_index'] = Variable<int>(difficultyIndex.value);
    }
    if (timeSeconds.present) {
      map['time_seconds'] = Variable<int>(timeSeconds.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<int>(mistakes.value);
    }
    if (hints.present) {
      map['hints'] = Variable<int>(hints.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyCompletionsCompanion(')
          ..write('date: $date, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('difficultyIndex: $difficultyIndex, ')
          ..write('timeSeconds: $timeSeconds, ')
          ..write('mistakes: $mistakes, ')
          ..write('hints: $hints, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameResultsTable extends GameResults
    with TableInfo<$GameResultsTable, GameResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _difficultyIndexMeta = const VerificationMeta(
    'difficultyIndex',
  );
  @override
  late final GeneratedColumn<int> difficultyIndex = GeneratedColumn<int>(
    'difficulty_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecondsMeta = const VerificationMeta(
    'timeSeconds',
  );
  @override
  late final GeneratedColumn<int> timeSeconds = GeneratedColumn<int>(
    'time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesMeta = const VerificationMeta(
    'mistakes',
  );
  @override
  late final GeneratedColumn<int> mistakes = GeneratedColumn<int>(
    'mistakes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsMeta = const VerificationMeta('hints');
  @override
  late final GeneratedColumn<int> hints = GeneratedColumn<int>(
    'hints',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDailyMeta = const VerificationMeta(
    'isDaily',
  );
  @override
  late final GeneratedColumn<bool> isDaily = GeneratedColumn<bool>(
    'is_daily',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_daily" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    difficultyIndex,
    timeSeconds,
    mistakes,
    hints,
    isDaily,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('difficulty_index')) {
      context.handle(
        _difficultyIndexMeta,
        difficultyIndex.isAcceptableOrUnknown(
          data['difficulty_index']!,
          _difficultyIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_difficultyIndexMeta);
    }
    if (data.containsKey('time_seconds')) {
      context.handle(
        _timeSecondsMeta,
        timeSeconds.isAcceptableOrUnknown(
          data['time_seconds']!,
          _timeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSecondsMeta);
    }
    if (data.containsKey('mistakes')) {
      context.handle(
        _mistakesMeta,
        mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakesMeta);
    }
    if (data.containsKey('hints')) {
      context.handle(
        _hintsMeta,
        hints.isAcceptableOrUnknown(data['hints']!, _hintsMeta),
      );
    }
    if (data.containsKey('is_daily')) {
      context.handle(
        _isDailyMeta,
        isDaily.isAcceptableOrUnknown(data['is_daily']!, _isDailyMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      difficultyIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty_index'],
      )!,
      timeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_seconds'],
      )!,
      mistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes'],
      )!,
      hints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hints'],
      )!,
      isDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daily'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $GameResultsTable createAlias(String alias) {
    return $GameResultsTable(attachedDatabase, alias);
  }
}

class GameResultRow extends DataClass implements Insertable<GameResultRow> {
  final int id;
  final int difficultyIndex;
  final int timeSeconds;
  final int mistakes;
  final int hints;
  final bool isDaily;
  final String date;
  const GameResultRow({
    required this.id,
    required this.difficultyIndex,
    required this.timeSeconds,
    required this.mistakes,
    required this.hints,
    required this.isDaily,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['difficulty_index'] = Variable<int>(difficultyIndex);
    map['time_seconds'] = Variable<int>(timeSeconds);
    map['mistakes'] = Variable<int>(mistakes);
    map['hints'] = Variable<int>(hints);
    map['is_daily'] = Variable<bool>(isDaily);
    map['date'] = Variable<String>(date);
    return map;
  }

  GameResultsCompanion toCompanion(bool nullToAbsent) {
    return GameResultsCompanion(
      id: Value(id),
      difficultyIndex: Value(difficultyIndex),
      timeSeconds: Value(timeSeconds),
      mistakes: Value(mistakes),
      hints: Value(hints),
      isDaily: Value(isDaily),
      date: Value(date),
    );
  }

  factory GameResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameResultRow(
      id: serializer.fromJson<int>(json['id']),
      difficultyIndex: serializer.fromJson<int>(json['difficultyIndex']),
      timeSeconds: serializer.fromJson<int>(json['timeSeconds']),
      mistakes: serializer.fromJson<int>(json['mistakes']),
      hints: serializer.fromJson<int>(json['hints']),
      isDaily: serializer.fromJson<bool>(json['isDaily']),
      date: serializer.fromJson<String>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'difficultyIndex': serializer.toJson<int>(difficultyIndex),
      'timeSeconds': serializer.toJson<int>(timeSeconds),
      'mistakes': serializer.toJson<int>(mistakes),
      'hints': serializer.toJson<int>(hints),
      'isDaily': serializer.toJson<bool>(isDaily),
      'date': serializer.toJson<String>(date),
    };
  }

  GameResultRow copyWith({
    int? id,
    int? difficultyIndex,
    int? timeSeconds,
    int? mistakes,
    int? hints,
    bool? isDaily,
    String? date,
  }) => GameResultRow(
    id: id ?? this.id,
    difficultyIndex: difficultyIndex ?? this.difficultyIndex,
    timeSeconds: timeSeconds ?? this.timeSeconds,
    mistakes: mistakes ?? this.mistakes,
    hints: hints ?? this.hints,
    isDaily: isDaily ?? this.isDaily,
    date: date ?? this.date,
  );
  GameResultRow copyWithCompanion(GameResultsCompanion data) {
    return GameResultRow(
      id: data.id.present ? data.id.value : this.id,
      difficultyIndex: data.difficultyIndex.present
          ? data.difficultyIndex.value
          : this.difficultyIndex,
      timeSeconds: data.timeSeconds.present
          ? data.timeSeconds.value
          : this.timeSeconds,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      hints: data.hints.present ? data.hints.value : this.hints,
      isDaily: data.isDaily.present ? data.isDaily.value : this.isDaily,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameResultRow(')
          ..write('id: $id, ')
          ..write('difficultyIndex: $difficultyIndex, ')
          ..write('timeSeconds: $timeSeconds, ')
          ..write('mistakes: $mistakes, ')
          ..write('hints: $hints, ')
          ..write('isDaily: $isDaily, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    difficultyIndex,
    timeSeconds,
    mistakes,
    hints,
    isDaily,
    date,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameResultRow &&
          other.id == this.id &&
          other.difficultyIndex == this.difficultyIndex &&
          other.timeSeconds == this.timeSeconds &&
          other.mistakes == this.mistakes &&
          other.hints == this.hints &&
          other.isDaily == this.isDaily &&
          other.date == this.date);
}

class GameResultsCompanion extends UpdateCompanion<GameResultRow> {
  final Value<int> id;
  final Value<int> difficultyIndex;
  final Value<int> timeSeconds;
  final Value<int> mistakes;
  final Value<int> hints;
  final Value<bool> isDaily;
  final Value<String> date;
  const GameResultsCompanion({
    this.id = const Value.absent(),
    this.difficultyIndex = const Value.absent(),
    this.timeSeconds = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.hints = const Value.absent(),
    this.isDaily = const Value.absent(),
    this.date = const Value.absent(),
  });
  GameResultsCompanion.insert({
    this.id = const Value.absent(),
    required int difficultyIndex,
    required int timeSeconds,
    required int mistakes,
    this.hints = const Value.absent(),
    this.isDaily = const Value.absent(),
    required String date,
  }) : difficultyIndex = Value(difficultyIndex),
       timeSeconds = Value(timeSeconds),
       mistakes = Value(mistakes),
       date = Value(date);
  static Insertable<GameResultRow> custom({
    Expression<int>? id,
    Expression<int>? difficultyIndex,
    Expression<int>? timeSeconds,
    Expression<int>? mistakes,
    Expression<int>? hints,
    Expression<bool>? isDaily,
    Expression<String>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (difficultyIndex != null) 'difficulty_index': difficultyIndex,
      if (timeSeconds != null) 'time_seconds': timeSeconds,
      if (mistakes != null) 'mistakes': mistakes,
      if (hints != null) 'hints': hints,
      if (isDaily != null) 'is_daily': isDaily,
      if (date != null) 'date': date,
    });
  }

  GameResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? difficultyIndex,
    Value<int>? timeSeconds,
    Value<int>? mistakes,
    Value<int>? hints,
    Value<bool>? isDaily,
    Value<String>? date,
  }) {
    return GameResultsCompanion(
      id: id ?? this.id,
      difficultyIndex: difficultyIndex ?? this.difficultyIndex,
      timeSeconds: timeSeconds ?? this.timeSeconds,
      mistakes: mistakes ?? this.mistakes,
      hints: hints ?? this.hints,
      isDaily: isDaily ?? this.isDaily,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (difficultyIndex.present) {
      map['difficulty_index'] = Variable<int>(difficultyIndex.value);
    }
    if (timeSeconds.present) {
      map['time_seconds'] = Variable<int>(timeSeconds.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<int>(mistakes.value);
    }
    if (hints.present) {
      map['hints'] = Variable<int>(hints.value);
    }
    if (isDaily.present) {
      map['is_daily'] = Variable<bool>(isDaily.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameResultsCompanion(')
          ..write('id: $id, ')
          ..write('difficultyIndex: $difficultyIndex, ')
          ..write('timeSeconds: $timeSeconds, ')
          ..write('mistakes: $mistakes, ')
          ..write('hints: $hints, ')
          ..write('isDaily: $isDaily, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $LessonProgressTable extends LessonProgress
    with TableInfo<$LessonProgressTable, LessonProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [nodeId, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nodeId};
  @override
  LessonProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressRow(
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }
}

class LessonProgressRow extends DataClass
    implements Insertable<LessonProgressRow> {
  final String nodeId;
  final DateTime completedAt;
  const LessonProgressRow({required this.nodeId, required this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['node_id'] = Variable<String>(nodeId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      nodeId: Value(nodeId),
      completedAt: Value(completedAt),
    );
  }

  factory LessonProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressRow(
      nodeId: serializer.fromJson<String>(json['nodeId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nodeId': serializer.toJson<String>(nodeId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  LessonProgressRow copyWith({String? nodeId, DateTime? completedAt}) =>
      LessonProgressRow(
        nodeId: nodeId ?? this.nodeId,
        completedAt: completedAt ?? this.completedAt,
      );
  LessonProgressRow copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressRow(
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressRow(')
          ..write('nodeId: $nodeId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(nodeId, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressRow &&
          other.nodeId == this.nodeId &&
          other.completedAt == this.completedAt);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressRow> {
  final Value<String> nodeId;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const LessonProgressCompanion({
    this.nodeId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    required String nodeId,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : nodeId = Value(nodeId),
       completedAt = Value(completedAt);
  static Insertable<LessonProgressRow> custom({
    Expression<String>? nodeId,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nodeId != null) 'node_id': nodeId,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressCompanion copyWith({
    Value<String>? nodeId,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return LessonProgressCompanion(
      nodeId: nodeId ?? this.nodeId,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('nodeId: $nodeId, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KeyValueEntriesTable keyValueEntries = $KeyValueEntriesTable(
    this,
  );
  late final $GameSavesTable gameSaves = $GameSavesTable(this);
  late final $DailyCompletionsTable dailyCompletions = $DailyCompletionsTable(
    this,
  );
  late final $GameResultsTable gameResults = $GameResultsTable(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    keyValueEntries,
    gameSaves,
    dailyCompletions,
    gameResults,
    lessonProgress,
  ];
}

typedef $$KeyValueEntriesTableCreateCompanionBuilder =
    KeyValueEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$KeyValueEntriesTableUpdateCompanionBuilder =
    KeyValueEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$KeyValueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValueEntriesTable> {
  $$KeyValueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValueEntriesTable> {
  $$KeyValueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValueEntriesTable> {
  $$KeyValueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValueEntriesTable,
          KeyValueEntry,
          $$KeyValueEntriesTableFilterComposer,
          $$KeyValueEntriesTableOrderingComposer,
          $$KeyValueEntriesTableAnnotationComposer,
          $$KeyValueEntriesTableCreateCompanionBuilder,
          $$KeyValueEntriesTableUpdateCompanionBuilder,
          (
            KeyValueEntry,
            BaseReferences<_$AppDatabase, $KeyValueEntriesTable, KeyValueEntry>,
          ),
          KeyValueEntry,
          PrefetchHooks Function()
        > {
  $$KeyValueEntriesTableTableManager(
    _$AppDatabase db,
    $KeyValueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KeyValueEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KeyValueEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValueEntriesTable,
      KeyValueEntry,
      $$KeyValueEntriesTableFilterComposer,
      $$KeyValueEntriesTableOrderingComposer,
      $$KeyValueEntriesTableAnnotationComposer,
      $$KeyValueEntriesTableCreateCompanionBuilder,
      $$KeyValueEntriesTableUpdateCompanionBuilder,
      (
        KeyValueEntry,
        BaseReferences<_$AppDatabase, $KeyValueEntriesTable, KeyValueEntry>,
      ),
      KeyValueEntry,
      PrefetchHooks Function()
    >;
typedef $$GameSavesTableCreateCompanionBuilder =
    GameSavesCompanion Function({
      required String id,
      required String puzzle,
      required String solution,
      required String cellValues,
      required String notes,
      required int mistakes,
      required int elapsedSeconds,
      required int difficultyIndex,
      required bool isDaily,
      Value<int> dayNumber,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$GameSavesTableUpdateCompanionBuilder =
    GameSavesCompanion Function({
      Value<String> id,
      Value<String> puzzle,
      Value<String> solution,
      Value<String> cellValues,
      Value<String> notes,
      Value<int> mistakes,
      Value<int> elapsedSeconds,
      Value<int> difficultyIndex,
      Value<bool> isDaily,
      Value<int> dayNumber,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$GameSavesTableFilterComposer
    extends Composer<_$AppDatabase, $GameSavesTable> {
  $$GameSavesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get puzzle => $composableBuilder(
    column: $table.puzzle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get solution => $composableBuilder(
    column: $table.solution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cellValues => $composableBuilder(
    column: $table.cellValues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSavesTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSavesTable> {
  $$GameSavesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get puzzle => $composableBuilder(
    column: $table.puzzle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get solution => $composableBuilder(
    column: $table.solution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cellValues => $composableBuilder(
    column: $table.cellValues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSavesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSavesTable> {
  $$GameSavesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get puzzle =>
      $composableBuilder(column: $table.puzzle, builder: (column) => column);

  GeneratedColumn<String> get solution =>
      $composableBuilder(column: $table.solution, builder: (column) => column);

  GeneratedColumn<String> get cellValues => $composableBuilder(
    column: $table.cellValues,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get mistakes =>
      $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDaily =>
      $composableBuilder(column: $table.isDaily, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GameSavesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSavesTable,
          GameSaveRow,
          $$GameSavesTableFilterComposer,
          $$GameSavesTableOrderingComposer,
          $$GameSavesTableAnnotationComposer,
          $$GameSavesTableCreateCompanionBuilder,
          $$GameSavesTableUpdateCompanionBuilder,
          (
            GameSaveRow,
            BaseReferences<_$AppDatabase, $GameSavesTable, GameSaveRow>,
          ),
          GameSaveRow,
          PrefetchHooks Function()
        > {
  $$GameSavesTableTableManager(_$AppDatabase db, $GameSavesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSavesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSavesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSavesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> puzzle = const Value.absent(),
                Value<String> solution = const Value.absent(),
                Value<String> cellValues = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<int> difficultyIndex = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSavesCompanion(
                id: id,
                puzzle: puzzle,
                solution: solution,
                cellValues: cellValues,
                notes: notes,
                mistakes: mistakes,
                elapsedSeconds: elapsedSeconds,
                difficultyIndex: difficultyIndex,
                isDaily: isDaily,
                dayNumber: dayNumber,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String puzzle,
                required String solution,
                required String cellValues,
                required String notes,
                required int mistakes,
                required int elapsedSeconds,
                required int difficultyIndex,
                required bool isDaily,
                Value<int> dayNumber = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GameSavesCompanion.insert(
                id: id,
                puzzle: puzzle,
                solution: solution,
                cellValues: cellValues,
                notes: notes,
                mistakes: mistakes,
                elapsedSeconds: elapsedSeconds,
                difficultyIndex: difficultyIndex,
                isDaily: isDaily,
                dayNumber: dayNumber,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSavesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSavesTable,
      GameSaveRow,
      $$GameSavesTableFilterComposer,
      $$GameSavesTableOrderingComposer,
      $$GameSavesTableAnnotationComposer,
      $$GameSavesTableCreateCompanionBuilder,
      $$GameSavesTableUpdateCompanionBuilder,
      (
        GameSaveRow,
        BaseReferences<_$AppDatabase, $GameSavesTable, GameSaveRow>,
      ),
      GameSaveRow,
      PrefetchHooks Function()
    >;
typedef $$DailyCompletionsTableCreateCompanionBuilder =
    DailyCompletionsCompanion Function({
      required String date,
      required int dayNumber,
      required int difficultyIndex,
      required int timeSeconds,
      required int mistakes,
      Value<int> hints,
      Value<int> rowid,
    });
typedef $$DailyCompletionsTableUpdateCompanionBuilder =
    DailyCompletionsCompanion Function({
      Value<String> date,
      Value<int> dayNumber,
      Value<int> difficultyIndex,
      Value<int> timeSeconds,
      Value<int> mistakes,
      Value<int> hints,
      Value<int> rowid,
    });

class $$DailyCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyCompletionsTable> {
  $$DailyCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hints => $composableBuilder(
    column: $table.hints,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyCompletionsTable> {
  $$DailyCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hints => $composableBuilder(
    column: $table.hints,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyCompletionsTable> {
  $$DailyCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mistakes =>
      $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<int> get hints =>
      $composableBuilder(column: $table.hints, builder: (column) => column);
}

class $$DailyCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyCompletionsTable,
          DailyCompletionRow,
          $$DailyCompletionsTableFilterComposer,
          $$DailyCompletionsTableOrderingComposer,
          $$DailyCompletionsTableAnnotationComposer,
          $$DailyCompletionsTableCreateCompanionBuilder,
          $$DailyCompletionsTableUpdateCompanionBuilder,
          (
            DailyCompletionRow,
            BaseReferences<
              _$AppDatabase,
              $DailyCompletionsTable,
              DailyCompletionRow
            >,
          ),
          DailyCompletionRow,
          PrefetchHooks Function()
        > {
  $$DailyCompletionsTableTableManager(
    _$AppDatabase db,
    $DailyCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<int> difficultyIndex = const Value.absent(),
                Value<int> timeSeconds = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<int> hints = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyCompletionsCompanion(
                date: date,
                dayNumber: dayNumber,
                difficultyIndex: difficultyIndex,
                timeSeconds: timeSeconds,
                mistakes: mistakes,
                hints: hints,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required int dayNumber,
                required int difficultyIndex,
                required int timeSeconds,
                required int mistakes,
                Value<int> hints = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyCompletionsCompanion.insert(
                date: date,
                dayNumber: dayNumber,
                difficultyIndex: difficultyIndex,
                timeSeconds: timeSeconds,
                mistakes: mistakes,
                hints: hints,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyCompletionsTable,
      DailyCompletionRow,
      $$DailyCompletionsTableFilterComposer,
      $$DailyCompletionsTableOrderingComposer,
      $$DailyCompletionsTableAnnotationComposer,
      $$DailyCompletionsTableCreateCompanionBuilder,
      $$DailyCompletionsTableUpdateCompanionBuilder,
      (
        DailyCompletionRow,
        BaseReferences<
          _$AppDatabase,
          $DailyCompletionsTable,
          DailyCompletionRow
        >,
      ),
      DailyCompletionRow,
      PrefetchHooks Function()
    >;
typedef $$GameResultsTableCreateCompanionBuilder =
    GameResultsCompanion Function({
      Value<int> id,
      required int difficultyIndex,
      required int timeSeconds,
      required int mistakes,
      Value<int> hints,
      Value<bool> isDaily,
      required String date,
    });
typedef $$GameResultsTableUpdateCompanionBuilder =
    GameResultsCompanion Function({
      Value<int> id,
      Value<int> difficultyIndex,
      Value<int> timeSeconds,
      Value<int> mistakes,
      Value<int> hints,
      Value<bool> isDaily,
      Value<String> date,
    });

class $$GameResultsTableFilterComposer
    extends Composer<_$AppDatabase, $GameResultsTable> {
  $$GameResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hints => $composableBuilder(
    column: $table.hints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameResultsTable> {
  $$GameResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hints => $composableBuilder(
    column: $table.hints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDaily => $composableBuilder(
    column: $table.isDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameResultsTable> {
  $$GameResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get difficultyIndex => $composableBuilder(
    column: $table.difficultyIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mistakes =>
      $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<int> get hints =>
      $composableBuilder(column: $table.hints, builder: (column) => column);

  GeneratedColumn<bool> get isDaily =>
      $composableBuilder(column: $table.isDaily, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$GameResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameResultsTable,
          GameResultRow,
          $$GameResultsTableFilterComposer,
          $$GameResultsTableOrderingComposer,
          $$GameResultsTableAnnotationComposer,
          $$GameResultsTableCreateCompanionBuilder,
          $$GameResultsTableUpdateCompanionBuilder,
          (
            GameResultRow,
            BaseReferences<_$AppDatabase, $GameResultsTable, GameResultRow>,
          ),
          GameResultRow,
          PrefetchHooks Function()
        > {
  $$GameResultsTableTableManager(_$AppDatabase db, $GameResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> difficultyIndex = const Value.absent(),
                Value<int> timeSeconds = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<int> hints = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                Value<String> date = const Value.absent(),
              }) => GameResultsCompanion(
                id: id,
                difficultyIndex: difficultyIndex,
                timeSeconds: timeSeconds,
                mistakes: mistakes,
                hints: hints,
                isDaily: isDaily,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int difficultyIndex,
                required int timeSeconds,
                required int mistakes,
                Value<int> hints = const Value.absent(),
                Value<bool> isDaily = const Value.absent(),
                required String date,
              }) => GameResultsCompanion.insert(
                id: id,
                difficultyIndex: difficultyIndex,
                timeSeconds: timeSeconds,
                mistakes: mistakes,
                hints: hints,
                isDaily: isDaily,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameResultsTable,
      GameResultRow,
      $$GameResultsTableFilterComposer,
      $$GameResultsTableOrderingComposer,
      $$GameResultsTableAnnotationComposer,
      $$GameResultsTableCreateCompanionBuilder,
      $$GameResultsTableUpdateCompanionBuilder,
      (
        GameResultRow,
        BaseReferences<_$AppDatabase, $GameResultsTable, GameResultRow>,
      ),
      GameResultRow,
      PrefetchHooks Function()
    >;
typedef $$LessonProgressTableCreateCompanionBuilder =
    LessonProgressCompanion Function({
      required String nodeId,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$LessonProgressTableUpdateCompanionBuilder =
    LessonProgressCompanion Function({
      Value<String> nodeId,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$LessonProgressTableFilterComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LessonProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LessonProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$LessonProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressRow,
          $$LessonProgressTableFilterComposer,
          $$LessonProgressTableOrderingComposer,
          $$LessonProgressTableAnnotationComposer,
          $$LessonProgressTableCreateCompanionBuilder,
          $$LessonProgressTableUpdateCompanionBuilder,
          (
            LessonProgressRow,
            BaseReferences<
              _$AppDatabase,
              $LessonProgressTable,
              LessonProgressRow
            >,
          ),
          LessonProgressRow,
          PrefetchHooks Function()
        > {
  $$LessonProgressTableTableManager(
    _$AppDatabase db,
    $LessonProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> nodeId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion(
                nodeId: nodeId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nodeId,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion.insert(
                nodeId: nodeId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressTable,
      LessonProgressRow,
      $$LessonProgressTableFilterComposer,
      $$LessonProgressTableOrderingComposer,
      $$LessonProgressTableAnnotationComposer,
      $$LessonProgressTableCreateCompanionBuilder,
      $$LessonProgressTableUpdateCompanionBuilder,
      (
        LessonProgressRow,
        BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressRow>,
      ),
      LessonProgressRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KeyValueEntriesTableTableManager get keyValueEntries =>
      $$KeyValueEntriesTableTableManager(_db, _db.keyValueEntries);
  $$GameSavesTableTableManager get gameSaves =>
      $$GameSavesTableTableManager(_db, _db.gameSaves);
  $$DailyCompletionsTableTableManager get dailyCompletions =>
      $$DailyCompletionsTableTableManager(_db, _db.dailyCompletions);
  $$GameResultsTableTableManager get gameResults =>
      $$GameResultsTableTableManager(_db, _db.gameResults);
  $$LessonProgressTableTableManager get lessonProgress =>
      $$LessonProgressTableTableManager(_db, _db.lessonProgress);
}
