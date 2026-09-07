/// Opens the troubleshoot report PDF, and the troubleshooting-notification
/// attachment, each in its own new browser tab.
///
/// The prototype only ever ships for web, but `flutter test` runs on the Dart
/// VM, where `package:web` cannot be compiled. Hence the configurable export —
/// the same arrangement as `lib/restart/prototype_restart.dart`: the real
/// `window.open`-backed navigation on web, a no-op stub everywhere else.
library;

export 'open_report_stub.dart' if (dart.library.js_interop) 'open_report_web.dart';
