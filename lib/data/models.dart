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

/// The availability of a [Device], shown as the device card's status tag.
///
/// Mirrors the states the Figma "Select device" frames show. Kept free of
/// `DeviceCardStatus` so this data layer stays independent of the vendored
/// components; `lib/flows/capture_scan.dart` maps between the two.
enum DeviceStatus { online, offline, inUse, warning }

/// One card of a [Device]'s detail view: what the device can do, or what runs
/// on it.
///
/// The Figma detail nodes fill the same card list with two different kinds of
/// content — the scanner offers scan modes ("Status scan", "Treatment scan"),
/// the PC/Laptop lists its installed applications ("CEREC 5.3.1",
/// "Connect 5.3.1") — so this carries only the title, subline and image the
/// card renders, and leaves what they mean to the device.
class DeviceDetailItem {
  const DeviceDetailItem({
    required this.title,
    required this.subline,
    required this.assetPath,
  });

  final String title;
  final String subline;

  /// Image shown in the card's 120x120 thumbnail slot. Square, and already
  /// carrying its own whitespace, so it needs no inset.
  final String assetPath;
}

/// A connected device offered by the "Capture scan" → "Select device" modal.
class Device {
  const Device({
    required this.name,
    required this.subline,
    required this.assetPath,
    this.batteryPercent,
    this.status = DeviceStatus.online,
    this.statusLabel,
    this.selectable = true,
    this.statusDescription,
    this.statusLinkText,
    this.thumbnailInset = 0,
    this.detailSubline,
    this.detailImageInset = 0,
    this.detailItems = const [],
  });

  final String name;
  final String subline;

  /// Photo of the device, shown in the card's 120×120 thumbnail slot.
  final String assetPath;

  /// Battery level in percent, or null for a mains-powered device.
  final int? batteryPercent;
  final DeviceStatus status;

  /// Overrides the status tag's default copy where the state carries a number
  /// the enum cannot — the Figma frame's "3 warnings".
  final String? statusLabel;

  /// Whether this device can be picked for a scan.
  ///
  /// Non-selectable devices are hidden until the modal's "All devices" button
  /// is pressed. They then render as normal cards with a dimmed thumbnail,
  /// and tapping one reveals [statusDescription] instead of picking it.
  final bool selectable;

  /// Explains why a non-selectable device cannot be picked. Shown inside its
  /// card once tapped; unused on a selectable device.
  final String? statusDescription;

  /// Label of the link below [statusDescription]. No link when null.
  ///
  /// The link is inert in this prototype — there is nothing behind it.
  final String? statusLinkText;

  /// Padding around [assetPath] inside the thumbnail slot, in logical pixels.
  ///
  /// The Figma frame scales each device photo differently inside the same
  /// 120×120 slot — the scanner sits inset, the PC/laptop spans the full
  /// width — so the inset is carried per device rather than fixed in the view.
  final double thumbnailInset;

  /// The single metadata item shown left of the battery indicator and status
  /// tag in this device's detail view. Omitted when null.
  ///
  /// Deliberately separate from [subline] rather than reusing it: the two
  /// Figma detail nodes disagree on whether the list card's subline belongs in
  /// the detail header. The scanner's is its serial number, which identifies
  /// the device and is repeated there; the PC/Laptop's summarises the
  /// applications the detail view then lists as [detailItems], so repeating it
  /// would say the same thing twice.
  final String? detailSubline;

  /// Padding around [assetPath] inside the detail view's 240×240 image slot,
  /// in logical pixels.
  ///
  /// The 240-slot counterpart of [thumbnailInset], and stated separately for
  /// the same reason: the Figma detail nodes scale each photo by their own
  /// factor. It happens to be twice [thumbnailInset] for both devices — the
  /// detail slot is twice the card slot, and both nodes scale the photo
  /// proportionally — but that is what the nodes show, not a rule to derive
  /// from.
  final double detailImageInset;

  /// The cards listed below the image in this device's detail view. Empty for
  /// a device that has no detail view.
  final List<DeviceDetailItem> detailItems;
}
