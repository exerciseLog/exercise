import 'package:flutter/cupertino.dart';
import 'dart:developer';
import '../model/nutrition_model.dart';

class ApiProvider with ChangeNotifier {
  List<NutApiModel> inList = [];
  bool inProgress = false;
  String selectedCal = '';

  List<NutApiModel> getResult() => inList;

  getLength() => inList.length;

  setResult(List<NutApiModel> resultList) {
    inList = resultList;
    notifyListeners();
  }

  modifyBool() {
    inProgress = !inProgress;
    notifyListeners();
  }

  void setCalorie(String cal) {
    selectedCal = cal;
    var test = double.parse(selectedCal);
    log(test.toString());
    notifyListeners();
  }

}