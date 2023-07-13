
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' as drift;
import '../table/db_helper.dart';
import '../table/memo_dao.dart';

class CalendarProvider with ChangeNotifier {
  Map<DateTime, MemoData> _memo = {};

  Map<DateTime, MemoData> get getMonthMemo => _memo;

  void setMonthMemo(Map<DateTime, MemoData> value) {
    _memo = value;
  }

  List<DateTime> get memoHistory => _memo.keys.toList();

  Future<void> getMemoHistory() async {
    var memoList =
        await MemoDao(GetIt.I<DbHelper>()).findMonthByWriteTime(DateTime.now());
    for (var memo in memoList) {
      _memo.update(memo.writeTime, (value) => memo, ifAbsent: () => memo);
    }
    notifyListeners();
  }

  Future<void> addMemo(DateTime selectedDay, String memoText) async {
    await MemoDao(GetIt.I<DbHelper>())
        .deleteByWriteTime(selectedDay ?? DateTime.now());
    var memoCompanion = MemoCompanion(
      writeTime: drift.Value(selectedDay ?? DateTime.now()),
      memo: drift.Value(memoText),
      modifyTime: drift.Value(DateTime.now()),
    );
    
    await MemoDao(GetIt.I<DbHelper>()).createMemo(
      memoCompanion,
    );
    _memo.addAll({
      selectedDay: MemoData(
          id: -1,
          writeTime: selectedDay,
          memo: memoText,
          modifyTime: DateTime.now())
    });
    notifyListeners();
  }
}
