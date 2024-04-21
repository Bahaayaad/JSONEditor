import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:namer_app/widgets/json_dynamic_fields/invalid_json.dart';
import 'package:provider/provider.dart';
import '../../models/my_app_state.dart';

class JsonField extends StatefulWidget {
    final String jsonString ;
    const JsonField({required this.jsonString});
  @override
  State<JsonField> createState() => _JsonFieldState();
}

class _JsonFieldState extends State<JsonField> {
  late Map<String, dynamic> _jsonMap;
  late Map<String, bool> _isFieldEditing;
  _JsonFieldState() {
    print("hello");
    _isFieldEditing = {};
  }
  @override
  void initState() {
    print("von");
    super.initState();
    _parseJson();
    //_isFieldEditing = {};
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



  void _deleteField(String key) {
    setState(() {
      _removeFieldAndChildren(_jsonMap, key);
    });
  }

  void _removeFieldAndChildren(Map<String, dynamic> json, String key) {
    json.remove(key);
    json.forEach((nestedKey, nestedValue) {
      if (nestedValue is Map<String, dynamic>) {
        _removeFieldAndChildren(nestedValue, key);
      } else if (nestedValue is List) {
        for (var item in nestedValue) {
          if (item is Map<String, dynamic>) {
            _removeFieldAndChildren(item, key);
          }
        }
      }
    });
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
                title: !isEditing?
                Text(
                    key.toString(), style: TextStyle(fontWeight: FontWeight.bold)
                ) :TextFormField(
                  initialValue: key.toString(),
                  onChanged: (newValue){
                    valueGet = newValue;
                  },
                  onEditingComplete: (){
                    //print("lets figure $json");
                    if(valueGet != key) {
                      json[valueGet] = json[key];
                      print("lets figure $_jsonMap and $json");
                      _deleteField(key);
                      app.fieldEdit(_jsonMap) ;
                    }
                    setState(() {
                      _isFieldEditing[uniqueIndex] =false;
                    });
                  },
                ),
                onTap: (){
                  setState(() {
                    _isFieldEditing[uniqueIndex] = true;
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteField(key),
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
              getLevels(_jsonMap, thePath, newValue);
              app.fieldEdit(_jsonMap) ;
            });

          },
        );
      }
      else {
        return GestureDetector(
          onTap: () {
            setState(() {
              _isFieldEditing[value.toString()] = true;
            });
          },
          child:!isEditing?
          Text(
            value.toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
                fontSize: 18
            ),
          ):TextFormField(
            initialValue: value.toString(),
            onChanged: (newValue){
              getLevels(_jsonMap, thePath, newValue);
              app.fieldEdit(_jsonMap) ;
            },
            onEditingComplete: (){
              setState(() {
                print("lets see what we get here") ;
                _isFieldEditing[value.toString()] =false;
              });
            },
          ) ,
        );
      }
    }
  }

  void getLevels(var currentLevel, var thePath, dynamic newValue){
    bool flag = true ;
    var  p = 0 ;
    for (int i = 1; i < thePath.length-1; i++) {
      if(flag && currentLevel[thePath[i]].runtimeType == List<dynamic>){
        p = int.parse(thePath[i+1]) ;
        currentLevel = currentLevel[thePath[i]] as List<dynamic>;
        flag = false;
      }else {
        var k = thePath[i];
        if(RegExp(r'^[0-9]+$').hasMatch(thePath[i])){
          k = int.parse(thePath[i]);
        }
        print("here we will deal with the issue ${thePath[i]} and $k");
        currentLevel = currentLevel[k] as Map<String, dynamic>;
        flag =true;
      }
    }
    if(flag) {
      currentLevel[thePath.last] = newValue;
    }else{
      currentLevel[p] = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _jsonMap.isNotEmpty
        ? _buildJsonTree(_jsonMap, '')
        : InvalidJson();
  }
}
