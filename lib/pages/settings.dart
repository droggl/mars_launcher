import 'package:flutter/material.dart';
import 'package:mars_launcher/data/app_info.dart';
import 'package:mars_launcher/logic/app_search_manager.dart';
import 'package:mars_launcher/logic/settings_manager.dart';
import 'package:mars_launcher/logic/shortcut_manager.dart';
import 'package:mars_launcher/pages/credits.dart';
import 'package:mars_launcher/theme/theme_manager.dart';
import 'package:mars_launcher/logic/utils.dart';
import 'package:mars_launcher/pages/dialogs/dialog_color_picker.dart';
import 'package:mars_launcher/pages/fragments/app_search_fragment.dart';
import 'package:mars_launcher/pages/hidden_apps.dart';
import 'package:mars_launcher/services/permission_service.dart';
import 'package:mars_launcher/services/service_locator.dart';
import 'package:mars_launcher/strings.dart';

const TEXT_STYLE_TITLE = TextStyle(fontSize: 35, fontWeight: FontWeight.normal);
const TEXT_STYLE_ITEMS = TextStyle(fontSize: 22, height: 1);
const ROW_PADDING_RIGHT = 50.0; // TODO look for overflow

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with WidgetsBindingObserver {
  final appShortcutsManager = getIt<AppShortcutsManager>();
  final themeManager = getIt<ThemeManager>();
  final permissionService = getIt<PermissionService>();
  final settingsManager = getIt<SettingsManager>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void pushAppSearch(ValueNotifierWithKey<AppInfo> specialAppNotifier) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => Scaffold(
                  body: SafeArea(
                      child: AppSearchFragment(
                appSearchMode: AppSearchMode.chooseSpecialShortcut,
                specialShortcutAppNotifier: specialAppNotifier,
              )))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        themeManager.toggleTheme();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, ROW_PADDING_RIGHT, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Strings.settingsTitle, style: TEXT_STYLE_TITLE),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        /// SET DEFAULT LAUNCHER
                        TextButton(
                          onPressed: () {
                            settingsManager.openDefaultLauncherSettings();
                          },
                          child: const Text(
                            Strings.settingsChangeDefaultLauncher,
                            style: TEXT_STYLE_ITEMS,
                          ),
                        ),

                        /// LIGHT COLOR / DARK COLOR
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ColorPickerDialog(changeDarkModeColor: false);
                                  },
                                );
                              },
                              child: const Text(
                                Strings.settingsLightColor,
                                style: TEXT_STYLE_ITEMS,
                              ),
                            ),
                            // Expanded(child: Container()),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ColorPickerDialog(changeDarkModeColor: true);
                                    });
                              },
                              child: const Text(
                                Strings.settingsDarkColor,
                                style: TEXT_STYLE_ITEMS,
                              ),
                            ),
                          ],
                        ),

                        /// APPS NUMBER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                settingsManager.setNotifierValueAndSave(settingsManager.numberOfShortcutItemsNotifier);
                              },
                              child: const Text(
                                Strings.settingsAppNumber,
                                style: TEXT_STYLE_ITEMS,
                              ),
                            ),
                            Expanded(child: Container()),
                            ValueListenableBuilder<int>(
                                valueListenable: settingsManager.numberOfShortcutItemsNotifier,
                                builder: (context, numOfShortcutItems, child) {
                                  return SizedBox(
                                      width: 86,
                                      child: TextButton(
                                        onPressed: () {
                                          settingsManager
                                              .setNotifierValueAndSave(settingsManager.numberOfShortcutItemsNotifier);
                                        },
                                        child:
                                            Center(child: Text(numOfShortcutItems.toString(), style: TEXT_STYLE_ITEMS)),
                                      ));
                                }),
                          ],
                        ),

                        /// CLOCK APP
                        Row(
                          children: [
                            TextButton(
                                onLongPress: () {},
                                onPressed: () {
                                  pushAppSearch(appShortcutsManager.clockAppNotifier);
                                },
                                child: const Text(
                                  Strings.settingsClockApp,
                                  style: TEXT_STYLE_ITEMS,
                                )),
                            Expanded(child: Container(),),
                            ShowHideButton(
                              notifier: settingsManager.clockWidgetEnabledNotifier,
                              onPressed: () {
                                settingsManager.setNotifierValueAndSave(settingsManager.clockWidgetEnabledNotifier);
                              },
                            ),
                          ],
                        ),

                        /// WEATHER APP
                        Row(
                          children: [
                            TextButton(
                                onLongPress: () {},
                                onPressed: () {
                                  pushAppSearch(appShortcutsManager.weatherAppNotifier);
                                },
                                child: const Text(
                                  Strings.settingsWeatherApp,
                                  style: TEXT_STYLE_ITEMS,
                                )),
                            Expanded(child: Container()),
                            ShowHideButton(
                              notifier: settingsManager.weatherWidgetEnabledNotifier,
                              onPressed: () {
                                settingsManager.setNotifierValueAndSave(settingsManager.weatherWidgetEnabledNotifier);
                              },
                            ),
                          ],
                        ),

                        /// CALENDAR APP
                        Row(
                          children: [
                            TextButton(
                              onLongPress: () {},
                              onPressed: () {
                                pushAppSearch(appShortcutsManager.calendarAppNotifier);
                              },
                              child: const Text(
                                Strings.settingsCalendarApp,
                                style: TEXT_STYLE_ITEMS,
                              ),
                            ),
                            Expanded(child: Container()),
                            ShowHideButton(
                              notifier: settingsManager.calendarWidgetEnabledNotifier,
                              onPressed: () {
                                settingsManager.setNotifierValueAndSave(settingsManager.calendarWidgetEnabledNotifier);
                              },
                            ),
                          ],
                        ),

                        /// BATTERY
                        Row(
                          children: [
                            TextButton(
                                onLongPress: () {},
                                onPressed: () {
                                  pushAppSearch(appShortcutsManager.batteryAppNotifier);
                                },
                                child: const Text(
                                  Strings.settingsBattery,
                                  style: TEXT_STYLE_ITEMS,
                                )),
                            Expanded(child: Container(),),
                            ShowHideButton(
                              notifier: settingsManager.batteryWidgetEnabledNotifier,
                              onPressed: () {
                                settingsManager.setNotifierValueAndSave(settingsManager.batteryWidgetEnabledNotifier);
                              },
                            ),
                          ],
                        ),

                        /// SWIPE LEFT
                        TextButton(
                            onLongPress: () {},
                            onPressed: () {
                              pushAppSearch(appShortcutsManager.swipeLeftAppNotifier);
                            },
                            child: const Text(
                              Strings.settingsSwipeLeft,
                              style: TEXT_STYLE_ITEMS,
                            )),

                        /// SWIPE RIGHT
                        TextButton(
                            onLongPress: () {},
                            onPressed: () {
                              pushAppSearch(appShortcutsManager.swipeRightAppNotifier);
                            },
                            child: const Text(
                              Strings.settingsSwipeRight,
                              style: TEXT_STYLE_ITEMS,
                            )),

                        /// HIDDEN APPS
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HiddenApps()),
                              );
                            },
                            child: const Text(
                              Strings.settingsHiddenApps,
                              style: TEXT_STYLE_ITEMS,
                            )),

                        /// SET API KEY
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Credits()),
                            );
                          },
                          child: const Text(
                            Strings.settingsCredits,
                            style: TEXT_STYLE_ITEMS,
                          ),
                        ),
                      ]),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowHideButton extends StatelessWidget {
  const ShowHideButton({Key? key, required this.notifier, required this.onPressed}) : super(key: key);

  final ValueNotifierWithKey<bool> notifier;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPressed();
      },
      child: ValueListenableBuilder<bool>(
          valueListenable: notifier,
          builder: (context, enabled, child) {
            return SizedBox(
              width: 70,
              child: Center(
                child: Text(
                  enabled ? "hide" : "show",
                  style: TEXT_STYLE_ITEMS,
                ),
              ),
            );
          }),
    );
  }
}
