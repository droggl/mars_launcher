import 'package:flutter/material.dart';
import 'package:mars_launcher/global.dart';
import 'package:mars_launcher/logic/calendar_manager.dart';
import 'package:mars_launcher/logic/settings_manager.dart';
import 'package:mars_launcher/logic/shortcut_manager.dart';
import 'package:mars_launcher/pages/todo_list.dart';
import 'package:mars_launcher/services/service_locator.dart';
import 'package:mars_launcher/theme/theme_constants.dart';

class EventView extends StatefulWidget {
  const EventView({
    Key? key,
  }) : super(key: key);

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final appShortcutsManager = getIt<AppShortcutsManager>();
  final settingsLogic = getIt<SettingsManager>();
  final calenderLogic = CalenderManager();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: settingsLogic.weatherWidgetEnabledNotifier,
        builder: (context, isWeatherEnabled, child) {
          var letterLength = isWeatherEnabled ? 15 : 21;
          return Container(
            constraints: BoxConstraints(maxWidth: isWeatherEnabled ? 140 : 180),
            child: TextButton(
              onPressed: () {
                appShortcutsManager.calendarAppNotifier.value.open();
              },
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const TodoList()),
                );
              },
              child: ValueListenableBuilder<String>(
                  valueListenable: calenderLogic.eventNotifier,
                  builder: (context, event, child) {
                    return Text(
                      event.length > letterLength
                          ? ".." + event.substring(event.length - letterLength)
                          : event,
                      // calenderLogic.currentDate + "\n" + event,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: FONT_SIZE_EVENTS,
                        fontFamily: FONT_LIGHT,
                      ),
                    );
                  }),
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  // padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                  // minimumSize: Size(0, 25.0), // Adjust minimum height
                  alignment: Alignment.center,
                  // padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0), // Adjust padding
                  // minimumSize: Size(0, 10.0), // Adjust minimum height
              ),

              // ButtonStyle(
              //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              //     RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(
              //           5), // Adjust the radius to control the roundness
              //     ),
              //   ),
              //   backgroundColor:
              //       MaterialStateProperty.all<Color>(Colors.lightGreen),
              // ),
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
