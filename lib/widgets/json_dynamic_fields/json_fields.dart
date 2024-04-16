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
  Map <String, int>? mp;
  Map <dynamic, int>? myOccurrence;


  _JsonFieldState() {
    _isFieldEditing = {}; // Initialize _isFieldEditing here
    myOccurrence = {};
    mp = {};
  }
  @override
  void initState() {
    super.initState();
    _parseJson();
    //_isFieldEditing = {};
    myOccurrence = {};
  }

  @override
  void didUpdateWidget(JsonField oldWidget) {
    super.didUpdateWidget(oldWidget);
    mp = {};
    if (widget.jsonString != oldWidget.jsonString) {
      _parseJson();
      _countOccurrence(_jsonMap);
      myOccurrence = {};
    }
  }

  void _parseJson() {
    try {
      final Map<String, dynamic> parsedJson = jsonDecode(widget.jsonString);
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

  void _countOccurrence(dynamic json) {
    if (json is Map) {
      json.forEach((key, value) {
        if (mp!.containsKey(key)) {
          mp![key] = (mp![key] ?? 1) + 1;
        } else {
          mp![key] = 1;
        }
        if (value is Map || value is List) {
          _countOccurrence(value);
        }
      });
    } else if (json is List) {
      for (var item in json) {
        _countOccurrence(item);
      }
    }

  }

  Widget _buildJsonTree(Map<String, dynamic> json) {
    mp = {};
    _countOccurrence(_jsonMap);
    final app = Provider.of<MyAppState>(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: json.length,
      itemBuilder: (context, index) {
        final key = json.keys.elementAt(index);
        final isEditing = _isFieldEditing[key] ?? false;
        myOccurrence ?[index] = (mp![key]!) ;
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
                    print("for the sake of testing ----> $index");
                    app.fieldEdit(_jsonMap, myOccurrence?[index], key, newValue, true);
                  },
                  onEditingComplete: (){
                    if(valueGet != key) {
                      json[valueGet] = json[key];
                      _deleteField(key);
                    }
                    setState(() {
                      _isFieldEditing[key] =false;
                      app.updateString();
                    });
                  },
                ),
                onTap: (){
                  setState(() {
                    if(myOccurrence![index] == null){
                    }
                    else{
                    }
                    _isFieldEditing[key] = true;
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteField(key),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildJsonNode(key, value, index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJsonNode(String key,dynamic value, int index) {
    mp = {};
    _countOccurrence(_jsonMap);
    final app = Provider.of<MyAppState>(context);
    final isEditing = _isFieldEditing[value] ?? false;
    var valueGet = value;
    if (value is Map<String, dynamic>) {
      return _buildJsonTree(value);
    } else if (value is List) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: value.length,
        itemBuilder: (context, index) {
          return _buildJsonNode(key,value[index], index);
        },
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isFieldEditing[value] = true;
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
            valueGet = newValue;
            app.fieldEdit(_jsonMap, myOccurrence?[index], key, newValue, false);
          },
          onEditingComplete: (){
            _jsonMap[key] = value;
            _deleteField(value);
            mp = {};
            _countOccurrence(_jsonMap);
            setState(() {
              _isFieldEditing[value] =false;
              app.updateString();
            });
          },
        ) ,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _jsonMap.isNotEmpty
        ? _buildJsonTree(_jsonMap)
        : InvalidJson();
  }
}
