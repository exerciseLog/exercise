import 'package:exercise_log/notifier/example_model.dart';
import 'package:exercise_log/screens/nutrition_screen.dart';
import 'package:exercise_log/screens/calendar_memo.dart';
import 'package:exercise_log/screens/walk_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // https://selfish-developer.com/entry/flutter-provider-%ED%8C%A8%ED%84%B4
                Consumer<ExampleModel>(
                  builder: (context, model, child) {
                    return Row(
                      children: [
                        // const SizedBox(
                        //   height: 30,
                        // ),
                        // ElevatedButton(
                        //     onPressed: () =>
                        //         context.read<ExampleModel>().increaseCount(),
                        //     child: const Text("provider")),
                        // const SizedBox(
                        //   width: 30,
                        // ),
                        // Text("count: ${model.counter}"),
                        const SizedBox(
                          height: 30,
                        ),
                        if (child != null) child
                      ],
                    );
                  },
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalendarMemo())),
                child: const Text("달력")),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NutApiPage())),
                child: const Text("칼로리")),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BmiScreen(
                              title: 'BMI',
                            ))),
                child: const Text("만보기")),
          ]),
        ));
  }
}
