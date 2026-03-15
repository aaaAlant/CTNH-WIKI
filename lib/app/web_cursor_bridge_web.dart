import 'dart:js_interop';

@JS('setAppCursorTheme')
external void _setAppCursorTheme(String themeName);

void setAppCursorTheme(String themeName) {
  _setAppCursorTheme(themeName);
}
