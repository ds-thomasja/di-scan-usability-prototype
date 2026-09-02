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

/// A connected device offered by the "Capture scan" → "Select device" modal.
class Device {
  const Device({
    required this.name,
    required this.subline,
    required this.assetPath,
    this.batteryPercent,
    this.online = true,
    this.thumbnailInset = 0,
  });

  final String name;
  final String subline;

  /// Photo of the device, shown in the card's 120×120 thumbnail slot.
  final String assetPath;

  /// Battery level in percent, or null for a mains-powered device.
  final int? batteryPercent;
  final bool online;

  /// Padding around [assetPath] inside the thumbnail slot, in logical pixels.
  ///
  /// The Figma frame scales each device photo differently inside the same
  /// 120×120 slot — the scanner sits inset, the PC/laptop spans the full
  /// width — so the inset is carried per device rather than fixed in the view.
  final double thumbnailInset;
}
