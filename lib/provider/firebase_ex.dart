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

class FirebaseEx with ChangeNotifier {
  final Map<DateTime, MemoData> _memo = {};
  MemoType memoType = MemoType.exercise;

  Map<DateTime, MemoData> get getMonthMemo => _memo;

  List<DateTime> get memoHistory => _memo.keys.toList();

  List<Map<MemoType, MemoModel>> dropdownList = [];

  Future<void> addMemo(DateTime selectedDay, String memoText) async {
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
  }

  Future<void> deleteMemo(DateTime selectedDay) async {
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

  Future<void> reloadDropdownList(MemoType Type, DateTime dateTime) async {
    memoType = Type;

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
        .where('writeTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0)))
        .where('writeTime',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime(
                dateTime.year, dateTime.month, dateTime.day, 23, 59, 59)))
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
            writeTime:
                (data['writeTime'] as Timestamp).toDate() ?? DateTime.now(),
          )
        });
      }
    }
    notifyListeners();
  }
}
