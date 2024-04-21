import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_app_state.dart';
import '../widgets/json_editor.dart';
import '../widgets/json_dynamic_fields/json_fields.dart';
class SplitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = Provider.of<MyAppState>(context);
    print("hello");
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: JsonEditor(),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
            child: JsonField(jsonString:app.jsonString),
          ),
        ),
      ],
    );
  }
}