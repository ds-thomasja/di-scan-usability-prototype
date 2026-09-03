/// No-op stand-in for `PrototypeRestart` on non-web targets.
///
/// Reached only by `flutter test` on the Dart VM — the prototype itself is
/// built for web, where `prototype_restart_web.dart` applies instead.
abstract final class PrototypeRestart {
  /// Does nothing: there is no browser document to reload off the web.
  static void restart() {}
}
