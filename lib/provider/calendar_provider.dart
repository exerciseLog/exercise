import 'package:flutter/material.dart';

import '../table/db_helper.dart';

class CalendarProvider with ChangeNotifier {
  Map<DateTime, MemoData> _monthMemo = {};

  Map<DateTime, MemoData> get getMonthMemo => _monthMemo;

  void setMonthMemo(Map<DateTime, MemoData> value) {
    _monthMemo = value;
  }

  List<DateTime> get memoHistory => _monthMemo.keys.toList();
}
