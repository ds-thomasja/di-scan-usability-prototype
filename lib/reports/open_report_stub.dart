/// No-op stand-in for `OpenReport` on non-web targets.
///
/// Reached only by `flutter test` on the Dart VM — the prototype itself is
/// built for web, where `open_report_web.dart` applies instead.
abstract final class OpenReport {
  /// Does nothing: there is no browser tab to open off the web.
  static void open() {}
}

/// No-op stand-in for `OpenAttachment` on non-web targets.
///
/// Reached only by `flutter test` on the Dart VM — the prototype itself is
/// built for web, where `open_report_web.dart` applies instead.
abstract final class OpenAttachment {
  /// Does nothing: there is no browser tab to open off the web.
  static void open() {}
}
