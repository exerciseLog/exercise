import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
}
