import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../restart/prototype_restart.dart';

/// The signpost the status-scan flow ends on, shown at
/// [AppRoutes.switchPrototype].
///
/// Matches Figma node `40255-18049` ("Prototype | Midway Interview"): a
/// centred heading and subline on a white surface, with the deck's footer
/// along the bottom. It hands the tester over to the second browser window
/// where the scanning workflow itself is prototyped, so it deliberately has
/// no actions of its own for the tester — the way out is the other window, or
/// the facilitator.
///
/// The facilitator's way out is the invisible target in the top-left corner:
/// tapping it reloads the prototype from scratch, ready for the next
/// participant. See [_restartTargetSize] and [PrototypeRestart].
class SwitchPrototypePage extends StatelessWidget {
  /// Creates the "Switch prototype" signpost.
  const SwitchPrototypePage({super.key});

  /// Side margin of the copy block: the Figma frame gives it 1472 of its
  /// 1600 width. The DS token set has no 64 spacing token, so this is a local
  /// layout constant rather than a hardcoded *visual* value.
  static const double _copyMargin = 64;

  /// Height of the footer logo, per the Figma node.
  static const double _logoHeight = 24;

  /// Side of the invisible square in the top-left corner that restarts the
  /// prototype.
  ///
  /// Not a Figma node: it is a facilitator affordance, deliberately unmarked
  /// so the tester does not find it looking for a way on. Big enough to hit
  /// without aiming, small enough to stay clear of the centred copy.
  static const double _restartTargetSize = 96;

  /// The month of the test session, as the Figma footer states it. A literal
  /// rather than a formatted `DateTime.now()`: it labels the design, not the
  /// day the prototype happens to be opened.
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DSText(
                      'Prototyp wechseln',
                      style: tokens.text.heading5xl,
                      textAlign: TextAlign.center,
                      // Both lines wrap rather than truncate: the frame fits
                      // them on one line each at 1600 wide, but the browser
                      // window in the session may well be narrower.
                      maxLines: null,
                    ),
                    SizedBox(height: tokens.spacing.component.l),
                    DSText(
                      'Setzen Sie den Scan-Workflow im anderen '
                      'Browserfenster fort',
                      style: tokens.text.heading3xl,
                      textAlign: TextAlign.center,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ),
            // Above the copy in the stack so a corner tap reaches it even
            // once the heading wraps far enough to overlap the square.
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                // Opaque, not the default `deferToChild`: the target is
                // painted nothing at all, and would otherwise not be hit.
                behavior: HitTestBehavior.opaque,
                // A browser reload rather than a route change, so that
                // nothing the participant touched carries over into the next
                // run — see [PrototypeRestart].
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
                    // The DS logo shipped by `lightning_core_ui`, which is the
                    // real asset in its resolution-aware variants; "light" is
                    // the light-background (dark ink) one. It is the wordmark
                    // beside the mark, so at the node's 24px height it comes
                    // out wider than the 79px the node shows — that is the
                    // node scaling its instance, and matching it would mean
                    // squashing the logo.
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
