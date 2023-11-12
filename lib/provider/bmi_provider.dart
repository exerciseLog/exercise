import 'package:flutter/material.dart';

class BmiProvider with ChangeNotifier {
  double _height = 0.0;
  final double _weight = 0.0;
  double _standardWeight = 0.0;
  int _standardCalorie = 0;
    
  String getWeight() => _weight.toString();
  String getHeight() => _height.toString();
  String getStandardWeight() => _standardWeight.toString();
  String getStandardCalorie() => _standardCalorie.toString();
  
  setHeight(String height) {
    _height = double.parse(height);
    final calHeight = _height / 100;
    _standardWeight = double.parse((calHeight * calHeight * 22).toStringAsFixed(1));
    _standardCalorie = (_standardWeight * 30).round();
    notifyListeners();
  } 

  
}