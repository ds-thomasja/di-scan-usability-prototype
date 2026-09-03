import 'package:web/web.dart' as web;

/// A full browser reload back to the prototype's start.
///
/// Deliberately heavier than a `context.go` to the home route: reloading
/// rebuilds the whole app, so nothing the previous participant touched
/// survives — not the navigation stack, not the collapsed state of the main
/// menu that `DSScaffoldPersistentStateProvider` keeps above the router, not
/// any page state below it.
abstract final class PrototypeRestart {
  /// Reloads the document at the app's own URL, minus the route fragment.
  ///
  /// The prototype uses go_router's default hash URLs, so the route lives in
  /// the fragment and the path is just wherever the app is hosted (`/` when
  /// run locally, `/di-scan-usability-prototype/` on GitHub Pages) — which
  /// makes dropping the fragment enough to land back on `initialLocation`.
  ///
  /// Dropping it rather than setting it to the start route is also what makes
  /// this a *reload*: a navigation whose target URL has no fragment is a real
  /// document load, where one that differs only in its fragment would be an
  /// in-page jump and reload nothing.
  ///
  /// [web.Location.replace] rather than `assign`, so the abandoned run does
  /// not sit in the Back history waiting to be stumbled into.
  static void restart() {
    final web.Location location = web.window.location;
    location.replace('${location.pathname}${location.search}');
  }
}
