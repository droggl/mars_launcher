
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mars_launcher/data/app_info.dart';
import 'package:flutter_mars_launcher/global.dart';

class AppsManager {
  final appsNotifier = ValueNotifier<List<AppInfo>>([]);
  bool currentlySyncing = false;

  AppsManager() {
    print("INITIALISING AppsManager");
    syncInstalledApps();
    DeviceApps.listenToAppsChanges().where((event) => event.event != ApplicationEventType.updated).listen((event) {handleAppEvent(event);});
  }

  handleAppEvent(ApplicationEvent event) async {
    print("Received app event: ${event.event}, packageName: ${event.packageName}");
    if (!currentlySyncing) {
      currentlySyncing = true;
      await syncInstalledApps();
      currentlySyncing = false;
    }
  }

  syncInstalledApps() async {
    final stopwatch = Stopwatch()..start();
    List<Application> applications = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );

    List<AppInfo> apps = [];
    for (var app in applications) {
      if (IGNORED_APPS.contains(app.packageName)) {
        continue;
      }
      apps.add(AppInfo(
          packageName: app.packageName,
          appName: app.appName,
          systemApp: app.systemApp));
    }
    apps.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    appsNotifier.value = apps;
    print('syncInstalledApps() executed in ${stopwatch.elapsed.inMilliseconds}ms');
  }
}
