import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/ui.dart';

abstract class Model {
   String? id;

  bool get hasData => id != null;


  void fromJson(Map<String, dynamic> json) {
    id = stringFromJson(json, 'id');
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == id;
  }

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }


   String stringFromJson(Map<String, dynamic>? json, String attribute, {String defaultValue = ''}) {
     try {
       if (json != null && json.containsKey(attribute)) {
         return json[attribute]?.toString() ?? defaultValue;
       }
       return defaultValue; // Return default value if attribute is missing
     } catch (e) {
       throw Exception('Error while parsing $attribute: $e');
     }
   }





   DateTime dateFromJson(Map<String, dynamic> json, String attribute, {required DateTime defaultValue}) {
    try {
      return json != null
          ? json[attribute] != null
          ? DateTime.parse(json[attribute]).toLocal()
          : defaultValue
          : defaultValue;
    } catch (e) {
      throw Exception('Error while parsing $attribute[$e]');
    }
  }

  dynamic mapFromJson(Map<String, dynamic> json, String attribute, {required Map<dynamic, dynamic> defaultValue}) {
    try {
      return json != null
          ? json[attribute] != null
          ? jsonDecode(json[attribute])
          : defaultValue
          : defaultValue;
    } catch (e) {
      throw Exception('Error while parsing $attribute[$e]');
    }
  }

  listFromJson(Map<String, dynamic> json, var attribute){
    try {
      print('Result: ${json}');
      print('Result: ${json['my_posts']}');
      var result = json['my_posts'];
      //print('Result: ${result}');
      //return result[0];
      return result??[];
    } catch (e) {
      throw Exception('Error while parsing $attribute[$e]');
    }
  }

  int intFromJson(Map<String, dynamic> json, String attribute, {int defaultValue = 0}) {
    try {
      if (json[attribute] != null) {
        if (json[attribute] is int) {
          return json[attribute];
        }
        return int.parse(json[attribute]);
      }
      return defaultValue;
    } catch (e) {
      throw Exception('Error while parsing $attribute[$e]');
    }
  }

  double doubleFromJson(Map<String, dynamic> json, String attribute, {int decimal = 2, double defaultValue = 0.0}) {
    try {
      if (json[attribute] != null) {
        if (json[attribute] is double) {
          return double.parse(json[attribute].toStringAsFixed(decimal));
        }
        if (json[attribute] is int) {
          return double.parse(json[attribute].toDouble().toStringAsFixed(decimal));
        }
        return double.parse(double.tryParse(json[attribute])!.toStringAsFixed(decimal));
      }
      return defaultValue;
    } catch (e) {
      throw Exception('Error while parsing $attribute[$e]');
    }
  }

   bool boolFromJson(Map<String, dynamic> json, String attribute, {bool defaultValue = false}) {
     try {
       if (json[attribute] != null) {
         if (json[attribute] is bool) {
           return json[attribute];
         } else if (json[attribute] is String) {
           final lowerValue = json[attribute].toLowerCase();
           if (['true', '1'].contains(lowerValue)) {
             return true;
           } else if (['false', '0', ''].contains(lowerValue)) {
             return false;
           }
         } else if (json[attribute] is int) {
           return json[attribute] != 0;
         }
       }
       return defaultValue;
     } catch (e) {
       throw Exception('Error while parsing $attribute[$e]');
     }
   }


}
