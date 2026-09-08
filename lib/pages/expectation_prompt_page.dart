import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../restart/prototype_restart.dart';

/// The signpost the "Jetzt aktualisieren" link (on the outdated-firmware
/// device card of the "Notifikationen" scenario) leads to, shown at
/// [AppRoutes.expectationPrompt].
///
/// Same setup as [SwitchPrototypePage] — a centred heading on a white
/// surface, with the deck's footer along the bottom, and the facilitator's
/// invisible restart target in the top-left corner — but with a single
/// heading line and no subline: this page only asks the tester what they
/// would expect to happen next, rather than handing them to another
/// prototype window.
class ExpectationPromptPage extends StatelessWidget {
  /// Creates the "What would you expect?" prompt.
  const ExpectationPromptPage({super.key});

  /// Side margin of the copy block, matching the "Switch prototype" page.
  static const double _copyMargin = 64;

  /// Height of the footer logo, per the Figma node.
  static const double _logoHeight = 24;

  /// Side of the invisible square in the top-left corner that restarts the
  /// prototype, matching the "Switch prototype" page.
  static const double _restartTargetSize = 96;

  /// The month of the test session, as the Figma footer states it.
  static const String _footerDate = 'September 2026';

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.surface.standard,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _copyMargin),
                child: DSText(
                  'What would you expect?',
                  style: tokens.text.heading5xl,
                  textAlign: TextAlign.center,
                  maxLines: null,
                ),
              ),
            ),
            // Above the copy in the stack so a corner tap reaches it even
            // once the heading wraps far enough to overlap the square.
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: PrototypeRestart.restart,
                child: const SizedBox.square(dimension: _restartTargetSize),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: tokens.spacing.layout.m,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing.component.xl,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: tokens.spacing.component.m,
                      ),
                      child: DSText(
                        _footerDate,
                        style: tokens.text.textLg
                            .copyWith(color: tokens.text.disabled),
                      ),
                    ),
                    Image.asset(
                      'assets/images/Logo-DS-light-default.png',
                      package: 'lightning_core_ui',
                      height: _logoHeight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
