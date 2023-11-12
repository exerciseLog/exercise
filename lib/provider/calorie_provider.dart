import 'package:flutter/material.dart';

class CalorieProvider with ChangeNotifier {
  double _calorie = 0.0;
  String _selectedFood = '';
  String _selectedCal = '';
  int _selectednum = 0;
  String _percent = '0';
  List<String> selectedFoodList = [];
  List<String> selectedCalList = [];
  int _selectedNumList = 0;

  String get selectedFood => _selectedFood;
  String get selectedCal => _selectedCal;
  String get getCalorie => _calorie.toString();
  int get listNum => _selectednum;
  int get selListNum => _selectedNumList;
  String get percent => _percent;

  setCalorie(String food, String cal, int num) {
    _selectedFood = food;
    _selectedCal = cal;
    _selectednum = num;
    notifyListeners();
  }

  addCalorie(String food, String cal, String stdCal) {
    var selCal = double.parse(cal);
    var result = _calorie + selCal;
    _calorie = double.parse(result.toStringAsFixed(2));
    if(stdCal != '0') {
      var percent = _calorie / double.parse(stdCal) * 100; 
      _percent = percent.toStringAsFixed(1);
    }
    selectedFoodList.add(food);
    selectedCalList.add(cal);
    notifyListeners();
  }

  resetCalorie() {
    _calorie = 0.0;
    _selectednum = 0;
    selectedFoodList.clear();
    selectedCalList.clear();
    _selectedNumList = 0;
    notifyListeners();
  }

  resetList() {
    _selectednum = 0;
    _selectedCal = '';
    notifyListeners();
  }
  
  setSelectedList(int index) {
    _selectedNumList = index;
    notifyListeners();
  }

  deleteSelectedList() {
    var dCal = double.parse(selectedCalList[_selectedNumList]);
    _calorie -= dCal;
    selectedFoodList.removeAt(_selectedNumList);
    selectedCalList.removeAt(_selectedNumList);
    notifyListeners();
  }
    
}