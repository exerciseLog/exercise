import 'package:exercise_log/screens/utils.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarMemo extends StatefulWidget {
  const CalendarMemo({super.key});

  @override
  State<CalendarMemo> createState() => _CalendarMemoState();
}

class _CalendarMemoState extends State<CalendarMemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar(
          focusedDay: kToday, firstDay: kFirstDay, lastDay: kLastDay),
    );
  }
}
