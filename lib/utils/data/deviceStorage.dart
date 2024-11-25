
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

class StorageManager {
  static final Map<String, String> _files = {}; // Map to track file paths for keys

  /// Save data to a file
  static Future<void> saveData(String key, dynamic value) async {
    final file = await _getFile(key);

    if (value is int || value is String || value is bool) {
      final data = jsonEncode({'type': value.runtimeType.toString(), 'value': value});
      await file.writeAsString(data);
      log('Data saved for key "$key": $value');
    } else {
      log("Invalid Type: Only int, String, and bool are supported.");
    }
  }

  /// Read data from a file
  static Future<dynamic> readData(String key) async {
    final file = await _getFile(key);

    if (await file.exists()) {
      final data = await file.readAsString();
      final decoded = jsonDecode(data);

      if (decoded['type'] == 'int') return int.parse(decoded['value'].toString());
      if (decoded['type'] == 'String') return decoded['value'];
      if (decoded['type'] == 'bool') return decoded['value'] == 'true';

      print("Unknown type for key: $key");
      return null;
    } else {
      print("No data found for key: $key");
      return null;
    }
  }

  /// Delete data for a specific key
  static Future<bool> deleteData(String key) async {
    final file = await _getFile(key);

    if (await file.exists()) {
      await file.delete();
      print('Data deleted for key "$key".');
      return true;
    } else {
      print("No data to delete for key: $key.");
      return false;
    }
  }

  /// Delete all saved data
  static Future<void> deleteAllData() async {
    for (String path in _files.values) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _files.clear();
    print("All data deleted.");
  }

  /// Private: Get the file for a specific key
  static Future<File> _getFile(String key) async {
    final directory = Directory.systemTemp; // Temporary directory for simplicity
    final path = '${directory.path}/$key.json';
    _files[key] = path; // Store the file path for reference
    return File(path);
  }
}


// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class StorageManager {
//   static const String _boxName = "appStorage";

//   /// Initialize Hive and open the storage box
//   static Future<void> init() async {
//     await Hive.initFlutter();
//     await Hive.openBox(_boxName);
//   }

//   /// Save data based on its type
//   static Future<void> saveData(String key, dynamic value) async {
//     var box = Hive.box(_boxName);
//     if (value is int || value is String || value is bool || value is double) {
//       box.put(key, value);
//     } else {
//       print("Invalid Type");
//     }
//   }

//   /// Read data based on key
//   static dynamic readData(String key) {
//     var box = Hive.box(_boxName);
//     return box.get(key);
//   }

//   /// Delete specific data by key
//   static Future<void> deleteData(String key) async {
//     var box = Hive.box(_boxName);
//     await box.delete(key);
//   }

//   /// Clear all data from the storage box
//   static Future<void> deleteAllSharedPreferencesData() async {
//     var box = Hive.box(_boxName);
//     await box.clear();
//   }
// }



// import 'package:shared_preferences/shared_preferences.dart';

// class StorageManager {
//   static void saveData(String key, dynamic value) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (value is int) {
//       prefs.setInt(key, value);
//     } else if (value is String) {
//       prefs.setString(key, value);
//     } else if (value is bool) {
//       prefs.setBool(key, value);
//     } else {
//       print("Invalid Type");
//     }
//   }

//   static Future<dynamic> readData(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     dynamic obj = prefs.get(key);
//     return obj;
//   }

//   static Future<bool> deleteData(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.remove(key);
//   }

//   static Future<void> deleteAllSharedPreferencesData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.clear();
// }
// }


// //variables assigned in app
// //Lang