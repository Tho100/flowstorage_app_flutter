import 'package:flutter/services.dart';

class SystemToggle {

  void toPortraitMode() {
    toggleStatusBarVisibility(true);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void toLandscapeMode() {
    toggleStatusBarVisibility(false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void toggleStatusBarVisibility(bool visible) {
    visible 
      ? SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom])
      : SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

}