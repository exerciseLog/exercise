import 'package:elegant_notification/elegant_notification.dart';
import 'package:exerciselog/provider/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../model/nutrition_model.dart';

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
    var check = Provider.of<int>(context);
    var api = Provider.of<ApiProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("EXERCISELOG"),
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: apiCtrl,
              decoration: const InputDecoration(
                  icon: Icon(Icons.add_box_outlined), hintText: '검색',
                  iconColor: Color.fromARGB(200, 20, 20, 255)
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: ElevatedButton(
                      onPressed: () {
                        String foodName = apiCtrl.text;
                        if(foodName == '') {
                          ElegantNotification.error(
                              title:  const Text("오류"),
                              description:  const Text("검색할 음식을 입력해 주세요.")
                          ).show(context);
                          return;
                        }
                        Future<List<NutApiModel>> resultList = ApiService.getNutrition(foodName);
                        api.setResult(resultList);
                        apiCtrl.clear();
                      },
                      child: const Text('검색하기')
                  ),
                ),
                OutlinedButton(
                    onPressed: () {
                      tDialog(context);
                    },
                    child: const Text("다이얼로그 테스트")
                )
              ],
            ),
            const SizedBox(
              height: 10,
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
                            name: api.inList[index].name,
                            maker: api.inList[index].maker,
                            kcal: api.inList[index].kcal,
                            size: api.inList[index].size
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                    ),

                    /*Text(
                        api.getResult(),
                        style: const TextStyle(height: 1.5, fontSize: 16),
                      ),*/
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future tDialog(BuildContext context) async{
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("입력"),
            content: TextField(
              controller: dlgCtrl,
              decoration: const InputDecoration(hintText: "테스트용"),
            ),
            actions: [
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }
}


class ApiListItem extends StatelessWidget {
  const ApiListItem ({
    super.key,
    required this.name,
    required this.maker,
    required this.kcal,
    required this.size
  });

  final String name;
  final String maker;
  final String kcal;
  final String size;

  @override
  Widget build(BuildContext context) {
    var api = Provider.of<ApiProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio(
              value: kcal,
              groupValue: api.selectedCal,
              onChanged: (value) {
                api.setCalorie(kcal);
                ElegantNotification.info(
                    title: const Text("정보"),
                    description: Text("선택된 음식의 열량: $kcal")
                ).show(context);
              }
          ),
          Expanded(
              child: _Description(
                name: name,
                maker: maker,
                kcal: kcal,
                size: size,
              )
          ),
          const Icon(Icons.more_vert, size: 15),
        ],
      ),
    );
  }
}


class _Description extends StatelessWidget {
  const _Description({
    required this.name,
    required this.maker,
    required this.kcal,
    required this.size
  });

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
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0
              ),
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
        )
    );
  }
}