import 'package:mars_launcher/main.dart';

class SharedPrefsManager {
  static void saveData(String key, dynamic value) async {
    print("[SharedPrefsManager] WRITE $key: $value");
    if (value is int) {
      prefs.setInt(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is List<String>) {
      prefs.setStringList(key, value);
    } else {
      print("Invalid Type");
    }
  }

  static dynamic readData(String key) {
    dynamic obj = prefs.get(key);
    print("[SharedPrefsManager] READ $key: $obj");
    return obj;
  }

  static List<String>? readStringList(String key) {
    List<String>? objList = prefs.getStringList(key);
    print("[SharedPrefsManager] READ $key: $objList");
    return objList;
  }

  static Future<bool> deleteData(String key) async {
    return prefs.remove(key);
  }
}
