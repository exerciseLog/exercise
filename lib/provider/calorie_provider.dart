import 'package:flutter/material.dart';

class CalorieProvider with ChangeNotifier {
  double _calorie = 0.0;
  String _selectedCal = '';
  int _selectedLnum = 0;

  String get selectedCal => _selectedCal;

  setCalorie(String cal, int num) {
    _selectedCal = cal;
    _selectedLnum = num;
    notifyListeners();
  }

  String get getCalorie => _calorie.toString();

  addCalorie(String cal) {
    var selCal = double.parse(cal);
    var result = _calorie + selCal;
    _calorie = double.parse(result.toStringAsFixed(2));
    notifyListeners();
  }

  resetCalorie() {
    _calorie = 0.0;
    _selectedLnum = 0;
    notifyListeners();
  }

  int get listNum => _selectedLnum;

  // setLnum(int num) {
  //   _selectedLnum = num;
  //   notifyListeners();
  // }

  resetList() {
    _selectedLnum = 0;
    _selectedCal = '';
    notifyListeners();
  }
}