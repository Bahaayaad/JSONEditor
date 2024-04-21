import 'dart:convert';

import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  ValueNotifier<String> jsonStringNotifier = ValueNotifier("");
  String jsonString = "";
  String newString = "" ;
  void changeJson(value) {
    jsonStringNotifier.value  = value ;
    jsonString = value ;
    notifyListeners();
  }
  void fieldEdit(Map<String, dynamic> jsonObject){
    print("lets see this crab $jsonObject") ;
    jsonStringNotifier.value = JsonEncoder.withIndent('  ').convert(jsonObject);

  }
}
