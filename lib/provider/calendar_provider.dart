import 'package:exercise_log/model/enum/memo_type.dart';
import 'package:exercise_log/model/memo_model.dart';

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

  List<Map<MemoType, MemoModel>> dropdownList = [];

  Future<void> getMemoHistory() async {
    var memoList =
        await MemoDao(GetIt.I<DbHelper>()).findMonthByWriteTime(DateTime.now());
    for (var memo in memoList) {
      _memo.update(memo.writeTime, (value) => memo, ifAbsent: () => memo);
    }
    reloadDropdownList(memoType, DateTime.now());
  }

  Future<void> addMemo(DateTime selectedDay, String memoText) async {
    if (memoType == MemoType.all) {
      memoType = MemoType.exercise;
    }
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
    // 현재 로그인 되어있는 유저 정보 가져오는 코드
    final user = FirebaseAuth.instance.currentUser;
    // Firesotre Databse에 있는 user 컬렉션에서 데이터 가져오는 코드
    final userData = await FirebaseFirestore.instance
      .collection('user')
      .doc(user!.uid)
      .get();
    // Create Update 코드 예시
    // .set 으로 넣으면 데이터가 있을시 덮어쓰고 없을시 생성함
    // 그래서 따로 수정 기능 넣을필요 X
    // .add 로 하면 생성만 가능
    FirebaseFirestore.instance
      .collection('calendar/${user.uid}/${memoType.name}')
      .doc('${selectedDay}')
      .set({
        'selectedDay': selectedDay,
        'userID': user.uid,
        'writeTime': selectedDay,
        'memo': memoText,
        'userName': userData.data()!['userName'],
        'modifyTime': DateTime.now(),
        'memoType': memoType.name,
    });
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

  Future<void> updateMemo(DateTime selectedDay, String memoText) async {
    for (var i in dropdownList) {
      if (i.entries.first.value.check) {
        await MemoDao(GetIt.I<DbHelper>()).updateMemo(
          i.entries.first.value.writeTime,
          i.entries.first.value.memo,
        );
      }
    }
    reloadDropdownList(memoType, selectedDay);
  }

  Future<void> deleteMemo(DateTime selectedDay) async {
    // bool allCheck = true;
    // for (var i in dropdownList) {
    //   if (i.entries.first.value.check) {
    //     await MemoDao(GetIt.I<DbHelper>())
    //         .deleteByWriteTime(i.entries.first.value.writeTime, memoType);
    //   } else {
    //     allCheck = false;
    //   }
    // }
    // if (allCheck) {
    //   _memo.removeWhere((key, value) => isEqualsDay(selectedDay, key));
    // }
    
    // memoType 버튼 클릭시 memoType 변수 받아와서
    // 그 변수에 맞게 doc('data') 에 있는 데이터 삭제하는 코드
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
      .collection('user')
      .doc(user!.uid)
      .get();
    FirebaseFirestore.instance
      .collection('calendar/${user.uid}/${memoType.name}')
      .doc('${selectedDay}')
      .delete();

    reloadDropdownList(memoType, selectedDay);
    notifyListeners();
  }

  Future<void> finishTodayExercise() async {
    var today = DateTime.now();
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

    // var memo = await MemoDao(GetIt.I<DbHelper>())
    //     .findDayMemoByWriteTime(dateTime, memoType);
    // if (memo.isEmpty) {
    //   dropdownList.clear();
    // } else {
    //   dropdownList.clear();
    //   for (var i in memo) {
    //     dropdownList.add({
    //       memoTypeMapper(i?.memoType ?? ""): MemoModel(
    //         memoType: memoTypeMapper(i?.memoType ?? ""),
    //         memo: i?.memo ?? "",
    //         writeTime: i?.writeTime ?? DateTime.now(),
    //       )
    //     });
    //   }
    // }

    // Firestore Database에 저장되어있는 데이터 Read 하는 코드 예시
    // 밑에 where를 통해 writeTime 으로 true 데이터 가져옴
    // 문제점. 원래는 통으로 들어있는 데이터를 긁어와 true인 데이터들을
    //        for문을 돌렸는데 지금은 데이터가 하나하나씩 저장되어있음
    //        all을 구현하려면 컬렉션을 그룹으로 싹 가져와서 표현해야됨
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
      .collection('user')
      .doc(user!.uid)
      .get();
    var snapshot = await FirebaseFirestore.instance
      .collection('calendar/${user.uid}/${memoType.name}')
      .where('writeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0)))
      .where('writeTime', isLessThanOrEqualTo: Timestamp.fromDate(DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59)))
      .get();

    if (snapshot.docs.isEmpty) {
      dropdownList.clear();
    } else {
      dropdownList.clear();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        dropdownList.add({
          memoTypeMapper(data['memoType'] ?? ""): MemoModel(
            memoType: memoTypeMapper(data['memoType'] ?? ""),
            memo: data['memo'] ?? "",
            writeTime: (data['writeTime'] as Timestamp).toDate() ?? DateTime.now(),
          )
        });
      }
    }
    notifyListeners();
  }

  Future<void> resetMemoType() async {
    memoType = MemoType.all;
    notifyListeners();
  }

  Future<void> dropdownListCheck(int index) async {
    dropdownList[index].entries.first.value.check =
        !dropdownList[index].entries.first.value.check;
    notifyListeners();
  }
}
