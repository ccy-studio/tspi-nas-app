import "package:event_bus/event_bus.dart";
import "package:flutter/material.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:tspi_nas_app/config/theme_data.dart" as tdr;
import "package:tspi_nas_app/utils/file_downloader_util.dart";
import "package:tspi_nas_app/utils/sp_util.dart";

class Application {
  static String BASE_URL = "";

  static final EventBus globalEventBus = EventBus();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => rootNavigatorKey.currentContext;

  static bool _isInstall = false;

  static void applicationInstall(BuildContext context) {
    if (_isInstall) {
      return;
    }
    _isInstall = true;
    tdr.register();
    SpUtil.getBaseUrl().then((value) => BASE_URL = value ?? "");

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.wave
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorColor = Theme.of(context).primaryColor
      ..maskType = EasyLoadingMaskType.custom
      ..backgroundColor = Colors.white
      ..maskColor = Colors.black12
      ..progressColor = Colors.blueAccent
      ..progressWidth = 2
      ..textColor = Theme.of(context).primaryColor;
  }
}
