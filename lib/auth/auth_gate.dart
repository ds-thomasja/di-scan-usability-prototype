import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import 'auth_state.dart';

/// The password gate shown at `/`.
///
/// This is *not* real authentication — see [AuthState]. It only keeps casual
/// visitors out of the shared usability-test prototype.
///
/// On success it calls [AuthState.tryUnlock] and navigates to
/// [AppRoutes.home]. The router's redirect would do the same on its own
/// (via `refreshListenable`), but navigating explicitly keeps the flow
/// obvious.
class AuthGate extends StatefulWidget {
  /// Creates the password gate.
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// Max width of the login card.
  ///
  /// The DS token set has no "login card width" token, so this is a local
  /// layout constant rather than a hardcoded *visual* value (color, spacing,
  /// radius and typography all come from tokens).
  static const double _cardMaxWidth = 420;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _fieldFocusNode = FocusNode();

  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    // Frontend validation before doing anything else: reject empty input
    // without pretending it was a wrong password.
    final String attempt = _controller.text.trim();
    if (attempt.isEmpty) {
      setState(() => _hasError = true);
      _fieldFocusNode.requestFocus();
      return;
    }

    if (AuthState.instance.tryUnlock(attempt)) {
      context.go(AppRoutes.home);
      return;
    }

    setState(() => _hasError = true);
    _fieldFocusNode.requestFocus();
  }

  void _clearError() {
    if (_hasError) setState(() => _hasError = false);
  }

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background.standard,
      body: SafeArea(
        child: DSResponsiveBody(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                child: DSContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DSText(
                        'DI Scan',
                        style: tokens.text.heading2xl,
                      ),
                      SizedBox(height: tokens.spacing.component.xxs),
                      DSText(
                        'Usability test prototype',
                        style: tokens.text.textSm
                            .copyWith(color: tokens.text.subdued),
                      ),
                      SizedBox(height: tokens.spacing.layout.s),
                      DSText(
                        'Password',
                        style: tokens.text.textSmStrong,
                      ),
                      SizedBox(height: tokens.spacing.component.xxs),
                      Semantics(
                        label: 'Prototype password',
                        textField: true,
                        child: DSPasswordField(
                          controller: _controller,
                          focusNode: _fieldFocusNode,
                          hintText: 'Enter password',
                          hasError: _hasError,
                          autofocus: true,
                          autofillHints: const [AutofillHints.password],
                          onChanged: (_) => _clearError(),
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      if (_hasError) ...[
                        SizedBox(height: tokens.spacing.component.xxs),
                        Semantics(
                          liveRegion: true,
                          child: DSText(
                            'Incorrect password. Please try again.',
                            maxLines: 2,
                            style: tokens.text.textSm
                                .copyWith(color: tokens.text.critical),
                          ),
                        ),
                      ],
                      SizedBox(height: tokens.spacing.layout.s),
                      DSButton.primary(
                        buttonText: 'Unlock',
                        stretch: true,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
