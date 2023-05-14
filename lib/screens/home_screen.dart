import 'package:exercise_log/screens/calendar_memo.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("ExerciseLog")),
        body: Center(
          child: Column(children: [
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalendarMemo())),
                child: const Text("달력"))
          ]),
        ));
  }
}
