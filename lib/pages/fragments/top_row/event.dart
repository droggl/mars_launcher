
import 'package:flutter/material.dart';
import 'package:mars_launcher/logic/calendar_logic.dart';
import 'package:mars_launcher/logic/settings_logic.dart';
import 'package:mars_launcher/logic/shortcut_logic.dart';
import 'package:mars_launcher/logic/theme_logic.dart';
import 'package:mars_launcher/services/service_locator.dart';


class EventView extends StatefulWidget {
  const EventView({
    Key? key,
  }) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final appShortcutsManager = getIt<AppShortcutsManager>();
  final settingsLogic = getIt<SettingsLogic>();
  final calenderLogic = CalenderLogic();
  final themeManager = getIt<ThemeManager>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: settingsLogic.weatherEnabledNotifier,
        builder: (context, isWeatherEnabled, child) {
          var letterLength = isWeatherEnabled ? 15 : 21;
          return Container(
            constraints: BoxConstraints(maxWidth: isWeatherEnabled ? 140 : 180),
            child: TextButton(
              onPressed: () {
                appShortcutsManager.calendarAppNotifier.value.open();
              },
              onLongPress: () async {
                /*var time = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.,
                  helpText: "Create a new event",
                  builder: (context, child) {
                    return Theme(
                      data: themeManager.themeModeNotifier.value ? ThemeData.dark() : ThemeData.light(),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  // FlutterAlarmClock.createAlarm(time.hour, time.minute);
                }*/
                // TODO create new event
              },
              child: ValueListenableBuilder<String>(
                  valueListenable: calenderLogic.eventNotifier,
                  builder: (context, event, child) {
                    return Text(
                      event.length > letterLength
                          ? ".." + event.substring(event.length - letterLength)
                          : event,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    );
                  }),
            ),
          );
        });
  }

  @override
  void dispose() {
    calenderLogic.stopTimer();
    super.dispose();
  }
}
