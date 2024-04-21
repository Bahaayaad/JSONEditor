import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'dart:convert';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../models/my_app_state.dart';

class JsonEditor extends StatefulWidget {
  @override
  State<JsonEditor> createState() => _JsonEditorState();
}

class _JsonEditorState extends State<JsonEditor> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ValueListenableBuilder<String>(
      valueListenable: appState.jsonStringNotifier,
      builder: (context, jsonString, _) {
        return MouseRegion(
          onEnter: (_) {
            setState(() {
              _isEditing = true;
            });
          },
          onExit: (_) {
            setState(() {
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
                        initialValue: jsonString,
                        onChanged: (value) {
                          setState(() {
                            appState.changeJson(value);
                          });
                        },
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                              (value) {
                            try {
                              jsonDecode(value!);
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
                jsonString,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
        );
      },
    );
  }
}
