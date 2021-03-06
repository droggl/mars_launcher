import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mars_launcher/data/app_info.dart';
import 'package:mars_launcher/global.dart';
import 'package:mars_launcher/logic/utils.dart';
import 'package:mars_launcher/services/shared_prefs_manager.dart';

const KEY_APPS_ARE_SAVED = "appsAreSaved";
const KEY_WEATHER_ENABLED = "weatherEnabled";
const KEY_CLOCK_ENABLED = "clockEnabled";
const KEY_CALENDAR_ENABLED = "calendarEnabled";
const KEY_NUM_OF_SHORTCUT_ITEMS = "numOfShortcutItems";
const KEY_SHORTCUT_MODE = "shortcutMode";
const KEY_CLOCK_APP = "clockApp";
const KEY_CALENDAR_APP = "calendarApp";
const KEY_WEATHER_APP = "weatherApp";
const KEY_SWIPE_LEFT_APP = "swipeLeftApp";
const KEY_SWIPE_RIGHT_APP = "swipeRightApp";

class AppShortcutsManager {
  late final ValueNotifierWithKey<AppInfo> clockAppNotifier;
  late final ValueNotifierWithKey<AppInfo> calendarAppNotifier;
  late final ValueNotifierWithKey<AppInfo> weatherAppNotifier;
  late final ValueNotifierWithKey<AppInfo> swipeLeftAppNotifier;
  late final ValueNotifierWithKey<AppInfo> swipeRightAppNotifier;
  late final ShortcutAppsNotifier shortcutAppsNotifier;

  AppShortcutsManager() {
    print("[$runtimeType] INITIALIZING");

    if (SharedPrefsManager.readData(KEY_APPS_ARE_SAVED) ?? false) {
      loadShortcutAppsFromSharedPrefs();
    } else {
      generateGenericShortcutApps();
      loadShortcutAppsFromJson();
    }
  }

  void generateGenericShortcutApps() {
    shortcutAppsNotifier = ShortcutAppsNotifier(List.generate(MAX_NUM_OF_SHORTCUT_ITEMS, (index) => genericAppInfo));
    clockAppNotifier = ValueNotifierWithKey(genericAppInfo, KEY_CLOCK_APP);
    calendarAppNotifier = ValueNotifierWithKey(genericAppInfo, KEY_CALENDAR_APP);
    weatherAppNotifier = ValueNotifierWithKey(genericAppInfo, KEY_WEATHER_APP);
    swipeLeftAppNotifier = ValueNotifierWithKey(genericAppInfo, KEY_SWIPE_LEFT_APP);
    swipeRightAppNotifier = ValueNotifierWithKey(genericAppInfo, KEY_SWIPE_RIGHT_APP);
  }

  void loadShortcutAppsFromJson() async {
    print("[$runtimeType] LOADING APPS FROM JSON");
    try {
      final String response = await rootBundle.loadString('assets/apps.json');
      final shortcutAppsJson = await json.decode(response);

      shortcutAppsNotifier.value = List.generate(MAX_NUM_OF_SHORTCUT_ITEMS, (index) => AppInfo(packageName: shortcutAppsJson["shortcutApps"][index][JSON_KEY_PACKAGE_NAME], appName: shortcutAppsJson["shortcutApps"][index]["name"]));
      clockAppNotifier.value = AppInfo(packageName: shortcutAppsJson["clock"][JSON_KEY_PACKAGE_NAME], appName: shortcutAppsJson["clock"][JSON_KEY_APP_NAME]);
      calendarAppNotifier.value = AppInfo(packageName: shortcutAppsJson["calendar"][JSON_KEY_PACKAGE_NAME], appName: shortcutAppsJson["calendar"][JSON_KEY_APP_NAME]);
      weatherAppNotifier.value = AppInfo(packageName: shortcutAppsJson["weather"][JSON_KEY_PACKAGE_NAME], appName: shortcutAppsJson["weather"][JSON_KEY_APP_NAME]);
      swipeLeftAppNotifier.value = AppInfo(packageName: shortcutAppsJson["camera"][JSON_KEY_PACKAGE_NAME], appName: shortcutAppsJson["camera"][JSON_KEY_APP_NAME]);
      swipeRightAppNotifier.value = AppInfo(packageName: shortcutAppsJson["contacts"][JSON_KEY_PACKAGE_NAME], appName: shortcutAppsJson["contacts"][JSON_KEY_APP_NAME]);
    } catch (e) {
      print("[$runtimeType] error loading from json: $e");
    }
    saveShortcutAppsToSharedPrefs();
  }

  void loadShortcutAppsFromSharedPrefs() {
    print("[$runtimeType] LOADING APPS FROM SHARED PREFS");
    shortcutAppsNotifier = ShortcutAppsNotifier(List.generate(MAX_NUM_OF_SHORTCUT_ITEMS, (index) => AppInfo.fromJsonString(SharedPrefsManager.readData("shortcut$index"))));
    clockAppNotifier = ValueNotifierWithKey(AppInfo.fromJsonString(SharedPrefsManager.readData(KEY_CLOCK_APP)), KEY_CLOCK_APP);
    calendarAppNotifier = ValueNotifierWithKey(AppInfo.fromJsonString(SharedPrefsManager.readData(KEY_CALENDAR_APP)), KEY_CALENDAR_APP);
    weatherAppNotifier = ValueNotifierWithKey(AppInfo.fromJsonString(SharedPrefsManager.readData(KEY_WEATHER_APP)), KEY_WEATHER_APP);
    swipeLeftAppNotifier = ValueNotifierWithKey(AppInfo.fromJsonString(SharedPrefsManager.readData(KEY_SWIPE_LEFT_APP)), KEY_SWIPE_LEFT_APP);
    swipeRightAppNotifier = ValueNotifierWithKey(AppInfo.fromJsonString(SharedPrefsManager.readData(KEY_SWIPE_RIGHT_APP)), KEY_SWIPE_RIGHT_APP);
  }

  void saveShortcutAppsToSharedPrefs() {
    int i = 0;
    for (var appInfo in shortcutAppsNotifier.value) {
      SharedPrefsManager.saveData("shortcut$i", appInfo.toJsonString());
      i++;
    }
    SharedPrefsManager.saveData(clockAppNotifier.key, clockAppNotifier.value.toJsonString());
    SharedPrefsManager.saveData(calendarAppNotifier.key, calendarAppNotifier.value.toJsonString());
    SharedPrefsManager.saveData(weatherAppNotifier.key, weatherAppNotifier.value.toJsonString());
    SharedPrefsManager.saveData(swipeLeftAppNotifier.key, swipeLeftAppNotifier.value.toJsonString());
    SharedPrefsManager.saveData(swipeRightAppNotifier.key, swipeRightAppNotifier.value.toJsonString());

    SharedPrefsManager.saveData(KEY_APPS_ARE_SAVED, true);
  }

  void setSpecialShortcutValue(ValueNotifierWithKey notifier, AppInfo appInfo) {
    notifier.value = appInfo;
    SharedPrefsManager.saveData(notifier.key, notifier.value.toJsonString());
  }
}


class ShortcutAppsNotifier extends ValueNotifier<List<AppInfo>> {
  ShortcutAppsNotifier(List<AppInfo> initialShortcutApps) : super(initialShortcutApps);

  void replaceShortcut(int index, AppInfo newShortcutApp) async {
    print("[$runtimeType] replacing index: $index");

    if (List.generate(MAX_NUM_OF_SHORTCUT_ITEMS, (i) => i).contains(index)) {
      value[index] = newShortcutApp;
      print("[$runtimeType] replaced shortcut");
      notifyListeners();
    }
    SharedPrefsManager.saveData("shortcut$index", newShortcutApp.toJsonString());
  }
}
