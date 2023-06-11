import 'package:flutter/cupertino.dart';
import '../model/nutrition_model.dart';

class ApiProvider with ChangeNotifier {
  List<NutApiModel> inList = [];
  bool inProgress = false;
    
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
  
  
}