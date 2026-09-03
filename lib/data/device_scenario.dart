/// Which [Device] list `showCaptureScanModal`'s "Select device" modal
/// renders.
///
/// [StartMenuPage]'s two scenario rows — "Scans" and "Notifikationen" — lead
/// through the exact same dashboard → patient/treatment → "Capture scan"
/// screens; only the devices and states the final modal shows differ. Rather
/// than thread a parameter through every one of those intermediate screens,
/// the row picks the scenario once via [DeviceScenarioState] before
/// navigating, and `showCaptureScanModal` reads it when the modal eventually
/// opens.
enum DeviceScenario {
  /// [MockData.devices]: the "Scans" scenario's plain availability states —
  /// online, in use, or reporting warnings.
  scans,

  /// [MockData.notificationDevices]: the "Notifikationen" scenario's outdated
  /// calibration/firmware notifications on otherwise-online scanners.
  notifications,
}

/// Ambient scenario selection; see [DeviceScenario].
///
/// A plain mutable static rather than a `ChangeNotifier`: nothing needs to
/// rebuild when it changes, since it is only ever read once, at the moment
/// the "Select device" modal is built.
class DeviceScenarioState {
  DeviceScenarioState._();

  /// The active scenario, defaulting to [DeviceScenario.scans] — the
  /// prototype's state before either start-menu row has been picked.
  static DeviceScenario current = DeviceScenario.scans;
}
