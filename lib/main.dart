import 'dart:html';
import 'dart:math';
import 'package:exercise_log/provider/api_provider.dart';
import 'package:exercise_log/notifier/example_model.dart';
import 'package:exercise_log/provider/calendar_provider.dart';
import 'package:exercise_log/provider/bmi_provider.dart';
import 'package:exercise_log/provider/calorie_provider.dart';
import 'package:exercise_log/screens/home_screen.dart';
import 'package:exercise_log/table/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  if (data?.host == 'titleclicked') {
    print('widget click');

    var test = context
        .read<CalendarProvider>()
        .addMemo(_selectedDay ?? DateTime.now(), _memoController.text);
  }
}

void main() {
  final database = DbHelper();
  GetIt.I.registerSingleton<DbHelper>(database);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => ExampleModel(),
    child: const MyApp(),
  ));
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
