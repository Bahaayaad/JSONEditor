import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:namer_app/widgets/json_dynamic_fields/invalid_json.dart';
import 'package:provider/provider.dart';
import '../../models/my_app_state.dart';

class JsonField extends StatefulWidget {
  final String jsonString;
  const JsonField({required this.jsonString});
  @override
  State<JsonField> createState() => _JsonFieldState();
}

class _JsonFieldState extends State<JsonField> {
  late Map<String, dynamic> _jsonMap;
  late Map<String, bool> _isFieldEditing;
  @override
  void initState() {
    super.initState();
    _parseJson();
    _isFieldEditing = {};
  }

  @override
  void didUpdateWidget(JsonField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.jsonString != oldWidget.jsonString) {
      print("hh");
      _parseJson();
    }
  }

  void _parseJson() {
    try {
      final Map<String, dynamic> parsedJson = jsonDecode(widget.jsonString);
      print("we should get here $parsedJson");
      setState(() {
        _jsonMap = parsedJson;
      });
    } catch (e) {
      // JSON parsing error
      setState(() {
        _jsonMap = {};
      });
    }
  }

  String _generateUniqueIndex(String path, String key) {
    return '$path/$key';
  }

  Widget _buildJsonTree(Map<String, dynamic> json, String path) {
    final app = Provider.of<MyAppState>(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: json.length,
      itemBuilder: (context, index) {
        final key = json.keys.elementAt(index);
        final uniqueIndex = _generateUniqueIndex(path, key);
        final isEditing = _isFieldEditing[uniqueIndex] ?? false;
        final value = json[key];
        var valueGet = key;
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: !isEditing
                    ? Text(key.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                    : TextFormField(
                        initialValue: key.toString(),
                        onChanged: (newValue) {
                          print("lets see what do we have here $uniqueIndex");
                          valueGet = newValue;
                        },
                        onEditingComplete: () {
                          if (valueGet != key) {
                            var thePath = uniqueIndex.split('/');
                            thePath.removeAt(0);
                            updateKeyAndDeleteOriginal(
                                _jsonMap, thePath, valueGet, false);
                            app.fieldEdit(_jsonMap);
                          }
                          setState(() {
                            _isFieldEditing[uniqueIndex] = false;
                          });
                        },
                      ),
                onTap: () {
                  setState(() {
                    _isFieldEditing[uniqueIndex] = true;
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    var thePath = uniqueIndex.split('/');
                    thePath.removeAt(0);
                    setState(() {
                      updateKeyAndDeleteOriginal(
                          _jsonMap, thePath, valueGet, true);
                      app.fieldEdit(_jsonMap);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildJsonNode(key, value, uniqueIndex),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJsonNode(String key, dynamic value, String path) {
    final app = Provider.of<MyAppState>(context);
    final isEditing = _isFieldEditing[value.toString()] ?? false;
    if (value is Map<String, dynamic>) {
      return _buildJsonTree(value, path);
    } else if (value is List) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: value.length,
        itemBuilder: (context, index) {
          return _buildJsonNode(key, value[index], '$path/$index');
        },
      );
    } else {
      var thePath = path.split('/');
      if (value is bool) {
        return Switch(
          value: value,
          onChanged: (newValue) {
            setState(() {
              updateValue(_jsonMap, thePath, newValue);
              app.fieldEdit(_jsonMap);
            });
          },
        );
      } else {
        return GestureDetector(
          onTap: () {
            setState(() {
              _isFieldEditing[value.toString()] = true;
            });
          },
          child: !isEditing
              ? Text(
                  value.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                      fontSize: 18),
                )
              : TextFormField(
                  initialValue: value.toString(),
                  onChanged: (newValue) {
                    updateValue(_jsonMap, thePath, newValue);
                    app.fieldEdit(_jsonMap);
                  },
                  onEditingComplete: () {
                    setState(() {
                      _isFieldEditing[value.toString()] = false;
                    });
                  },
                ),
        );
      }
    }
  }

  void updateValue(var currentLevel, var thePath, dynamic newValue) {
    bool flag = true;
    var p = 0;
    for (int i = 1; i < thePath.length - 1; i++) {
      if (flag && currentLevel[thePath[i]].runtimeType == List<dynamic>) {
        p = int.parse(thePath[i + 1]);
        currentLevel = currentLevel[thePath[i]] as List<dynamic>;
        flag = false;
      } else {
        var k = thePath[i];
        if (RegExp(r'^[0-9]+$').hasMatch(thePath[i])) {
          k = int.parse(thePath[i]);
        }
        currentLevel = currentLevel[k] as Map<String, dynamic>;
        flag = true;
      }
    }
    if (flag) {
      currentLevel[thePath.last] = newValue;
    } else {
      currentLevel[p] = newValue;
    }
  }

  void updateKeyAndDeleteOriginal(
      var currentLevel, var thePath, var newKeyName, bool justDelete) {
    bool flag = true;
    for (int i = 0; i < thePath.length - 1; i++) {
      if (flag && currentLevel[thePath[i]].runtimeType == List<dynamic>) {
        currentLevel = currentLevel[thePath[i]] as List<dynamic>;
        flag = false;
      } else {
        var k = thePath[i];
        if (RegExp(r'^[0-9]+$').hasMatch(thePath[i])) {
          k = int.parse(thePath[i]);
        }
        currentLevel = currentLevel[k] as Map<String, dynamic>;
        flag = true;
      }
    }
    if (justDelete) {
      currentLevel.remove(thePath.last);
      print("lets check here $currentLevel");
    } else {
      var value = currentLevel.remove(thePath.last);
      currentLevel[newKeyName] = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _jsonMap.isNotEmpty ? _buildJsonTree(_jsonMap, '') : InvalidJson();
  }
}
