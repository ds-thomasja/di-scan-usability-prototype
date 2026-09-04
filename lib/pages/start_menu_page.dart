import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../data/device_scenario.dart';

/// The screen the prototype opens on once unlocked, shown at
/// [AppRoutes.start].
///
/// Matches Figma node `40532-88315` ("Home"): the DS logo over a single
/// [DSContainer] holding one [DSListCustomItem] row per usability-test
/// scenario this session covers.
///
/// The "Scan exklusiv", "Scan inklusiv" and "Szenario 4" rows lead to the
/// exact same dashboard ([AppRoutes.home]) and the same patient/treatment
/// pages — they differ only in which [DeviceScenario] the rest of the flow
/// then reads: which device list a "Capture scan" button's "Select device"
/// modal shows, and (for patient Izzy Castaneda specifically) which mock
/// media [MockData.patientById] hands out. Picking one of those rows sets
/// [DeviceScenarioState.current] before navigating, so those later screens
/// can pick up the right data without the row needing to carry it any
/// further itself. The remaining rows ("Report", "Anhang") are placeholders
/// not wired to a scenario yet.
class StartMenuPage extends StatelessWidget {
  /// Creates the scenario picker.
  const StartMenuPage({super.key});

  /// Max width of the logo/card column, per the Figma frame.
  static const double _maxWidth = 400;

  /// Size of the DS logo, per the Figma node.
  ///
  /// The packaged asset's canvas has transparent padding to the right of
  /// the wordmark (its intrinsic aspect ratio is ~6.2:1, not the ~3.3:1 the
  /// visible logo mark actually has), so sizing it by [_logoHeight] alone
  /// renders it far wider than the design and shifts the visible mark left
  /// of center. Cropping to both dimensions below via [FittedBox.fitHeight]
  /// keeps the mark itself at the Figma-specified size.
  static const double _logoWidth = 158;
  static const double _logoHeight = 48;

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background.standard,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRect(
                      child: SizedBox(
                        width: _logoWidth,
                        height: _logoHeight,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/images/Logo-DS-light-default.png',
                            package: 'lightning_core_ui',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spacing.layout.l),
                  DSContainer(
                    child: DSList<DSListCustomItem>(
                      // Unbounded ancestor (a `SingleChildScrollView`, so the
                      // whole card scrolls with the logo above it on short
                      // viewports) rather than the sliver-based scaffold the
                      // dashboard's lists sit in, so the list has to size
                      // itself to its rows instead of expecting a bounded
                      // height to fill.
                      shrinkWrap: true,
                      items: [
                        DSListCustomItem(
                          header: 'Scan exklusiv',
                          body: const SizedBox.shrink(),
                          onPressed: () => _openScenario(
                            context,
                            DeviceScenario.exclusive,
                          ),
                        ),
                        DSListCustomItem(
                          header: 'Scan inklusiv',
                          body: const SizedBox.shrink(),
                          onPressed: () => _openScenario(
                            context,
                            DeviceScenario.scans,
                          ),
                        ),
                        DSListCustomItem(
                          header: 'Szenario 4',
                          body: const SizedBox.shrink(),
                          onPressed: () => _openScenario(
                            context,
                            DeviceScenario.notifications,
                          ),
                        ),
                        DSListCustomItem(
                          header: 'Report',
                          body: const SizedBox.shrink(),
                        ),
                        DSListCustomItem(
                          header: 'Anhang',
                          body: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sets [DeviceScenarioState.current] to [scenario] and goes to the
/// dashboard; shared by both [StartMenuPage] rows' press and chevron
/// callbacks.
void _openScenario(BuildContext context, DeviceScenario scenario) {
  DeviceScenarioState.current = scenario;
  context.go(AppRoutes.home);
}
