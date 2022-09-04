import 'dart:core' as core;
import 'package:flutter/foundation.dart';
import 'dart:core';

class Debug {
  static bool? isDevelopment;

  static void print(dynamic statement) {
    if (isDevelopment!) {
      if (kDebugMode) {
        core.print(statement);
      }
    }
  }
}
