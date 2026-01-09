import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void log(String message) {
    debugPrint('[App] $message');
  }

  static void error(String message) {
    debugPrint('[App][ERROR] $message');
  }
}
