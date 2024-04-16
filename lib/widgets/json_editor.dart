import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'dart:convert';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../models/my_app_state.dart';

class JsonEditor extends StatefulWidget {
  Map<String, dynamic> parsedJson = {} ;

  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  Map<String, dynamic>? _jsonMap;
  bool _isEditing = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var text = appState.jsonString;
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isEditing = true;
        });
      },
      onExit: (_) {
        setState(() {
          appState.updateString2();
          _isEditing = false;
        });
      },
      child: GestureDetector(
        child: _isEditing
            ? SingleChildScrollView(
              child: FormBuilder(
                        autovalidateMode: AutovalidateMode.always,
                        child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 133),
                  child: FormBuilderTextField(
                    name: 'json',
                    maxLines: null,
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Enter JSON',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: appState.jsonString,
                    onChanged: (value) {
                      appState.changeJson(value);
                    },
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                          (value) {
                        try {
                          widget.parsedJson = jsonDecode(value!);
                          text = widget.parsedJson.toString();
                          return null;
                        } catch (e) {
                          return 'Invalid JSON format';
                        }
                      },
                    ]),
                  ),
                ),
              ],
                        ),
                      ),
            )
            : Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(
            appState.newString,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
      ),
    );
  }
}