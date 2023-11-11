import 'package:exercise_log/model/enum/memo_type.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' as drift;
import '../screens/utils.dart';
import '../table/db_helper.dart';
import '../table/memo_dao.dart';

class CalendarProvider with ChangeNotifier {
  final Map<DateTime, MemoData> _memo = {};
  MemoType memoType = MemoType.exercise;

  Map<DateTime, MemoData> get getMonthMemo => _memo;

  List<DateTime> get memoHistory => _memo.keys.toList();

  List<Map<MemoType, String>> dropdownList = [];

  Future<void> getMemoHistory() async {
    var memoList =
        await MemoDao(GetIt.I<DbHelper>()).findMonthByWriteTime(DateTime.now());
    for (var memo in memoList) {
      _memo.update(memo.writeTime, (value) => memo, ifAbsent: () => memo);
    }
    notifyListeners();
  }

  Future<void> addMemo(DateTime selectedDay, String memoText) async {
    if (memoType == MemoType.all) {
      memoType = MemoType.exercise;
    }
    // await MemoDao(GetIt.I<DbHelper>()).deleteByWriteTime(selectedDay, memoType);
    DateTime modifyTime = DateTime.now();
    DateTime writeTime = DateTime(selectedDay.year, selectedDay.month,
        selectedDay.day, modifyTime.hour, modifyTime.minute, modifyTime.second);
    var memoCompanion = MemoCompanion(
      writeTime: drift.Value(writeTime),
      memo: drift.Value(memoText),
      modifyTime: drift.Value(modifyTime),
      memoType: drift.Value(memoType.name),
    );

    await MemoDao(GetIt.I<DbHelper>()).createMemo(
      memoCompanion,
    );
    _memo.addAll({
      selectedDay: MemoData(
          id: -1,
          writeTime: selectedDay,
          memo: memoText,
          modifyTime: DateTime.now(),
          memoType: memoType.name)
    });
    notifyListeners();
  }

  Future<void> deleteMemo(DateTime selectedDay) async {
    await MemoDao(GetIt.I<DbHelper>()).deleteByWriteTime(selectedDay, memoType);

    _memo.removeWhere((key, value) => isEqualsDay(selectedDay, key));
    notifyListeners();
  }

  Future<void> finishTodayExercise() async {
    var today = DateTime.now();
    // await MemoDao(GetIt.I<DbHelper>()).deleteByWriteTime(today, memoType);
    var memoCompanion = MemoCompanion(
      writeTime: drift.Value(today),
      memo: const drift.Value(''),
      modifyTime: drift.Value(today),
      memoType: drift.Value(memoType.name),
    );

    await MemoDao(GetIt.I<DbHelper>()).createMemo(
      memoCompanion,
    );
    _memo.addAll({
      today: MemoData(
          id: -1,
          writeTime: today,
          memo: '',
          modifyTime: DateTime.now(),
          memoType: memoType.name)
    });
    notifyListeners();
  }

  Future<void> reloadDropdownList(MemoType Type, DateTime dateTime) async {
    memoType = Type;

    var memo = await MemoDao(GetIt.I<DbHelper>())
        .findDayMemoByWriteTime(dateTime, memoType);
    if (memo.isEmpty) {
      dropdownList.clear();
    } else {
      dropdownList.clear();
      for (var i in memo) {
        dropdownList.add({memoTypeMapper(i?.memoType ?? ""): i?.memo ?? ""});
      }
    }
    notifyListeners();
  }

  Future<void> resetMemoType() async {
    memoType = MemoType.all;
    notifyListeners();
  }
}
