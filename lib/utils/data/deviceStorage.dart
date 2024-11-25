
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

// //variables assigned in app
// //Lang