import 'package:exercise_log/model/enum/memo_type.dart';

class MemoModel {
  MemoModel({
    required this.memoType,
    required this.memo,
    this.check = false,
    required this.writeTime,
  });
  MemoType memoType;
  String memo;
  bool check;
  DateTime writeTime;
}
