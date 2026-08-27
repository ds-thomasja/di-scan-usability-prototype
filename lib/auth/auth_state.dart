import 'package:flutter/foundation.dart';

/// Client-side only "authentication" for the usability-test prototype.
///
/// This is not real security: the password is hardcoded in the compiled
/// bundle. It only exists to keep casual visitors from wandering into the
/// prototype while it's shared for testing.
class AuthState extends ChangeNotifier {
  AuthState._();

  static final AuthState instance = AuthState._();

  static const String _password = 'diScan2026';

  bool _unlocked = false;

  bool get isUnlocked => _unlocked;

  /// Returns true if [attempt] matches the prototype password.
  bool tryUnlock(String attempt) {
    if (attempt == _password) {
      _unlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }
}
