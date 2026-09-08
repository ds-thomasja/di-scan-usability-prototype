import 'package:web/web.dart' as web;

/// Opens the troubleshoot report in a new browser tab.
abstract final class OpenReport {
  /// The PDF's path, served as-is from `web/documents/` (not a Flutter
  /// asset), so it is not routed through the Flutter asset bundle.
  ///
  /// Relative rather than root-absolute, so it resolves against the page's
  /// `<base href>` regardless of whether the prototype is served at `/`
  /// (locally) or a subpath (e.g. GitHub Pages) — the same base-href
  /// consideration `PrototypeRestart` accounts for.
  static const String _path = 'documents/Troubleshoot_Report.pdf';

  /// Opens the report PDF in a new tab, leaving the prototype where it was.
  static void open() {
    web.window.open(_path, '_blank');
  }
}

/// Opens the troubleshooting-notification attachment in the same browser tab.
abstract final class OpenAttachment {
  /// The click-through HTML page's path, served as-is from `web/documents/`
  /// alongside the two screenshots it swaps between, for the same
  /// base-href reasons as [OpenReport._path].
  static const String _path = 'documents/troubleshooting_notification.html';

  /// Navigates to the attachment in the current tab; the page's own
  /// top-left tap zone navigates back via browser history.
  static void open() {
    web.window.open(_path, '_self');
  }
}
