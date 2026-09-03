/// A restart of the whole prototype, for the facilitator between participants.
///
/// The prototype only ever ships for web, but `flutter test` runs on the Dart
/// VM, where `package:web` cannot be compiled. Hence the configurable export —
/// the same arrangement as `lib/auth/remember_store.dart`: the real
/// `location`-backed reload on web, a no-op stub everywhere else.
library;

export 'prototype_restart_stub.dart'
    if (dart.library.js_interop) 'prototype_restart_web.dart';
