import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../components/application_loading/application_loading.dart';

/// The wait after picking "Status scan" in the "Select device" modal, shown at
/// [AppRoutes.scanLoading].
///
/// Plays the two Figma frames of that wait in sequence, then leaves for
/// [AppRoutes.switchPrototype]:
///
/// - node `40601-127415` — nothing but a small spinner on the standard
///   background, the browser-level wait before the scan application paints
///   anything ([_Phase.booting]);
/// - node `40184-47635` — the application's own loading screen, whose
///   two-step timeline card advances once
///   ([_Phase.preparingWorkspace] → [_Phase.startingApplication]).
///
/// The phases are on timers rather than driven by anything real: there is no
/// scan application behind this prototype, and the point of the screen in the
/// test session is that the tester sees the wait the design describes.
///
/// The treatment-scan flow actually has data to fetch — the treatment just
/// created, and the reference scan picked for it — so it runs a third step,
/// "Fetch scan data", between [_Phase.preparingWorkspace] and
/// [_Phase.startingApplication]. Set [includeFetchScanData] for that flow;
/// the status-scan flow leaves it off, since a status scan starts from
/// nothing.
class ScanLoadingPage extends StatefulWidget {
  /// Creates the scan loading page.
  const ScanLoadingPage({this.includeFetchScanData = false, super.key});

  /// Whether to run the "Fetch scan data" step. See the class doc.
  final bool includeFetchScanData;

  @override
  State<ScanLoadingPage> createState() => _ScanLoadingPageState();
}

/// The phases of the load, in the order they play.
enum _Phase {
  /// Figma node `40601-127415`: the bare spinner.
  booting,

  /// Figma node `40184-47635`: "Preparing workspace…" is the active step.
  preparingWorkspace,

  /// "Fetch scan data" advanced to active. Only reached when
  /// [ScanLoadingPage.includeFetchScanData] is set.
  fetchingScanData,

  /// The same screen with "Start application" advanced to active.
  startingApplication,
}

class _ScanLoadingPageState extends State<ScanLoadingPage> {
  /// How long the bare spinner is shown before the loading screen appears.
  static const Duration _bootingDuration = Duration(seconds: 2);

  /// How long each of the loading screen's steps stays active.
  static const Duration _preparingDuration = Duration(seconds: 2);
  static const Duration _fetchingDuration = Duration(seconds: 2);
  static const Duration _startingDuration = Duration(seconds: 2);

  /// The pause once "Start application" has run its course and the load is
  /// done, before the page leaves. Without it the last step's active state is
  /// replaced the instant it is reached, which reads as a skipped step.
  static const Duration _readyHold = Duration(milliseconds: 800);

  /// The scheduled phase changes, kept so they can be cancelled — both by
  /// [dispose] and by "Cancel loading" leaving the page early.
  final List<Timer> _timers = [];

  _Phase _phase = _Phase.booting;

  @override
  void initState() {
    super.initState();
    _after(_bootingDuration, () => _enter(_Phase.preparingWorkspace));

    // The fetch step only exists on the treatment-scan flow; skipping it here
    // means [_Phase.fetchingScanData] is simply never entered on the
    // status-scan flow, rather than needing a second, near-identical
    // schedule.
    Duration untilStartingApplication =
        _bootingDuration + _preparingDuration;
    if (widget.includeFetchScanData) {
      _after(untilStartingApplication, () => _enter(_Phase.fetchingScanData));
      untilStartingApplication += _fetchingDuration;
    }
    _after(
      untilStartingApplication,
      () => _enter(_Phase.startingApplication),
    );
    _after(
      untilStartingApplication + _startingDuration + _readyHold,
      _finish,
    );
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _after(Duration delay, VoidCallback action) =>
      _timers.add(Timer(delay, action));

  void _enter(_Phase phase) => setState(() => _phase = phase);

  /// Leaves for the "Switch prototype" signpost once the load is done.
  ///
  /// [GoRouter.pushReplacement] rather than `go`: it takes this page off the
  /// stack but leaves the page the scan was started from underneath, so the
  /// browser's Back button still gets a facilitator out of the signpost.
  void _finish() => context.pushReplacement(AppRoutes.switchPrototype);

  /// Returns to the page the scan was started from, per the component's spec
  /// for "Cancel loading".
  ///
  /// That page is the one this route was pushed on top of. There is nothing
  /// beneath it after a browser reload on this URL, though, so fall back to
  /// home rather than leaving the tester stuck on a cancelled load.
  void _cancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  /// The steps of Figma node `40184-47635`, typed for [phase] — two of them,
  /// or three when [ScanLoadingPage.includeFetchScanData] is set.
  List<DSTimelineStep> _steps(_Phase phase) {
    DSTimelineStepType typeFor(_Phase reachedAt) {
      if (phase.index < reachedAt.index) return DSTimelineStepType.future;
      if (phase.index == reachedAt.index) return DSTimelineStepType.active;
      return DSTimelineStepType.completed;
    }

    return [
      loadingStep(
        typeFor(_Phase.preparingWorkspace),
        'Arbeitsbereich wird vorbereitet…',
      ),
      if (widget.includeFetchScanData)
        loadingStep(typeFor(_Phase.fetchingScanData), 'Scandaten abrufen'),
      loadingStep(typeFor(_Phase.startingApplication), 'Anwendung starten'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return Scaffold(
      // The same colour [ApplicationLoading] paints, so that the rounded
      // corners it clips itself to are invisible against this full-screen
      // background rather than showing four notches.
      backgroundColor: tokens.background.standard,
      body: SafeArea(
        child: ApplicationLoading(
          appReady: _phase != _Phase.booting,
          // Figma node `40184-47635` shows the subline and the timeline card
          // and no notification: this load is not one of the slow ones the
          // notification exists for.
          notification: false,
          steps: _steps(_phase),
          onCancel: _cancel,
        ),
      ),
    );
  }
}
