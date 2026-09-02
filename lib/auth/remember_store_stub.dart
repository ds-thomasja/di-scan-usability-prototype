/// No-op stand-in for [RememberStore] on non-web targets.
///
/// Reached only by `flutter test` on the Dart VM — the prototype itself is
/// built for web, where `remember_store_web.dart` applies instead.
abstract final class RememberStore {
  /// Always false: there is nowhere to persist to off the web.
  static bool read() => false;

  /// Discards [remembered].
  static void write(bool remembered) {}
}
