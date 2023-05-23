// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_helper.dart';

// ignore_for_file: type=lint
class $MemoTable extends Memo with TableInfo<$MemoTable, MemoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _writeTimeMeta =
      const VerificationMeta('writeTime');
  @override
  late final GeneratedColumn<DateTime> writeTime = GeneratedColumn<DateTime>(
      'write_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modifyTimeMeta =
      const VerificationMeta('modifyTime');
  @override
  late final GeneratedColumn<DateTime> modifyTime = GeneratedColumn<DateTime>(
      'modify_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, memo, writeTime, modifyTime];
  @override
  String get aliasedName => _alias ?? 'memo';
  @override
  String get actualTableName => 'memo';
  @override
  VerificationContext validateIntegrity(Insertable<MemoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    } else if (isInserting) {
      context.missing(_memoMeta);
    }
    if (data.containsKey('write_time')) {
      context.handle(_writeTimeMeta,
          writeTime.isAcceptableOrUnknown(data['write_time']!, _writeTimeMeta));
    } else if (isInserting) {
      context.missing(_writeTimeMeta);
    }
    if (data.containsKey('modify_time')) {
      context.handle(
          _modifyTimeMeta,
          modifyTime.isAcceptableOrUnknown(
              data['modify_time']!, _modifyTimeMeta));
    } else if (isInserting) {
      context.missing(_modifyTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo'])!,
      writeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}write_time'])!,
      modifyTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modify_time'])!,
    );
  }

  @override
  $MemoTable createAlias(String alias) {
    return $MemoTable(attachedDatabase, alias);
  }
}

class MemoData extends DataClass implements Insertable<MemoData> {
  final int id;
  final String memo;
  final DateTime writeTime;
  final DateTime modifyTime;
  const MemoData(
      {required this.id,
      required this.memo,
      required this.writeTime,
      required this.modifyTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['memo'] = Variable<String>(memo);
    map['write_time'] = Variable<DateTime>(writeTime);
    map['modify_time'] = Variable<DateTime>(modifyTime);
    return map;
  }

  MemoCompanion toCompanion(bool nullToAbsent) {
    return MemoCompanion(
      id: Value(id),
      memo: Value(memo),
      writeTime: Value(writeTime),
      modifyTime: Value(modifyTime),
    );
  }

  factory MemoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoData(
      id: serializer.fromJson<int>(json['id']),
      memo: serializer.fromJson<String>(json['memo']),
      writeTime: serializer.fromJson<DateTime>(json['writeTime']),
      modifyTime: serializer.fromJson<DateTime>(json['modifyTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memo': serializer.toJson<String>(memo),
      'writeTime': serializer.toJson<DateTime>(writeTime),
      'modifyTime': serializer.toJson<DateTime>(modifyTime),
    };
  }

  MemoData copyWith(
          {int? id, String? memo, DateTime? writeTime, DateTime? modifyTime}) =>
      MemoData(
        id: id ?? this.id,
        memo: memo ?? this.memo,
        writeTime: writeTime ?? this.writeTime,
        modifyTime: modifyTime ?? this.modifyTime,
      );
  @override
  String toString() {
    return (StringBuffer('MemoData(')
          ..write('id: $id, ')
          ..write('memo: $memo, ')
          ..write('writeTime: $writeTime, ')
          ..write('modifyTime: $modifyTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memo, writeTime, modifyTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoData &&
          other.id == this.id &&
          other.memo == this.memo &&
          other.writeTime == this.writeTime &&
          other.modifyTime == this.modifyTime);
}

class MemoCompanion extends UpdateCompanion<MemoData> {
  final Value<int> id;
  final Value<String> memo;
  final Value<DateTime> writeTime;
  final Value<DateTime> modifyTime;
  const MemoCompanion({
    this.id = const Value.absent(),
    this.memo = const Value.absent(),
    this.writeTime = const Value.absent(),
    this.modifyTime = const Value.absent(),
  });
  MemoCompanion.insert({
    this.id = const Value.absent(),
    required String memo,
    required DateTime writeTime,
    required DateTime modifyTime,
  })  : memo = Value(memo),
        writeTime = Value(writeTime),
        modifyTime = Value(modifyTime);
  static Insertable<MemoData> custom({
    Expression<int>? id,
    Expression<String>? memo,
    Expression<DateTime>? writeTime,
    Expression<DateTime>? modifyTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memo != null) 'memo': memo,
      if (writeTime != null) 'write_time': writeTime,
      if (modifyTime != null) 'modify_time': modifyTime,
    });
  }

  MemoCompanion copyWith(
      {Value<int>? id,
      Value<String>? memo,
      Value<DateTime>? writeTime,
      Value<DateTime>? modifyTime}) {
    return MemoCompanion(
      id: id ?? this.id,
      memo: memo ?? this.memo,
      writeTime: writeTime ?? this.writeTime,
      modifyTime: modifyTime ?? this.modifyTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (writeTime.present) {
      map['write_time'] = Variable<DateTime>(writeTime.value);
    }
    if (modifyTime.present) {
      map['modify_time'] = Variable<DateTime>(modifyTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoCompanion(')
          ..write('id: $id, ')
          ..write('memo: $memo, ')
          ..write('writeTime: $writeTime, ')
          ..write('modifyTime: $modifyTime')
          ..write(')'))
        .toString();
  }
}

abstract class _$DbHelper extends GeneratedDatabase {
  _$DbHelper(QueryExecutor e) : super(e);
  late final $MemoTable memo = $MemoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [memo];
}
