
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