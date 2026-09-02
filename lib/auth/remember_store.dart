/// Persistence for the prototype's "stay unlocked" flag.
///
/// The prototype only ever ships for web, but `flutter test` runs on the Dart
/// VM, where `package:web` cannot be compiled. Hence the configurable export:
/// the real `localStorage` implementation on web, a no-op stub everywhere
/// else.
library;

export 'remember_store_stub.dart'
    if (dart.library.js_interop) 'remember_store_web.dart';
