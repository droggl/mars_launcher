/// All logic according to dark and light theme

import 'package:flutter/material.dart';
import 'package:mars_launcher/services/service_locator.dart';
import 'package:mars_launcher/services/shared_prefs_manager.dart';
import 'package:mars_launcher/strings.dart';
import 'package:mars_launcher/theme/theme_constants.dart';


class ThemeManager {
  final sharedPrefsManager = getIt<SharedPrefsManager>();

  late final themeModeNotifier;

  late Color lightBackground;
  late Color darkBackground;
  late Color searchTextColor;

  ThemeManager() {
    themeModeNotifier = ThemeModeNotifier<ThemeMode>(
        sharedPrefsManager.readDataWithDefault(Keys.themeMode, true) ? ThemeMode.dark : ThemeMode.light
    );
  lightBackground = Color(sharedPrefsManager.readData(Keys.lightBackground) ?? Colors.white.value);
  darkBackground = Color(sharedPrefsManager.readData(Keys.darkBackground) ?? Colors.black.value);
  searchTextColor = Color(sharedPrefsManager.readData(Keys.lightSearchColor) ?? COLOR_ACCENT.value);
  }

  bool get isDarkMode {
    return themeModeNotifier.value == ThemeMode.dark;
  }

  ThemeData get lightTheme {
    return basicLightTheme.copyWith(scaffoldBackgroundColor: lightBackground);
  }

  ThemeData get darkTheme {
    return basicDarkTheme.copyWith(scaffoldBackgroundColor: darkBackground);
  }

  get systemUiOverlayStyle {
    /// If background color is changed (!= white or black) -> it is not possible to adjust status bar color to background color -> therefore use normal contrast in that case
    final statusBarIconBrightnessDark = darkBackground == COLOR_DARK_BACKGROUND ? Brightness.dark : Brightness.light;
    final statusBarIconBrightnessLight = lightBackground == COLOR_LIGHT_BACKGROUND ? Brightness.light : Brightness.dark;
    final systemUiOverlayStyle = isDarkMode ?
      lightSystemUiOverlayStyle.copyWith(systemNavigationBarColor: darkBackground, statusBarColor: darkBackground, statusBarIconBrightness: statusBarIconBrightnessDark) :
      darkSystemUiOverlayStyle.copyWith(systemNavigationBarColor: lightBackground, statusBarColor: lightBackground, statusBarIconBrightness: statusBarIconBrightnessLight);

    return systemUiOverlayStyle;
  }

  void toggleTheme() {
    if (themeModeNotifier.value == ThemeMode.light) {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.light;
    }
    sharedPrefsManager.saveData(Keys.themeMode, isDarkMode);
    print("Changed themeMode to ${themeModeNotifier.value}");
  }

  void setBackgroundColor(bool isDarkMode, Color color) {
    if (isDarkMode) {
      darkBackground = color;
      sharedPrefsManager.saveData(Keys.darkBackground, color.value);
    } else {
      lightBackground = color;
      sharedPrefsManager.saveData(Keys.lightBackground, color.value);
    }
    themeModeNotifier.notify();
  }
}

class ThemeModeNotifier<T> extends ValueNotifier<T> {
  ThemeModeNotifier(T value) : super(value);

  void notify() {
    notifyListeners();
  }
}
