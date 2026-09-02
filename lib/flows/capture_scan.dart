import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../components/device_card/device_card.dart';
import '../components/device_modal/device_modal.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

/// Opens the "Select device" modal that every "Capture scan" button leads to.
///
/// Matches the Figma frame *DI Scan · Projects*, node `40250-121538`: a
/// one-click device list — tapping a card picks that device straight away, with
/// no confirm step — rendered by the shared [DeviceModal] component from the
/// `overarching` repo (`lib/components/device_modal`).
///
/// Picking a device only closes the modal: this click-through prototype has no
/// scan acquisition behind it. The returned future completes with the index of
/// the picked device, or null when the modal was dismissed.
Future<int?> showCaptureScanModal(BuildContext context) =>
    showDSModalDialog<int?>(
      context: context,
      builder: (context, pop) => DeviceModal.selectDevice(
        devices: MockData.devices.map(_toModalDevice).toList(),
        // The Figma frame shows no Confirm button: one tap picks the device.
        selectable: false,
        onClose: pop,
        onConfirm: pop,
      ),
    );

/// Maps a prototype [Device] onto the shape [DeviceModal] consumes.
DeviceModalDevice _toModalDevice(Device device) => DeviceModalDevice(
  name: device.name,
  subline: device.subline,
  batteryPercent: device.batteryPercent,
  status: device.online ? DeviceCardStatus.online : DeviceCardStatus.offline,
  thumbnail: Padding(
    padding: EdgeInsets.all(device.thumbnailInset),
    child: Image.asset(device.assetPath, fit: BoxFit.contain),
  ),
);
