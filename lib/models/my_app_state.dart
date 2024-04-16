import 'dart:convert';

import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  String jsonString = "";
  String newString = "" ;
  void changeJson(value) {
    jsonString = value ;
    notifyListeners();
  }
  void fieldEdit(Map<String, dynamic> jsonObject, int? freq, String key, String newValue, bool flag){
    String? findKey(Map<String, dynamic> map, String targetKey, [String currentPath = '']) {
      for (var entry in map.entries) {
        var newPath = currentPath.isEmpty ? entry.key : '$currentPath.${entry.key}';
        print("lets see what we get here  $newPath") ;
        if (entry.key == targetKey) {
          return newPath;
        } else if (entry.value is Map<String, dynamic>) {
          var result = findKey(entry.value, targetKey, newPath);
          if (result != null) {
            return result;
          }
        }
      }
      return null;
    }
    String? keyPath = findKey(jsonObject, key);
    keyPath ??= key;
    RegExp pattern = RegExp(r'"' + keyPath.replaceAll('.', r'\.') + r'"\s*:\s*');
    if(!flag) {
      pattern = RegExp(r'"(' + keyPath.replaceAll('.', r'\.') + r'"\s*:\s*)"\w*"');
    }
    int replaceCount = 0;
    if (pattern.hasMatch(jsonString)) {
      print('Pattern matched!');

    } else {
      print('Pattern not matched.');
    }
    newString = jsonString.replaceAllMapped(pattern, (match) {
      replaceCount++;
      print("lets see here $freq");
      print("sad w rb al 3ebad $freq");
      print("vsdvsbrfndgjndtrhgdgegwgwassfvs");
      if(replaceCount == freq) {
        if(flag) {
          return '"$newValue":${match.group(0)!.split(":")[1]}';
        } else{
          return '"${match.group(1)!}"$newValue"';
        }
      }
      return match.group(0)!;
    });
    notifyListeners();
  }
  void updateString(){
    jsonString = newString ;
    notifyListeners();
  }
  void updateString2(){
    newString = jsonString;
    notifyListeners();
  }
}
