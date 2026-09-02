import 'package:flutter/foundation.dart';

import 'remember_store.dart';

/// Client-side only "authentication" for the usability-test prototype.
///
/// This is not real security: the password is hardcoded in the compiled
/// bundle. It only exists to keep casual visitors from wandering into the
/// prototype while it's shared for testing.
class AuthState extends ChangeNotifier {
  /// Restores a previously remembered unlock, so a reload skips the gate.
  AuthState._() : _unlocked = RememberStore.read();

  static final AuthState instance = AuthState._();

  static const String _password = 'diScan2026';

  bool _unlocked;

  bool get isUnlocked => _unlocked;

  /// Returns true if [attempt] matches the prototype password.
  ///
  /// When [remember] is true the unlock is persisted for this browser and
  /// subsequent reloads land straight on the home page; when false it lasts
  /// only for the current page load.
  bool tryUnlock(String attempt, {required bool remember}) {
    if (attempt != _password) return false;

    _unlocked = true;
    RememberStore.write(remember);
    notifyListeners();
    return true;
  }

  /// Locks the prototype again and forgets any persisted unlock.
  ///
  /// Not wired to any button — the prototype has no sign-out in the Figma
  /// reference. It exists so a fresh gate can be forced between usability-test
  /// participants without clearing site data by hand.
  void lock() {
    _unlocked = false;
    RememberStore.write(false);
    notifyListeners();
  }
}
