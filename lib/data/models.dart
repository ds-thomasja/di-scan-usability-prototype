/// A single dental scan / media item belonging to a patient.
class MediaItem {
  const MediaItem({
    required this.title,
    required this.timestamp,
    required this.assetPath,
    this.tag,
  });

  final String title;
  final String timestamp;
  final String assetPath;
  final String? tag;
}

/// A note or activity log entry, shown in a treatment's "quick view" panel.
class ActivityEntry {
  const ActivityEntry({
    required this.title,
    required this.author,
    required this.timestamp,
  });

  final String title;
  final String author;
  final String timestamp;
}

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.cardId,
    required this.dateOfBirth,
    required this.creationDate,
    this.media = const [],
  });

  final String id;
  final String name;
  final String cardId;
  final String dateOfBirth;
  final String creationDate;
  final List<MediaItem> media;
}

class Treatment {
  const Treatment({
    required this.id,
    required this.title,
    required this.patientId,
    required this.patientName,
    required this.service,
    required this.teeth,
    required this.createdOn,
    required this.createdBy,
    required this.lastActivity,
    this.selectedTeeth = const [],
    this.activities = const [],
  });

  final String id;
  final String title;
  final String patientId;
  final String patientName;
  final String service;
  final String teeth;
  final String createdOn;
  final String createdBy;
  final String lastActivity;
  final List<int> selectedTeeth;
  final List<ActivityEntry> activities;
}
