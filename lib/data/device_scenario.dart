/// Which [Device] list `showCaptureScanModal`'s "Select device" modal
/// renders, and which mock patient data [MockData] hands out for patient
/// `p1` (Izzy Castaneda) — see [MockData.patientById].
///
/// [StartMenuPage]'s scenario rows — "Scan exklusiv", "Scan inklusiv" and
/// "Szenario 4" — lead through the exact same dashboard → patient/treatment →
/// "Capture scan" screens; only the devices, states and (for Izzy Castaneda)
/// patient data the rest of the flow shows differ. Rather than thread a
/// parameter through every one of those intermediate screens, the row picks
/// the scenario once via [DeviceScenarioState] before navigating, and the
/// screens that care read it when they eventually build.
enum DeviceScenario {
  /// "Scan exklusiv": reuses [MockData.devices] for the device list. Izzy
  /// Castaneda has no media and no treatments in this scenario.
  exclusive,

  /// [MockData.devices]: the "Scan inklusiv" scenario's plain availability
  /// states — online, in use, or reporting warnings. Izzy Castaneda has one
  /// status scan in her media in this scenario.
  scans,

  /// [MockData.notificationDevices]: the "Szenario 4" scenario's outdated
  /// calibration/firmware notifications on otherwise-online scanners.
  notifications,
}

/// Ambient scenario selection; see [DeviceScenario].
///
/// A plain mutable static rather than a `ChangeNotifier`: nothing needs to
/// rebuild when it changes, since it is only ever read once per screen, at
/// the moment that screen's scenario-dependent content is built.
class DeviceScenarioState {
  DeviceScenarioState._();

  /// The active scenario, defaulting to [DeviceScenario.scans] — the
  /// prototype's state before any start-menu row has been picked.
  static DeviceScenario current = DeviceScenario.scans;
}
