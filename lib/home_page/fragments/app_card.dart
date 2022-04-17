import 'package:flutter/material.dart';
import 'package:flutter_mars_launcher/data/app_info.dart';
import 'package:flutter_mars_launcher/home_page/fragments/app_search_fragment.dart';
import 'package:flutter_mars_launcher/logic/apps_logic.dart';
import 'package:flutter_mars_launcher/services/service_locator.dart';



typedef OpenAppCallback = Function(AppInfo appInfo);

class AppCard extends StatelessWidget {
  final AppInfo appInfo;
  final bool isShortcutItem;
  final OpenAppCallback openApp;

  AppCard({required this.appInfo, required this.isShortcutItem, required this.openApp});

  @override
  Widget build(BuildContext context) {
    final appsManager = getIt<AppsManager>();

    var fontFamily = isShortcutItem ? "NotoSansRegular" : "NotoSansLight";
    var letterSpacing = isShortcutItem ? 1.0 : 0.0;
    var textColor = isShortcutItem ? Colors.white : Colors.deepOrange;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
      child: TextButton(
        onPressed: () {
          openApp(appInfo);
        },
        onLongPress: () {

          if (isShortcutItem) {
            int shortcutIndex = appsManager.shortcutAppsNotifier.value.indexOf(appInfo);

            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    Scaffold(body: SafeArea(child: AppSearchFragment(shortcutSelectionMode: true, shortcutIndex: shortcutIndex)))
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (_) => AppInfoDialog(appInfo: appInfo),
            );
          }
        },
        child: Text(
          appInfo.appName,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w100,
            fontFamily: fontFamily,
            letterSpacing: letterSpacing,
          ),
        ),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(isShortcutItem ? Theme.of(context).primaryColor : Colors.deepOrange),
        ),
      ),
    );
  }
}

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({
    Key? key,
    required this.appInfo,
  }) : super(key: key);

  final AppInfo appInfo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        appInfo.appName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        appInfo.systemApp
            ? Container()
            : TextButton(
                onPressed: () {
                  appInfo.uninstall();
                  Navigator.of(context).pop();
                },
                child: Text("Uninstall")),
        TextButton(
            onPressed: () {
              appInfo.openSettings();
              Navigator.of(context).pop();
            },
            child: Text("Info")),
      ],
    );
  }
}
