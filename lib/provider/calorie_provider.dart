import 'package:flutter/material.dart';

class CalorieProvider with ChangeNotifier {
  double _calorie = 0.0;
  String _selectedCal = '';

  String get selectedCal => _selectedCal;

  setCalorie(String cal) {
    _selectedCal = cal;
    notifyListeners();
  }

  String get getCalorie => _calorie.toString();

  addCalorie(String cal) {
    var selCal = double.parse(cal);
    _calorie = _calorie + selCal;
    notifyListeners();
  }

  resetCalorie() {
    _calorie = 0.0;
    notifyListeners();
  }
}