import 'package:flutter/material.dart';
import 'package:mars_launcher/data/app_info.dart';
import 'package:mars_launcher/logic/apps_manager.dart';
import 'package:mars_launcher/logic/shortcut_manager.dart';
import 'package:mars_launcher/logic/utils.dart';
import 'package:mars_launcher/pages/dialogs/dialog_app_info.dart';
import 'package:mars_launcher/pages/fragments/cards/app_card.dart';
import 'package:mars_launcher/services/service_locator.dart';

enum AppSearchMode { openApp, chooseShortcut, chooseSpecialShortcut }

class AppSearchManager {
  final appsManager = getIt<AppsManager>();
  final appShortcutsManager = getIt<AppShortcutsManager>();
  late final ValueNotifier<List<AppInfo>> filteredAppsNotifier;
  final Map<AppInfo, AppCard> memorizedAppCards = {};

  /// Temporary parameters that are set when AppSearchFragment is initialized
  AppSearchMode? appSearchMode;
  int? shortcutIndex;

  ValueNotifierWithKey<AppInfo>? specialShortcutAppNotifier;

  AppSearchManager() {
    filteredAppsNotifier = ValueNotifier(getFilteredApps());

    appsManager.appsNotifier.addListener(() {
      filteredAppsNotifier.value = getFilteredApps();
    });
  }

  List<AppInfo> getFilteredApps() {
    return appsManager.appsNotifier.value.where((app) => !app.isHidden).toList();
  }

  AppCard generateAppCard(AppInfo appInfo) {
    return AppCard(
      appInfo: appInfo,
      callbackHandleOnPress: handleOnPress,
      callbackHandleOnLongPress: handleOnLongPress,
    );
  }

  AppCard getMemorizedAppCard(AppInfo appInfo) {
    return memorizedAppCards.putIfAbsent(appInfo, () => generateAppCard(appInfo));
  }

  setTemporaryParameters(
      AppSearchMode appSearchMode, int? shortcutIndex, ValueNotifierWithKey<AppInfo>? specialShortcutAppNotifier) {
    this.appSearchMode = appSearchMode;
    this.shortcutIndex = shortcutIndex;
    this.specialShortcutAppNotifier = specialShortcutAppNotifier;
  }

  resetFilteredList() async {
    filteredAppsNotifier.value = getFilteredApps();

    appSearchMode = shortcutIndex = specialShortcutAppNotifier = null;
  }

  handleOnPress(BuildContext context, AppInfo appInfo) {
    switch (appSearchMode) {
      case AppSearchMode.openApp:
        openApp(appInfo);
        break;
      case AppSearchMode.chooseShortcut:
        replaceShortcut(context, appInfo);
        break;
      case AppSearchMode.chooseSpecialShortcut:
        replaceSpecialShortcut(context, appInfo);
        break;
      case null:
        break;
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  handleOnLongPress(BuildContext context, AppInfo appInfo) async {
    final result = await showDialog(
      context: context,
      builder: (_) => AppInfoDialog(appInfo: appInfo),
    );

    // Handle the result
    if (result != null) {
      print('Dialog result: $result');
    }
  }

  openApp(AppInfo appInfo) {
    appInfo.open();
  }

  replaceShortcut(BuildContext context, AppInfo appInfo) {
    if (shortcutIndex != null) {
      print("[$runtimeType] Replacing shortcut app with index $shortcutIndex with ${appInfo.appName}");
      appShortcutsManager.shortcutAppsNotifier.replaceShortcut(shortcutIndex!, appInfo);
      Navigator.of(context).pop();
    }
  }

  replaceSpecialShortcut(BuildContext context, AppInfo appInfo) {
    if (specialShortcutAppNotifier != null) {
      print("[$runtimeType] Replacing special shortcut app ${specialShortcutAppNotifier!.key} with ${appInfo.appName}");
      appShortcutsManager.setSpecialShortcutValue(specialShortcutAppNotifier!, appInfo);
      Navigator.of(context).pop();
    }
  }

  updateFilteredApps(BuildContext context, String searchValue) async {
    List<AppInfo> filteredApps = appsManager.appsNotifier.value
        .where((app) => app.displayName.toLowerCase().contains(searchValue.toLowerCase()) && !app.isHidden)
        .toList();
    if (filteredApps.length == 1) {
      handleOnPress(context, filteredApps.first);
    }
    filteredAppsNotifier.value = filteredApps;
  }
}
