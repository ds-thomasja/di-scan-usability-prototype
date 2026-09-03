import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../data/device_scenario.dart';

/// The screen the prototype opens on once unlocked, shown at
/// [AppRoutes.start].
///
/// Matches Figma node `40532-88315` ("Home"): the DS logo over a single
/// [DSContainer] holding one [DSListTextItem] row per usability-test scenario
/// this session covers.
///
/// Both rows lead to the exact same dashboard ([AppRoutes.home]), from which
/// the status/treatment-scan flow they describe is reachable via a patient's
/// or treatment's "Capture scan" button — they differ only in which
/// [DeviceScenario] that button's "Select device" modal ends up showing.
/// Picking a row sets [DeviceScenarioState.current] before navigating, so
/// `showCaptureScanModal` (see `lib/flows/capture_scan.dart`) can pick up the
/// right device list without either row needing to carry it any further
/// itself.
class StartMenuPage extends StatelessWidget {
  /// Creates the scenario picker.
  const StartMenuPage({super.key});

  /// Max width of the logo/card column, per the Figma frame.
  static const double _maxWidth = 400;

  /// Height of the DS logo, per the Figma node.
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
                    child: Image.asset(
                      'assets/images/Logo-DS-light-default.png',
                      package: 'lightning_core_ui',
                      height: _logoHeight,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.layout.l),
                  DSContainer(
                    child: DSList<DSListTextItem>(
                      // Unbounded ancestor (a `SingleChildScrollView`, so the
                      // whole card scrolls with the logo above it on short
                      // viewports) rather than the sliver-based scaffold the
                      // dashboard's lists sit in, so the list has to size
                      // itself to its two rows instead of expecting a bounded
                      // height to fill.
                      shrinkWrap: true,
                      items: [
                        DSListTextItem(
                          header: 'Scans',
                          body: 'Die Nutzerschaft kann Status- und '
                              'Treatment-Scans ohne Fehler durchführen.',
                          onPressed: () => _openScenario(
                            context,
                            DeviceScenario.scans,
                          ),
                          actions: [
                            DSAction(
                              title: 'Öffnen',
                              icon: DSIcons.chevronRight,
                              onTrigger: () => _openScenario(
                                context,
                                DeviceScenario.scans,
                              ),
                            ),
                          ],
                        ),
                        DSListTextItem(
                          header: 'Notifikationen',
                          body: 'Bei der Auswahl der Scanner werden '
                              'Notifikationen zu veralteten Kalibrierungen '
                              'und Firmware Updates gezeigt.',
                          onPressed: () => _openScenario(
                            context,
                            DeviceScenario.notifications,
                          ),
                          actions: [
                            DSAction(
                              title: 'Öffnen',
                              icon: DSIcons.chevronRight,
                              onTrigger: () => _openScenario(
                                context,
                                DeviceScenario.notifications,
                              ),
                            ),
                          ],
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
