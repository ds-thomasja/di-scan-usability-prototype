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

  static Patient? patientById(String id) =>
      patients.where((p) => p.id == id).firstOrNull;

  static Treatment? treatmentById(String id) =>
      treatments.where((t) => t.id == id).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
