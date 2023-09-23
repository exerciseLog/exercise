import 'package:exercise_log/model/enum/memo_type.dart';
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

  List<String> dropdownList = ['데드리프트', '벤치프레스', '스쿼트'];
  String selectedDropdown = '데드리프트';

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
          TableCalendar(
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            availableCalendarFormats: {CalendarFormat.month: 'Month'},
            locale: 'ko_KR',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              memoTypeButton(MemoType.all.buttonValue),
              memoTypeButton(MemoType.ateFood.buttonValue),
              memoTypeButton(MemoType.walk.buttonValue),
              memoTypeButton(MemoType.exercise.buttonValue),
            ],
          ),
          TextField(
            focusNode: memoTextFocus,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '오늘의 운동',
            ),
            maxLines: 3,
            controller: _memoController,
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(itemBuilder: (context, index) {
              const ExpansionTile(
                title: Text("타이틀"),
                children: [Text("하위")],
              );
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => _memoSaved(context),
                child: const Text('저장'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: OutlinedButton(
                  onPressed: () => _memoDelete(context),
                  child: const Text('삭제',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget memoTypeButton(String value) {
    return OutlinedButton(onPressed: () {}, child: Text(value));
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

  void _memoDelete(BuildContext context) {
    context.read<CalendarProvider>().deleteMemo(_selectedDay ?? DateTime.now());
    Fluttertoast.showToast(msg: '메모가 삭제되었습니다.');
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
