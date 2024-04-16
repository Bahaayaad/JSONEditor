import 'package:flutter/material.dart';
import 'split_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SplitScreen(),
      ),
    );
  }
}