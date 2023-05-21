import 'package:exerciselog/provider/api_provider.dart';
import 'package:exerciselog/screen/nutrition_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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
          home: NutApiPage(),
        ),
    );
  }
}



