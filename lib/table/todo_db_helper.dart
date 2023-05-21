// import 'dart:io';

// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:exercise_log/table/todos.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// part 'todo_db_helper.g.dart';

// @DriftDatabase(
//   tables: [Todos],
// )
// class TodoDbHelper extends _$TodoDbHelper {
//   TodoDbHelper() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;
// }

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     // path_provider 를 통해 앱의 저장위치 얻음
//     final dbFolder = await getApplicationDocumentsDirectory();

//     // 해당 경로에 파일 생성
//     final file = File(p.join(dbFolder.path, 'db.sqlite'));
//     return NativeDatabase(file);
//   });
// }
