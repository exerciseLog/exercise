import 'package:flutter/material.dart';

class CalorieProvider with ChangeNotifier {
  double _calorie = 0.0;
  String _selectedFood = '';
  String _selectedCal = '';
  int _selectedLnum = 0;
  List<String> selectedFoodList = [];
  List<String> selectedCalList = [];

  String get selectedFood => _selectedFood;
  String get selectedCal => _selectedCal;
  String get getCalorie => _calorie.toString();
  int get listNum => _selectedLnum;

  setCalorie(String food, String cal, int num) {
    _selectedFood = food;
    _selectedCal = cal;
    _selectedLnum = num;
    notifyListeners();
  }

  addCalorie(String food, String cal) {
    var selCal = double.parse(cal);
    var result = _calorie + selCal;
    _calorie = double.parse(result.toStringAsFixed(2));
    selectedFoodList.add(food);
    selectedCalList.add(cal);
    
    notifyListeners();
  }

  resetCalorie() {
    _calorie = 0.0;
    _selectedLnum = 0;
    selectedFoodList.clear();
    selectedCalList.clear();
    notifyListeners();
  }

  resetList() {
    _selectedLnum = 0;
    _selectedCal = '';
    notifyListeners();
  }
  
  
}