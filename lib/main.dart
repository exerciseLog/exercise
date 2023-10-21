import 'package:exercise_log/model/enum/memo_type.dart';
import 'dart:developer';
import 'package:exercise_log/provider/api_provider.dart';
import 'package:exercise_log/provider/calendar_provider.dart';
import 'package:exercise_log/provider/bmi_provider.dart';
import 'package:exercise_log/provider/calorie_provider.dart';
import 'package:exercise_log/provider/position_provider.dart';
import 'package:exercise_log/screens/home_screen.dart';
import 'package:exercise_log/table/db_helper.dart';
import 'package:exercise_log/table/memo_dao.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  initializeDateFormatting().then((_) => runApp(const MyApp()));
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
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          log('User is currently signed out!');
        } else {
          log('User is signed in!');
        }
      });
    });
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
        ChangeNotifierProvider<PositionProvider>(
          create: (BuildContext context) => PositionProvider(),
        ),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}
