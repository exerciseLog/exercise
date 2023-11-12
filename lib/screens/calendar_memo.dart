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

//todo :: 페이지 최하단에 입력했던 운동 그대로 나오도록하고 옆으로 밀면 삭제 가능,
class _CalendarMemoState extends State<CalendarMemo> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  FocusNode memoTextFocus = FocusNode();
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00);
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                calendarWidget(),
                SizedBox(height: 50, child: memoTypeButtonWidget()),
                SizedBox(height: 100, child: memoInputFiled()),
                memoList(),
              ],
            ),
          ),
        ),
        saveButton(),
      ],
    );
  }

  Widget memoList() {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: provider.dropdownList.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 70,
              child: ExpansionTile(
                  title: Text(provider.dropdownList[index].entries
                      .toList()
                      .first
                      .value
                      .split('\n')
                      .first),
                  children: [
                    memoField(provider.dropdownList[index].entries
                        .toList()
                        .first
                        .value)
                  ]),
            );
          },
        );
      },
    );
  }

  Widget memoTypeButtonWidget() {
    return Consumer<CalendarProvider>(builder: (context, provider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          memoTypeButton(MemoType.all),
          memoTypeButton(MemoType.ateFood),
          memoTypeButton(MemoType.walk),
          memoTypeButton(MemoType.exercise),
        ],
      );
    });
  }

  Widget calendarWidget() {
    return Consumer<CalendarProvider>(builder: (context, provider, child) {
      return TableCalendar(
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
        ),
        headerVisible: true,
        // availableCalendarFormats: const {CalendarFormat.month: 'Month'},
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
      );
    });
  }

  Widget memoTypeButton(MemoType memoType) {
    return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return context.read<CalendarProvider>().memoType != memoType
                ? Colors.white
                : Colors.black26;
          }),
        ),
        onPressed: () async {
          reloadDropdownList(memoType);
        },
        child: Text(memoType.buttonValue));
  }

  Future<void> reloadDropdownList(MemoType memoType) async {
    _memoController.text = '';
    context
        .read<CalendarProvider>()
        .reloadDropdownList(memoType, _selectedDay ?? DateTime.now());
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

  Future<void> _memoSaved(BuildContext context) async {
    await context
        .read<CalendarProvider>()
        .addMemo(_selectedDay ?? DateTime.now(), _memoController.text);
    Fluttertoast.showToast(msg: '메모가 저장되었습니다.');
    await reloadDropdownList(context.read<CalendarProvider>().memoType);
    setState(() {
      _memoController.text = '';
    });
  }

  void _memoDelete(BuildContext context) {
    context.read<CalendarProvider>().deleteMemo(_selectedDay ?? DateTime.now());
    context.read<CalendarProvider>().dropdownList.clear();

    setState(() {
      context.read<CalendarProvider>().dropdownList.clear();
    });
    Fluttertoast.showToast(msg: '메모가 삭제되었습니다.');
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  Widget memoField(String value) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: value,
      ),
      maxLines: 3,
    );
  }

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

      context
          .read<CalendarProvider>()
          .reloadDropdownList(MemoType.all, selectedDay);
      context.read<CalendarProvider>().resetMemoType();
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

  Widget saveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            context.read<CalendarProvider>().memoType != MemoType.all
                ? _memoSaved(context)
                : {};
          },
          child: const Text('저장'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: OutlinedButton(
            onPressed: () => _memoDelete(context),
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }

  Widget memoInputFiled() {
    return TextField(
      focusNode: memoTextFocus,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: _memoController.text.isNotEmpty
            ? '오늘의 ${context.read<CalendarProvider>().memoType.buttonValue}'
            : "기록하기",
      ),
      maxLines: 3,
      controller: _memoController,
    );
  }
}
