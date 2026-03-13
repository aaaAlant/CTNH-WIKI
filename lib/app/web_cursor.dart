import 'dart:js_interop';

import 'package:ctnh_wiki/features/home/models/home_module.dart';

@JS('setAppCursorTheme')
external void _setAppCursorTheme(String themeName);

class WebCursorController {
  const WebCursorController._();

  static const HomeCursorTheme defaultTheme = HomeCursorTheme.tech;

  static void setTheme(HomeCursorTheme theme) {
    _setAppCursorTheme(_themeName(theme));
  }

  static String _themeName(HomeCursorTheme theme) {
    switch (theme) {
      case HomeCursorTheme.tech:
        return 'tech';
      case HomeCursorTheme.magic:
        return 'magic';
      case HomeCursorTheme.adventure:
        return 'adventure';
    }
  }
}
