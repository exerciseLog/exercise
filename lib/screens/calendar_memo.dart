import 'package:exercise_log/provider/calendar_provider.dart';
import 'package:exercise_log/screens/utils.dart';
import 'package:exercise_log/table/db_helper.dart';
import 'package:exercise_log/table/memo_dao.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarMemo extends StatefulWidget {
  const CalendarMemo({super.key});

  @override
  State<CalendarMemo> createState() => _CalendarMemoState();
}

class _CalendarMemoState extends State<CalendarMemo> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  FocusNode memoTextFocus = FocusNode();
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().getMemoHistory();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          TableCalendar(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: (day) {
              return isExerciseDay(day) ? [1] : [];
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
                // Use `CalendarStyle` to customize the UI
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: Color(0xffF67098),
                  shape: BoxShape.circle,
                )),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            focusNode: memoTextFocus,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '오늘의 운동',
            ),
            maxLines: 10,
            controller: _memoController,
          ),
          OutlinedButton(
            onPressed: () => _memoSaved(context),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  bool isExerciseDay(DateTime day) {
    //todo :: 전부 검사 하는 로직 수정 필요
    var isExercise = false;
    context.read<CalendarProvider>().memoHistory.forEach((element) {
      if (isEqualsDay(element, day)) {
        isExercise = true;
      }
    });
    return isExercise;
  }

  void _memoSaved(BuildContext context) {
    context
        .read<CalendarProvider>()
        .addMemo(_selectedDay ?? DateTime.now(), _memoController.text);
    Fluttertoast.showToast(msg: '메모가 저장되었습니다.');
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  // Future<void> getMonthMemo(BuildContext context) async {
  //   var memoList =
  //       await MemoDao(GetIt.I<DbHelper>()).findMonthByWriteTime(DateTime.now());
  //   monthMemo = {for (var memo in memoList) memo.writeTime: memo};
  //   Provider.of<CalendarProvider>(context, listen: false)
  //       .setMonthMemo(monthMemo);
  // }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        memoTextFocus.unfocus();
      });
      var memo =
          await MemoDao(GetIt.I<DbHelper>()).findByWriteTime(selectedDay);
      if (memo == null) {
        setState(() {
          _memoController.text = '';
        });
        Fluttertoast.showToast(msg: '해당 날짜에 저장된 기록이 없습니다.');
      } else {
        setState(() {
          _memoController.text = memo.memo;
        });
      }

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }
}
