import 'package:exercise_log/provider/api_provider.dart';
import 'package:exercise_log/notifier/example_model.dart';
import 'package:exercise_log/screens/home_screen.dart';
import 'package:exercise_log/table/db_helper.dart';
import 'package:exercise_log/table/memo_dao.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

void main() {
  final database = DbHelper();
  GetIt.I.registerSingleton<DbHelper>(database);
  runApp(ChangeNotifierProvider(
    create: (_) => ExampleModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<int>.value(value: 50),
        ChangeNotifierProvider<ApiProvider>(
          create: (BuildContext context) => ApiProvider(),
        )
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}
