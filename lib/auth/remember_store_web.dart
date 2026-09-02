import 'package:web/web.dart' as web;

/// `localStorage`-backed persistence for the "stay unlocked" flag.
///
/// Only the fact that the gate was passed is stored — never the password
/// itself, which stays a compile-time constant in `AuthState`.
abstract final class RememberStore {
  /// The `localStorage` key holding the unlock marker.
  ///
  /// Version-suffixed on purpose: bumping the suffix (for instance after
  /// changing the prototype password) forces every browser that remembered
  /// the old one back through the gate.
  static const String _key = 'di-scan.unlocked.v1';

  /// Whether this browser has a stored unlock.
  ///
  /// Browsers *throw* on `localStorage` access when site data is blocked
  /// (private windows, strict cookie settings) rather than returning null, so
  /// the read is guarded: a storage failure means "not remembered" and must
  /// never keep the prototype from starting.
  static bool read() {
    try {
      return web.window.localStorage.getItem(_key) == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Stores the unlock marker when [remembered], clears it otherwise.
  static void write(bool remembered) {
    try {
      if (remembered) {
        web.window.localStorage.setItem(_key, 'true');
      } else {
        web.window.localStorage.removeItem(_key);
      }
    } catch (_) {
      // Nothing to recover: the prototype just asks for the password again
      // on the next load.
    }
  }
}
