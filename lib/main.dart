import 'package:exercise_log/model/enum/memo_type.dart';
import 'package:exercise_log/provider/api_provider.dart';
import 'package:exercise_log/notifier/example_model.dart';
import 'package:exercise_log/provider/calendar_provider.dart';
import 'package:exercise_log/provider/bmi_provider.dart';
import 'package:exercise_log/provider/calorie_provider.dart';
import 'package:exercise_log/screens/home_screen.dart';
import 'package:exercise_log/table/db_helper.dart';
import 'package:exercise_log/table/memo_dao.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  if (data?.host == 'titleclicked') {
    var memoCompanion = MemoCompanion(
        writeTime: drift.Value(DateTime.now()),
        memo: const drift.Value(''),
        modifyTime: drift.Value(DateTime.now()),
        memoType: drift.Value(MemoType.exercise.name));
    final database = DbHelper();
    await MemoDao(database).createMemo(
      memoCompanion,
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    final database = DbHelper();
    GetIt.I.registerSingleton<DbHelper>(database);
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiProvider>(
          create: (BuildContext context) => ApiProvider(),
        ),
        ChangeNotifierProvider<CalorieProvider>(
          create: (BuildContext context) => CalorieProvider(),
        ),
        ChangeNotifierProvider<CalendarProvider>(
          create: (BuildContext context) => CalendarProvider(),
        ),
        ChangeNotifierProvider<BmiProvider>(
          create: (BuildContext context) => BmiProvider(),
        ),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}
