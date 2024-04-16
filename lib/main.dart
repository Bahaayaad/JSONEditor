import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/my_app_state.dart';
import 'screens/my_app.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MyApp(),
    ),
  );
}



