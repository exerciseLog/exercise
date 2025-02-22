import 'package:drift/drift.dart';
import 'package:exercise_log/model/enum/memo_type.dart';
import 'package:exercise_log/table/db_helper.dart';
import 'package:exercise_log/table/memo.dart';
import 'package:intl/intl.dart';

part 'memo_dao.g.dart';

@DriftAccessor(tables: [Memo])
class MemoDao extends DatabaseAccessor<DbHelper> with _$MemoDaoMixin {
  MemoDao(DbHelper db) : super(db);

  Future<MemoData> findById(int id) async {
    return (select(memo)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<MemoData?> findFirstMemoByWriteTime(DateTime writeTime) async {
    var startYear = DateFormat('yyyy').format(writeTime);
    var startMonth = DateFormat('MM').format(writeTime);
    var startDay = DateFormat('dd').format(writeTime);
    return (select(memo)
          ..where((t) => t.writeTime.isBetweenValues((writeTime),
              (DateTime.parse('$startYear-$startMonth-$startDay 23:59:59'))))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<MemoData?>> findDayMemoByWriteTime(
      DateTime writeTime, MemoType memoType) async {
    var startYear = DateFormat('yyyy').format(writeTime);
    var startMonth = DateFormat('MM').format(writeTime);
    var startDay = DateFormat('dd').format(writeTime);
    var result = (select(memo)
      ..where((t) => t.writeTime.isBetweenValues(
          (DateTime.parse('$startYear-$startMonth-$startDay 00:00:00')),
          (DateTime.parse('$startYear-$startMonth-$startDay 23:59:59')))));
    if (memoType != MemoType.all) {
      result.where((tbl) => tbl.memoType.equals(memoType.name));
    }
    return result.get();
  }

  Future<int> deleteByWriteTime(DateTime writeTime, MemoType memoType) async {
    var result = (delete(memo)..where((t) => t.writeTime.equals((writeTime))));
    if (memoType != MemoType.all) {
      result.where((tbl) => tbl.memoType.equals(memoType.name));
    }
    return await result.go();
  }

  Future<List<MemoData>> findMonthByWriteTime(DateTime writeTime) {
    var startYear = DateFormat('yyyy').format(writeTime);
    var startMonth = DateFormat('MM').format(writeTime);
    Future<List<MemoData>> memoData;
    memoData = (select(memo)
          ..where((t) => t.writeTime.isBetweenValues(
              (DateTime.parse('$startYear-$startMonth-01')),
              (DateTime.parse('$startYear-$startMonth-31')))))
        .get();

    return memoData;
  }

  Future<int> createMemo(MemoCompanion data) async {
    return await into(memo).insert(data);
  }

  Future<int> updateMemo(DateTime writeTime, String data) async {
    return (update(memo)..where((t) => t.writeTime.equals(writeTime)))
        .write(MemoCompanion(memo: Value(data)));
  }

  Future<int> updateModifyTime(int id, DateTime modifyTime) async {
    return (update(memo)..where((t) => t.id.equals(id)))
        .write(MemoCompanion(modifyTime: Value(modifyTime)));
  }

  // Future<int> deleteByWriteTime(DateTime writeTime) {
  //   return (delete(memo)..where((tbl) => tbl.writeTime.equals(writeTime))).go();
  // }

  Future<int> deleteAll() async {
    return delete(memo).go();
  }
}
