import 'package:drift/drift.dart';
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

  Future<MemoData> findByWriteTime(DateTime writeTime) async {
    return (select(memo)..where((t) => t.writeTime.equals(writeTime)))
        .getSingle();
  }

  Future<MemoData?> findMonthByWriteTime(DateTime writeTime) {
    var startYear = DateFormat('yyyy').format(writeTime);
    var startMonth = DateFormat('MM').format(writeTime);
    var startDay = DateFormat('dd').format(writeTime);
    Future<MemoData?> memoData;
      memoData =  (select(memo)
        ..where((t) => t.writeTime.equals(
            (DateTime.parse('$startYear-$startMonth-$startDay'))))..limit(1))
          .getSingleOrNull();

    return memoData;
  }

  Future<int> createMemo(MemoCompanion data,DateTime writeTime) async {
    deleteByWriteTime(writeTime);
    return into(memo).insert(data);
  }

  Future<int> updateModifyTime(int id, DateTime modifyTime) async {
    return (update(memo)..where((t) => t.id.equals(id)))
        .write(MemoCompanion(modifyTime: Value(modifyTime)));
  }

  Future<int> deleteByWriteTime(DateTime writeTime) {
    return (delete(memo)..where((tbl) => tbl.writeTime.equals(writeTime))).go();
  }

  Future<int> deleteAll() async {
    return delete(memo).go();
  }
}
