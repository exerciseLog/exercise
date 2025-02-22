import 'dart:developer';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:exercise_log/provider/api_provider.dart';
import 'package:exercise_log/provider/calorie_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../model/nutrition_model.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../provider/bmi_provider.dart';
import '../provider/calendar_provider.dart';
import 'package:animations/animations.dart';

class NutApiPage extends StatefulWidget {
  const NutApiPage({Key? key}) : super(key: key);

  @override
  State<NutApiPage> createState() => _NutApiPageState();
}

class _NutApiPageState extends State<NutApiPage> {
  static const _pageSize = 10;
  TextEditingController foodCtrl = TextEditingController();
  TextEditingController madeCtrl = TextEditingController();
  final PagingController<int, NutApiModel> _pagingController =
      PagingController(firstPageKey: 0);

  noItemsFoundIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "결과 없음",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text("음식을 검색하세요."),
        ],
      ),
    );
  }

  noItemsIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("추가한 음식이 없습니다."),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      _pagingController.addPageRequestListener((pageKey) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          var apiItems =
              Provider.of<ApiProvider>(context, listen: false).inList;
          if (apiItems.isEmpty) {
            _pagingController.appendLastPage(<NutApiModel>[]);
            return;
          }
          log(pageKey.toString());
          /* var nextPageKey = pageKey + _pageSize; */
          final isLastPage = apiItems.length <= pageKey + _pageSize;
          final nextPageKey =
              isLastPage ? apiItems.length : pageKey + _pageSize;
          final appendPage = apiItems.sublist(pageKey, nextPageKey);
          if (isLastPage) {
            _pagingController.appendLastPage(appendPage);
          } else {
            _pagingController.appendPage(appendPage, nextPageKey);
          }
        });
      });
    } catch (e) {
      _pagingController.error = e;
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var api = Provider.of<ApiProvider>(context);
    var cal = Provider.of<CalorieProvider>(context);
    var bmi = Provider.of<BmiProvider>(context);
    var selectedCal = cal.selectedCal;
    var numCal = cal.getCalorie;
    var stdCal = bmi.getStandardCalorie();
    var percent = cal.percent;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    flex: 3,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: foodCtrl,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.menu_book),
                              hintText: '음식명(필수)',
                              iconColor: Color.fromARGB(200, 20, 20, 255)),
                        ),
                        TextFormField(
                          controller: madeCtrl,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.store),
                              hintText: '제조사명',
                              iconColor: Color.fromARGB(200, 20, 20, 255)),
                        )
                      ],
                    )),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () async {
                        api.modifyBool();
                        String foodName = foodCtrl.text;
                        String madeName = madeCtrl.text;
                        if (foodName == '') {
                          ElegantNotification.error(
                                  title: const Text("오류"),
                                  description: const Text("검색할 음식을 입력해 주세요."))
                              .show(context);
                          api.modifyBool();
                          return;
                        }

                        try {
                          List<NutApiModel> resultList =
                              await ApiService.getNutrition(foodName, madeName);
                          api.setResult(resultList);
                          _pagingController.refresh();

                          cal.resetList();
                        } catch (err) {
                          _pagingController.error = err;
                          ElegantNotification.error(
                                  title: const Text("오류"),
                                  description: Text('$err'))
                              .show(context);
                        } finally {
                          api.modifyBool();
                        }
                      },
                      child: const Text('검색하기')),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: api.inProgress,
              child: const CircularProgressIndicator(),
            ),
            Container(
              alignment: Alignment.topLeft,
              height: 300,
              child: Scrollbar(
                thickness: 8,
                radius: const Radius.circular(12),
                child: PagedListView<int, NutApiModel>.separated(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<NutApiModel>(
                      itemBuilder: (context, item, index) {
                        return ApiListItem(
                            index: index,
                            name: item.name,
                            maker: item.maker,
                            kcal: item.kcal,
                            size: item.size,
                            carb: item.carb,
                            protien: item.protien,
                            fat: item.fat,
                            sugar: item.sugar,
                            sodium: item.sodium,
                            col: item.col);
                      },
                      noItemsFoundIndicatorBuilder: (_) =>
                          noItemsFoundIndicator(context),
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 1500)),
                  separatorBuilder: ((context, index) => const Divider()),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: OutlinedButton(
                    onPressed: () {
                      if (selectedCal == '') {
                        ElegantNotification.error(
                                title: const Text("오류"),
                                description: const Text('선택된 음식이 없습니다.'))
                            .show(context);
                      } else {
                        cal.addCalorie(cal.selectedFood, selectedCal, stdCal);
                        ElegantNotification.success(
                                title: const Text("성공"),
                                description: Text(
                                    "선택된 음식의 열량 $selectedCal kcal이 추가되었습니다."))
                            .show(context);
                        cal.resetList();
                      }
                    },
                    child: const Text("추가")),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (numCal == "0" || numCal == "0.0") {
                      ElegantNotification.error(
                              title: const Text("실패"),
                              description:
                                  const Text("음식을 검색해 추가한 다음 시도해 주세요."))
                          .show(context);
                    } else {
                      return DatePicker.showDatePicker(context,
                          dateFormat: 'yyyy MMMM dd',
                          initialDateTime: DateTime.now(),
                          minDateTime: DateTime(2000),
                          maxDateTime: DateTime(2100),
                          onMonthChangeStartWithFirstDate: false,
                          locale: DateTimePickerLocale.ko,
                          onConfirm: (dateTime, List<int> index) async {
                        DateTime selDate = DateTime.utc(dateTime.year,
                            dateTime.month, dateTime.day, 00, 00);
                        var res = DateFormat('yyyy-MM-dd').format(selDate);
                        var foodList = cal.selectedFoodList;
                        String memoValue = '';
                        for (var food in foodList) {
                          memoValue += "$food, ";
                        }
                        memoValue += "\n$numCal kcal";
                        context
                            .read<CalendarProvider>()
                            .addMemo(selDate, memoValue);

                        if (context.mounted) {
                          ElegantNotification.success(
                                  title: const Text("성공"),
                                  description: Text("$res에 추가된 칼로리: $numCal"))
                              .show(context);
                          cal.resetCalorie();
                        }
                      });
                    }
                  },
                  child: const Text("달력에 기록")),
            ]),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                    message: '회원님의 현재 적정 열량은 $stdCal kcal 입니다.',
                    child: Text(
                      "총 열량: $numCal kcal($percent%)",
                      style: const TextStyle(
                          fontFamily: 'NaverNanum',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600),
                    )),
                const Tooltip(
                  message:
                      '현재 입력된 음식 리스트의 총 열량과 입력된 신체 정보에 따른 일일 열량 소비량의 예측 값입니다.'
                      '정확한 소비량 계산은 전문가와 상의하세요!',
                  child: Icon(
                    Icons.help_outline_outlined,
                    size: 24,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "먹은 음식",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    height: 100,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(6),
                      itemCount: cal.selectedCalList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _CheckedListItem(
                          index: index,
                          food: cal.selectedFoodList[index],
                          cal: cal.selectedCalList[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                cal.deleteSelectedList();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(200, 0, 0, 15),
              ),
              child: const Text("삭제"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class ApiListItem extends StatelessWidget {
  const ApiListItem(
      {super.key,
      required this.index,
      required this.name,
      required this.maker,
      required this.kcal,
      required this.size,
      required this.carb,
      required this.protien,
      required this.fat,
      required this.sugar,
      required this.sodium,
      required this.col});

  final int index;
  final String name;
  final String maker;
  final String kcal;
  final String size;
  final String carb;
  final String protien;
  final String fat;
  final String sugar;
  final String sodium;
  final String col;

  @override
  Widget build(BuildContext context) {
    var cal = Provider.of<CalorieProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio(
              value: index,
              groupValue: cal.listNum,
              onChanged: kcal == ''
                  ? null
                  : (value) {
                      cal.setCalorie(name, kcal, index);
                    }),
          Expanded(
              child: _Description(
            name: name,
            maker: maker,
            kcal: kcal,
            size: size,
          )),
          IconButton(
            icon: const Icon(Icons.more_vert),
            iconSize: 15,
            onPressed: () async {
              return showModal(
                  context: context,
                  configuration: const FadeScaleTransitionConfiguration(
                      transitionDuration: Duration(milliseconds: 300),
                      reverseTransitionDuration: Duration(milliseconds: 150)),
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("영양 상세"),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "식품명: $name",
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.w600),
                            ),
                            Visibility(
                                visible: maker != '' ? true : false,
                                child: Text("제조사: $maker",
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300))),
                            Text("1회 제공량: $size g",
                                style: const TextStyle(fontSize: 16.0)),
                            _DialogNutDetail(
                                name: "열량", value: kcal, unit: "kcal"),
                            _DialogNutDetail(
                                name: "탄수화물", value: carb, unit: "g"),
                            _DialogNutDetail(
                                name: "단백질", value: protien, unit: "g"),
                            _DialogNutDetail(name: "지방", value: fat, unit: "g"),
                            _DialogNutDetail(
                                name: "당류", value: sugar, unit: "g"),
                            _DialogNutDetail(
                                name: "나트륨", value: sodium, unit: "mg"),
                            _DialogNutDetail(
                                name: "콜레스테롤", value: col, unit: "mg"),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description(
      {required this.name,
      required this.maker,
      required this.kcal,
      required this.size});

  final String name;
  final String maker;
  final String kcal;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
            Text(
              maker,
              style: const TextStyle(fontSize: 9.0),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
            Text(
              '$kcal kcal ($size g)',
              style: const TextStyle(fontSize: 10.0),
            ),
          ],
        ));
  }
}

class _DialogNutDetail extends StatelessWidget {
  const _DialogNutDetail({
    required this.name,
    required this.value,
    required this.unit,
  });

  final String name;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: value != '' ? true : false,
        child: Text("$name: $value $unit",
            style: const TextStyle(fontSize: 14.0)));
  }
}

class _CheckedListItem extends StatelessWidget {
  const _CheckedListItem(
      {required this.index, required this.food, required this.cal});

  final int index;
  final String food;
  final String cal;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CalorieProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Radio(
            value: index,
            groupValue: provider.selListNum,
            onChanged: cal == ''
                ? null
                : (value) {
                    provider.setSelectedList(index);
                    ElegantNotification.info(
                            title: const Text("정보"),
                            description: Text("선택된 음식의 열량: $cal"))
                        .show(context);
                  }),
        Text(
          "$food : $cal kcal",
          style: const TextStyle(fontSize: 15.0),
        ),
      ]),
    );
  }
}
