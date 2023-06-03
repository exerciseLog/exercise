import 'package:elegant_notification/elegant_notification.dart';
import 'package:exercise_log/provider/api_provider.dart';
import 'package:exercise_log/provider/calorie_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../model/nutrition_model.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

class NutApiPage extends StatefulWidget {
  const NutApiPage({Key? key}) : super(key: key);

  @override
  State<NutApiPage> createState() => _NutApiPageState();
}

class _NutApiPageState extends State<NutApiPage> {
  TextEditingController apiCtrl = TextEditingController();
  TextEditingController dlgCtrl = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    var api = Provider.of<ApiProvider>(context);
    var cal = Provider.of<CalorieProvider>(context);
    var selectedCal = cal.selectedCal;
    var numCal = cal.getCalorie;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("EXERCISELOG"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: TextFormField(
                    controller: apiCtrl,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.add_box_outlined),
                      hintText: '검색',
                      iconColor: Color.fromARGB(200, 20, 20, 255)),
                  )
                ),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      onPressed: () async {
                        api.modifyBool();
                        String foodName = apiCtrl.text;
                          if (foodName == '') {
                            ElegantNotification.error(
                                  title: const Text("오류"),
                                  description: const Text("검색할 음식을 입력해 주세요."))
                              .show(context);
                            api.modifyBool();
                            return;
                          }
                                                   
                        try {
                          Future<List<NutApiModel>> resultList =
                            ApiService.getNutrition(foodName);
                          List<NutApiModel> list = await resultList;
                          api.setResult(list);
                          apiCtrl.clear();
                          cal.resetList();
                        }
                        catch(err) {
                          ElegantNotification.error(
                                  title: const Text("오류"),
                                  description: Text('$err'))
                              .show(context);
                        }
                        finally {
                          api.modifyBool();
                        }
                        
                      },
                      child: const Text('검색하기')
                  ),
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
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    height: 300,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(6),
                      itemCount: api.getLength(),
                      itemBuilder: (BuildContext context, int index) {
                        return ApiListItem(
                            index: index,
                            name: api.inList[index].name,
                            maker: api.inList[index].maker,
                            kcal: api.inList[index].kcal,
                            size: api.inList[index].size,
                            carb: api.inList[index].carb,
                            protien: api.inList[index].protien,
                            fat: api.inList[index].fat,
                            sugar: api.inList[index].sugar,
                            sodium: api.inList[index].sodium,
                            col: api.inList[index].col);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: OutlinedButton(
                    onPressed: () {
                      if(selectedCal == '') {
                        ElegantNotification.error(
                              title: const Text("오류"),
                              description: const Text('선택된 음식이 없습니다.'))
                              .show(context);
                      }
                      else {
                        cal.addCalorie(selectedCal);
                        ElegantNotification.success(
                          title: const Text("성공"),
                          description: Text(
                          "선택된 음식의 열량 $selectedCal kcal이 추가되었습니다."))
                        .show(context);
                        cal.resetList();
                      }
                     
                    }, 
                    child: const Text("추가")
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if(numCal == "0" || numCal == "0.0") {
                      ElegantNotification.error(
                      title: const Text("실패"),
                      description: const Text("음식을 검색해 추가한 다음 시도해 주세요."))
                      .show(context);
                    }
                    else {
                      return DatePicker.showDatePicker(
                        context,
                        dateFormat: 'yyyy MMMM dd',
                        initialDateTime: DateTime.now(),
                        minDateTime: DateTime(2000),
                        maxDateTime: DateTime(2100),
                        onMonthChangeStartWithFirstDate: false,
                        locale: DateTimePickerLocale.ko,
                        onConfirm: (dateTime, List<int> index) {
                          DateTime selDate = dateTime;
                          var res = DateFormat('yyyy-MM-dd').format(selDate);
                          ElegantNotification.success(
                            title: const Text("성공"),
                            description: Text("$res에 추가된 칼로리: $numCal"))
                            .show(context);
                          cal.resetCalorie();
                        }
                      );
                     
                    }
                  }, 
                child: const Text("등록")
                ),
              ]
            ),

            Text("현재 입력된 열량: $numCal")
          ],
        ),
      ),
    );
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
              onChanged: kcal == '' ? null : (value) {
                cal.setCalorie(kcal, index);  
                ElegantNotification.info(
                      title: const Text("정보"),
                      description: Text("선택된 음식의 열량: $kcal"))
                  .show(context);
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
              return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("영양 상세"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "식품명: $name",
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Visibility(
                            visible: maker != '' ? true : false,
                            child: Text("제조사: $maker",
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w300
                                )
                            )
                          ),
                          Text("1회 제공량: $size g", 
                            style: const TextStyle(fontSize: 16.0)
                          ),
                          _DialogNutDetail(
                            name: "열량", 
                            value: kcal, 
                            unit: "kcal"
                          ),
                          _DialogNutDetail(
                            name: "탄수화물", 
                            value: carb, 
                            unit: "g"
                          ),
                          _DialogNutDetail(
                            name: "단백질", 
                            value: protien, 
                            unit: "g"
                          ),
                          _DialogNutDetail(
                            name: "지방", 
                            value: fat, 
                            unit: "g"
                          ),
                          _DialogNutDetail(
                            name: "당류", 
                            value: sugar, 
                            unit: "g"
                          ),
                          _DialogNutDetail(
                            name: "나트륨", 
                            value: sodium, 
                            unit: "mg"
                          ),
                          _DialogNutDetail(
                            name: "콜레스테롤", 
                            value: col, 
                            unit: "mg"
                          ),
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
        style: const TextStyle(fontSize: 14.0)
      )
    );
  }


}
