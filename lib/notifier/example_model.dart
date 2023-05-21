import 'package:flutter/material.dart';

class ExampleModel with ChangeNotifier {
  int counter = 0;

  increaseCount() {
    counter++;
    notifyListeners();
  }
}
