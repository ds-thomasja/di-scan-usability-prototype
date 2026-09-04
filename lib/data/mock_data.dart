import 'dart:math';

import 'device_scenario.dart';
import 'models.dart';

/// Fake data mirroring the sample names/IDs used in the Figma mockups.
/// This prototype contains no real patient information.
class MockData {
  MockData._();

  static final Random _random = Random();

  /// The DI scan renders the Media tab's tiles draw their image from.
  static const List<String> _mediaAssetPaths = [
    'assets/media/di_scan_1.png',
    'assets/media/di_scan_2.png',
    'assets/media/di_scan_3.png',
    'assets/media/di_scan_4.png',
    'assets/media/di_scan_5.png',
    'assets/media/di_scan_6.png',
  ];

  static const List<String> _mediaTitles = ['Status-Scan', 'Behandlungsscan'];

  static const List<String> _mediaTimestamps = [
    'Jetzt',
    'Vor 5 Minuten',
    'Vor 7 Minuten',
    '12.08.2025 um 09:39:43',
  ];

  /// Builds a random 1-5 item Media tab for a patient or treatment: every
  /// tile carries the "DI · 3" tag, a name of either "Status scan" or
  /// "Treatment scan", and one of the six DI scan renders — there is no real
  /// scan history behind this click-through prototype.
  static List<MediaItem> _randomMedia() => List.generate(
    1 + _random.nextInt(5),
    (_) => MediaItem(
      title: _mediaTitles[_random.nextInt(_mediaTitles.length)],
      timestamp: _mediaTimestamps[_random.nextInt(_mediaTimestamps.length)],
      assetPath: _mediaAssetPaths[_random.nextInt(_mediaAssetPaths.length)],
      tag: 'DI · 3',
    ),
  );

  /// Patient Izzy Castaneda's (`p1`) single media item in the "Scan
  /// inklusiv" scenario — see [patientById].
  static const MediaItem _izzyStatusScan = MediaItem(
    title: 'Status-Scan',
    timestamp: '12.08.2025 um 09:39:43',
    assetPath: 'assets/media/di_scan_1.png',
    tag: 'DI · 3',
  );

  static final List<Patient> patients = [
    Patient(
      id: 'p1',
      name: 'Castaneda, Izzy',
      cardId: '1234567890',
      dateOfBirth: '05.22.1980',
      creationDate: '27.08.2025 · 16:00',
      media: const [],
    ),
    Patient(
      id: 'p2',
      name: 'Wick, John',
      cardId: '1234567890',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p3',
      name: 'Hunt, Ethan',
      cardId: '1234567890',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p4',
      name: 'Solo, Han',
      cardId: '18762868188',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p5',
      name: 'McClane, John',
      cardId: '029409423',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p6',
      name: 'Lee, Bruce',
      cardId: '18762868188',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p7',
      name: 'Bond, James',
      cardId: '2091209830',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p8',
      name: 'Parker, Peter',
      cardId: '18762868188',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p9',
      name: 'Wyne, Bruce',
      cardId: '029409423',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _randomMedia(),
    ),
    Patient(
      id: 'p10',
      name: 'Roe, Jane',
      cardId: '12345',
      dateOfBirth: '21.11.1985',
      creationDate: '21.11.2024 · 09:00',
      media: _randomMedia(),
    ),
  ];

  static final List<ActivityEntry> _sampleActivities = [
    const ActivityEntry(
      title: 'Behandlung erstellt: Implantat',
      author: 'Sören Schüller',
      timestamp: '07.03.2025',
    ),
  ];

  static final List<Treatment> treatments = [
    Treatment(
      id: 'AA0204',
      title: 'Endo, Tim',
      patientId: 'p6',
      patientName: 'Briant, Holly',
      service: 'Wurzelkanalbehandlung',
      teeth: '14 - Wurzelkanalbehandlung',
      createdOn: '05/03/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/10/2023  10:02',
      selectedTeeth: const [14],
      activities: _sampleActivities,
      media: _randomMedia(),
    ),
    Treatment(
      id: 'AA0205',
      title: 'Krone, Holly',
      patientId: 'p7',
      patientName: 'Briant, Holly',
      service: 'Krone',
      teeth: '19 - Krone',
      createdOn: '05/03/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/10/2023  10:02',
      selectedTeeth: const [19],
      activities: _sampleActivities,
      media: _randomMedia(),
    ),
    Treatment(
      id: 'AA0206',
      title: 'Brücke, Paula',
      patientId: 'p8',
      patientName: 'Paula, Theodora',
      service: 'Provisorische Restauration',
      teeth: '22-24 - Brücke',
      createdOn: '05/10/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/10/2023  10:02',
      selectedTeeth: const [22, 23, 24],
      activities: _sampleActivities,
      media: _randomMedia(),
    ),
    Treatment(
      id: 'AA0207',
      title: 'Aufbissschiene, Angelina',
      patientId: 'p9',
      patientName: 'Briant, Angelina',
      service: 'Aufbissschiene / Schiene',
      teeth: 'Gesamter Bogen',
      createdOn: '05/03/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/03/2023  10:02',
      activities: _sampleActivities,
      media: _randomMedia(),
    ),
  ];

  /// The scan modes the scanner's detail view offers, per Figma node
  /// `40184-46885`.
  static const List<DeviceDetailItem> _scanModes = [
    DeviceDetailItem(
      title: 'Status-Scan',
      subline:
          'Für zahnärztliche Kontrolluntersuchungen und Scans vor '
          'chirurgischen Eingriffen verwenden.',
      assetPath: 'assets/scan_modes/status_scan.png',
      action: DeviceDetailAction.statusScan,
    ),
    DeviceDetailItem(
      title: 'Behandlungsscan',
      subline:
          'Zum Erstellen einer Behandlung und zum Scannen '
          'behandlungsrelevanter Bereiche verwenden.',
      assetPath: 'assets/scan_modes/treatment_scan.png',
      action: DeviceDetailAction.treatmentScan,
    ),
  ];

  /// The applications the PC/Laptop's detail view lists, per Figma node
  /// `40184-46884`. Both cards show the machine's own photo, as that node
  /// does — the applications have no artwork of their own.
  static const List<DeviceDetailItem> _pcApplications = [
    DeviceDetailItem(
      title: 'CEREC',
      subline: '5.3.1',
      assetPath: 'assets/devices/pc_laptop.png',
    ),
    DeviceDetailItem(
      title: 'Connect',
      subline: '5.3.1',
      assetPath: 'assets/devices/pc_laptop.png',
    ),
  ];

  /// The tiles the "New treatment" modal's "Treatment option" picker offers,
  /// per Figma node `40275-781084`.
  static const List<TreatmentOption> treatmentOptions = [
    TreatmentOption(
      label: 'Restauration',
      assetPath: 'assets/treatment_options/restoration.png',
    ),
    TreatmentOption(
      label: 'Prothesen',
      assetPath: 'assets/treatment_options/dentures.png',
    ),
    TreatmentOption(
      label: 'Aligner',
      assetPath: 'assets/treatment_options/aligner.png',
    ),
    TreatmentOption(
      label: 'Implantat',
      assetPath: 'assets/treatment_options/implant.png',
    ),
    TreatmentOption(
      label: 'Schiene',
      assetPath: 'assets/treatment_options/splint.png',
    ),
  ];

  /// The six view-angle images the "Use a previous scan as a reference"
  /// modal's preview cycles through, in the order its segmented control
  /// offers them: arch upper, buccal right, buccal left, bite closed,
  /// contact visualisation, bite open. Shared by both [referenceScanGroups]
  /// entries — this click-through prototype has one captured set of angles,
  /// not one per scan.
  static const List<String> _referenceScanViewAssetPaths = [
    'assets/reference_scans/status_scan_arch_upper.png',
    'assets/reference_scans/status_scan_buccal_right.png',
    'assets/reference_scans/status_scan_buccal_left.png',
    'assets/reference_scans/status_scan_thumbnail.png',
    'assets/reference_scans/status_scan_contact_visualisation.png',
    'assets/reference_scans/status_scan_bite_open.png',
  ];

  /// Builds the "Use a previous scan as a reference" modal's gallery,
  /// grouped the way Figma node `40184-58978` groups them, with exactly one
  /// tile per item in [patient]'s Media tab ([Patient.media]) — so the
  /// gallery never offers more scans as a reference than the patient
  /// actually has. Each tile keeps that media item's title, timestamp and
  /// thumbnail, but reuses the shared [_referenceScanViewAssetPaths] for the
  /// preview, since this prototype has only one captured set of angles.
  ///
  /// Empty when the patient has no media — callers should skip the modal
  /// entirely in that case rather than show an empty gallery.
  static List<ReferenceScanGroup> referenceScanGroupsForPatient(
    Patient patient,
  ) {
    if (patient.media.isEmpty) return const [];

    return [
      ReferenceScanGroup(
        title: 'Neueste',
        scans: [
          for (final item in patient.media)
            ReferenceScan(
              title: item.title,
              timestamp: item.timestamp,
              assetPath: item.assetPath,
              viewAssetPaths: _referenceScanViewAssetPaths,
            ),
        ],
      ),
    ];
  }

  /// The devices offered by the "Select device" modal, matching the Figma
  /// "Modal - Device selection" frame `40250-121538`: every device is
  /// selectable and online, so all four are shown at once with no disabled
  /// cards.
  ///
  /// Each carries the `detail*` fields of its own detail view — Figma nodes
  /// `40184-46885` (the scanner) and `40184-46884` (the PC/Laptop).
  ///
  /// The three scanners are the same named Primescans as [notificationDevices]
  /// — Nemo and Bruce share their serial number and battery level with that
  /// list, confirming they are the same physical devices — but here every one
  /// of them is online: this scenario has nothing to report about them.
  static const List<Device> devices = [
    Device(
      name: 'Primescan 2 - Nemo',
      subline: 'SN: 15552561',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 81,
      thumbnailInset: 26,
      detailSubline: 'SN: 15552561',
      detailImageInset: 52,
      detailItems: _scanModes,
    ),
    Device(
      name: 'PC/Laptop Raum 4',
      subline: 'CEREC, Connect',
      assetPath: 'assets/devices/pc_laptop.png',
      detailItems: _pcApplications,
    ),
    Device(
      name: 'Primescan 2 - Bruce',
      subline: 'SN: 1555260',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 44,
      thumbnailInset: 26,
      detailSubline: 'SN: 1555260',
      detailImageInset: 52,
      detailItems: _scanModes,
    ),
    Device(
      name: 'Primescan 2 - Dorie',
      subline: 'SN: 1555259',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 44,
      thumbnailInset: 26,
      detailSubline: 'SN: 1555259',
      detailImageInset: 52,
      detailItems: _scanModes,
    ),
  ];

  /// The devices offered by the "Select device" modal in the "Notifikationen"
  /// scenario — see [DeviceScenario.notifications] — matching the Figma
  /// "Notifikationen" instance of node `40252-12717`: the same modal as
  /// [devices], but with one of its scanners (Bruce) reporting an outdated
  /// firmware instead of being in use or warning. Nemo is online in this
  /// scenario.
  ///
  /// Structured the same way as [devices] — the modal shows every device at
  /// once, selectable ones alongside the one non-selectable card — so
  /// `showCaptureScanModal` needs no scenario-specific layout logic, only a
  /// different list.
  static const List<Device> notificationDevices = [
    Device(
      name: 'PC/Laptop Raum 4',
      subline: 'CEREC, Connect',
      assetPath: 'assets/devices/pc_laptop.png',
      detailItems: _pcApplications,
    ),
    Device(
      name: 'Primescan 2 - Dorie',
      subline: 'SN: 1555262',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 44,
      thumbnailInset: 26,
      detailSubline: 'SN: 1555262',
      detailImageInset: 52,
      detailItems: _scanModes,
    ),
    Device(
      name: 'Primescan 2 - Nemo',
      subline: 'SN: 15552561',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 81,
      thumbnailInset: 26,
      detailSubline: 'SN: 15552561',
      detailImageInset: 52,
      detailItems: _scanModes,
    ),
    Device(
      name: 'Primescan 2 - Bruce',
      subline: 'SN: 1555260',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 44,
      status: DeviceStatus.firmwareOutdated,
      selectable: false,
      statusDescription:
          'Ohne weitere Eingaben wird die Primescan-Software nach dieser '
          'Scan-Sitzung automatisch aktualisiert.',
      statusLinkText: 'Jetzt aktualisieren',
      thumbnailInset: 26,
    ),
  ];

  /// Looks up a patient by [id].
  ///
  /// Patient `p1` (Izzy Castaneda) has no fixed media in [patients] — her
  /// media depends on which [DeviceScenario] the tester picked on
  /// [StartMenuPage]: none in "Scan exklusiv" or "Szenario 4", one status
  /// scan in "Scan inklusiv". Read fresh on every call, rather than baked
  /// into [patients], so re-picking a scenario after returning to the start
  /// menu is reflected immediately.
  static Patient? patientById(String id) {
    final patient = patients.where((p) => p.id == id).firstOrNull;
    if (patient == null || patient.id != 'p1') return patient;

    return Patient(
      id: patient.id,
      name: patient.name,
      cardId: patient.cardId,
      dateOfBirth: patient.dateOfBirth,
      creationDate: patient.creationDate,
      media: switch (DeviceScenarioState.current) {
        DeviceScenario.exclusive || DeviceScenario.notifications => const [],
        DeviceScenario.scans => const [_izzyStatusScan],
      },
    );
  }

  static Treatment? treatmentById(String id) =>
      treatments.where((t) => t.id == id).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
