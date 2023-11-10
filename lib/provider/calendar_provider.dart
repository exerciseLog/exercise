import 'package:exercise_log/model/enum/memo_type.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' as drift;
import '../screens/utils.dart';
import '../table/db_helper.dart';
import '../table/memo_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarProvider with ChangeNotifier {
  final Map<DateTime, MemoData> _memo = {};
  
  MemoType memoType = MemoType.exercise;

  Map<DateTime, MemoData> get getMonthMemo => _memo;

  List<DateTime> get memoHistory => _memo.keys.toList();

  Map<MemoType, String> dropdownList = {};
  
  Future<void> addMemo(DateTime selectedDay, String memoText) async {
    if (memoType == MemoType.all) {
      memoType = MemoType.exercise;
    }
    final strSelectedDay = selectedDay.toString();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
      .collection('user')
      .doc(user!.uid)
      .get();
    FirebaseFirestore.instance
      .collection('calendar/${user.uid}/${memoType.name}')
      .doc('data')
      .set({
        'text': memoText,
        'userID': user.uid,
        'userName': userData.data()!['userName'],
        'selectedDay': selectedDay,
        'memoType': memoType.name,
    });
    notifyListeners();
  }

  Future<void> getMemoHistory() async {
    var memoList =
        await MemoDao(GetIt.I<DbHelper>()).findMonthByWriteTime(DateTime.now());
    for (var memo in memoList) {
      _memo.update(memo.writeTime, (value) => memo, ifAbsent: () => memo);
    }
    notifyListeners();
  }

  // Future<void> addMemo(DateTime selectedDay, String memoText) async {
  //   if (memoType == MemoType.all) {
  //     memoType = MemoType.exercise;
  //   }
  //   await MemoDao(GetIt.I<DbHelper>()).deleteByWriteTime(selectedDay, memoType);
  //   var memoCompanion = MemoCompanion(
  //     writeTime: drift.Value(selectedDay),
  //     memo: drift.Value(memoText),
  //     modifyTime: drift.Value(DateTime.now()),
  //     memoType: drift.Value(memoType.name),
  //   );

  //   await MemoDao(GetIt.I<DbHelper>()).createMemo(
  //     memoCompanion,
  //   );
  //   _memo.addAll({
  //     selectedDay: MemoData(
  //         id: -1,
  //         writeTime: selectedDay,
  //         memo: memoText,
  //         modifyTime: DateTime.now(),
  //         memoType: memoType.name)
  //   });
  //   notifyListeners();
  // }

  Future<void> deleteMemo(DateTime selectedDay) async {
   if (memoType == MemoType.all) {
      memoType = MemoType.exercise;
    }
    final strSelectedDay = selectedDay.toString();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
      .collection('user')
      .doc(user!.uid)
      .get();
    FirebaseFirestore.instance
      .collection('calendar/${user.uid}/${memoType.name}')
      .doc('data')
      .delete();
    notifyListeners();
  }

  Future<void> finishTodayExercise() async {
    var today = DateTime.now();
    await MemoDao(GetIt.I<DbHelper>()).deleteByWriteTime(today, memoType);
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
}
