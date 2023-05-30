import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:exercise_log/model/nutrition_model.dart';

class ApiService {
  static const String url =
      "https://openapi.foodsafetykorea.go.kr/api/81084e1ce468417b9f5f/I2790/json/1/20";

  static Future<List<NutApiModel>> getNutrition(String foodName) async {
    List<NutApiModel> resList = [];
    final sendUrl = Uri.parse("$url/DESC_KOR=$foodName");
    final response = await http.get(sendUrl);
    if (response.statusCode == 200) {
      final resJson = jsonDecode(response.body);
      final results = resJson['I2790']['row'];
      if (results == null) {
        return Future.error('검색된 결과가 없습니다.');
      }
      for (var result in results) {
        final instance = NutApiModel.fromJson(result);
        resList.add(instance);
      }
      return resList;
    }
    throw Error();
  }
}

/* !Stream class
return (jsonDecode(response.body) as List).map((e) =>
NutApiModel.fromJson(e)).toList();*/
