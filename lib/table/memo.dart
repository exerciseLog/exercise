import 'package:drift/drift.dart';

class Memo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get memo => text()();
  DateTimeColumn get writeTime => dateTime()();
  DateTimeColumn get modifyTime => dateTime()();
}
