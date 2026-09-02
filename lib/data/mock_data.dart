import 'models.dart';

/// Fake data mirroring the sample names/IDs used in the Figma mockups.
/// This prototype contains no real patient information.
class MockData {
  MockData._();

  static const List<MediaItem> _sampleMedia = [
    MediaItem(
      title: 'Treatment scan',
      timestamp: 'Now',
      assetPath: 'assets/media/scan_1.png',
      tag: 'DI · 7',
    ),
    MediaItem(
      title: 'Treatment scan',
      timestamp: '5 min ago',
      assetPath: 'assets/media/scan_2.png',
      tag: 'DI · 4',
    ),
    MediaItem(
      title: 'Treatment scan',
      timestamp: '7 min ago',
      assetPath: 'assets/media/scan_3.png',
      tag: 'PHOTO · 12',
    ),
    MediaItem(
      title: 'Treatment scan',
      timestamp: '12.08.2025 at 09:39:43',
      assetPath: 'assets/media/scan_4.png',
      tag: 'DI',
    ),
  ];

  static final List<Patient> patients = [
    const Patient(
      id: 'p1',
      name: 'Castaneda, Izzy',
      cardId: '1234567890',
      dateOfBirth: '05.22.1980',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p2',
      name: 'Wick, John',
      cardId: '1234567890',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p3',
      name: 'Hunt, Ethan',
      cardId: '1234567890',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p4',
      name: 'Solo, Han',
      cardId: '18762868188',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p5',
      name: 'McClane, John',
      cardId: '029409423',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p6',
      name: 'Lee, Bruce',
      cardId: '18762868188',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p7',
      name: 'Bond, James',
      cardId: '2091209830',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p8',
      name: 'Parker, Peter',
      cardId: '18762868188',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p9',
      name: 'Wyne, Bruce',
      cardId: '029409423',
      dateOfBirth: '27.08.1990',
      creationDate: '27.08.2025 · 16:00',
      media: _sampleMedia,
    ),
    const Patient(
      id: 'p10',
      name: 'Roe, Jane',
      cardId: '12345',
      dateOfBirth: '21.11.1985',
      creationDate: '21.11.2024 · 09:00',
      media: _sampleMedia,
    ),
  ];

  static final List<ActivityEntry> _sampleActivities = [
    const ActivityEntry(
      title: 'Treatment created: Implant',
      author: 'Sören Schüller',
      timestamp: '07.03.2025',
    ),
  ];

  static final List<Treatment> treatments = [
    Treatment(
      id: 'AA00LY9',
      title: 'Implant',
      patientId: 'p1',
      patientName: 'Castaneda, Izzy',
      service: 'Restoration',
      teeth: '16 - Crown',
      createdOn: '08/27/2024  9:12',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '08/27/2024  9:12',
      selectedTeeth: const [16],
      activities: _sampleActivities,
    ),
    Treatment(
      id: 'AA0204',
      title: 'Endo, Tim',
      patientId: 'p6',
      patientName: 'Briant, Holly',
      service: 'Root canal treatment',
      teeth: '14 - Root canal',
      createdOn: '05/03/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/10/2023  10:02',
      selectedTeeth: const [14],
      activities: _sampleActivities,
    ),
    Treatment(
      id: 'AA0205',
      title: 'Crown, Holly',
      patientId: 'p7',
      patientName: 'Briant, Holly',
      service: 'Crown',
      teeth: '19 - Crown',
      createdOn: '05/03/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/10/2023  10:02',
      selectedTeeth: const [19],
      activities: _sampleActivities,
    ),
    Treatment(
      id: 'AA0206',
      title: 'Bridge, Paula',
      patientId: 'p8',
      patientName: 'Paula, Theodora',
      service: 'Temporary Restoration',
      teeth: '22-24 - Bridge',
      createdOn: '05/10/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/10/2023  10:02',
      selectedTeeth: const [22, 23, 24],
      activities: _sampleActivities,
    ),
    Treatment(
      id: 'AA0207',
      title: 'Nightguard, Angelina',
      patientId: 'p9',
      patientName: 'Briant, Angelina',
      service: 'Nightguard / Splint',
      teeth: 'Full arch',
      createdOn: '05/03/2023  10:02',
      createdBy: 'Dr. Ada, Angelina',
      lastActivity: '05/03/2023  10:02',
      activities: _sampleActivities,
    ),
  ];

  /// The scan modes the scanner's detail view offers, per Figma node
  /// `40184-46885`.
  static const List<DeviceDetailItem> _scanModes = [
    DeviceDetailItem(
      title: 'Status scan',
      subline: 'Use for dental check-ups and scanning before surgery.',
      assetPath: 'assets/scan_modes/status_scan.png',
      action: DeviceDetailAction.statusScan,
    ),
    DeviceDetailItem(
      title: 'Treatment scan',
      subline: 'Use to create a treatment and scan areas relevant to the '
          'treatment.',
      assetPath: 'assets/scan_modes/treatment_scan.png',
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

  /// The devices offered by the "Select device" modal, matching the Figma
  /// "Modal - Device selection" frames: the two selectable ones the modal
  /// opens on (node `40250-121538`), followed by the two the "All devices"
  /// button reveals as disabled cards (node `40428-152410`).
  ///
  /// The two selectable ones carry the `detail*` fields of their own detail
  /// view — Figma nodes `40184-46885` (the scanner) and `40184-46884` (the
  /// PC/Laptop). The other two have none: they cannot be picked, so their
  /// detail view is never reached.
  static const List<Device> devices = [
    Device(
      name: 'Primescan 2 Name',
      subline: 'SN: 15552561',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 81,
      thumbnailInset: 26,
      detailSubline: 'SN: 15552561',
      detailImageInset: 52,
      detailItems: _scanModes,
    ),
    Device(
      name: 'PC/Laptop Room 4',
      subline: 'CEREC, Connect',
      assetPath: 'assets/devices/pc_laptop.png',
      detailItems: _pcApplications,
    ),
    Device(
      name: 'Primescan 2 Name',
      subline: 'SN: 1555260',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 44,
      status: DeviceStatus.inUse,
      selectable: false,
      // Placeholder copy: the Figma node carries only lorem-ipsum, so this is
      // written to be plausible for the test session, not signed off.
      statusDescription:
          'This scanner is currently capturing a scan at another workstation. '
          'It becomes available once that scan is finished.',
      statusLinkText: 'Show who is using it',
      thumbnailInset: 26,
    ),
    Device(
      name: 'Primescan 2 Name',
      subline: 'SN: 1555259',
      assetPath: 'assets/devices/primescan_2.png',
      batteryPercent: 44,
      status: DeviceStatus.warning,
      statusLabel: '3 warnings',
      selectable: false,
      statusDescription:
          'This scanner reports 3 warnings that have to be resolved before it '
          'can capture a scan.',
      statusLinkText: 'Show the warnings',
      thumbnailInset: 26,
    ),
  ];

  static Patient? patientById(String id) =>
      patients.where((p) => p.id == id).firstOrNull;

  static Treatment? treatmentById(String id) =>
      treatments.where((t) => t.id == id).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
