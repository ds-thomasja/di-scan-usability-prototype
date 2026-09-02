import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../components/device_card/device_card.dart';
import '../components/device_modal/device_modal.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

/// Label of the footer button while only the selectable devices are listed.
const String _showAllLabel = 'All devices';

/// Label of the same button once the full list is shown.
const String _showSelectableOnlyLabel = 'Selectable devices only';

/// Opens the "Select device" modal that every "Capture scan" button leads to.
///
/// Matches the Figma frame *DI Scan · Projects*, in all four of its states:
///
/// - node `40250-121538` — a one-click list of the selectable devices plus an
///   "All devices" button bottom right;
/// - node `40428-152410` — that button pressed: the devices that cannot be
///   picked (in use, or reporting warnings) join the list, rendered with a
///   dimmed thumbnail, and the button becomes "Selectable devices only".
///   Tapping one of those opens the in-card notification explaining why it
///   cannot be picked, per Figma "Device card" node `5389:18149`.
/// - nodes `40184-46885` and `40184-46884` — the detail view a picked device
///   switches the modal to: that device's own header, its photo, and the cards
///   listing what it offers. "Switch device" returns to the list.
///
/// Rendered by the shared [DeviceModal] component from the `overarching` repo
/// (`lib/components/device_modal`), whose `deviceDetails` mode is the
/// detail view.
///
/// One of the detail view's cards continues the flow: "Status scan" closes
/// the modal and pushes [AppRoutes.scanLoading]. The others are dead ends —
/// see [_buildDetailsView].
///
/// The returned future completes once the modal has closed and any flow it
/// started has been navigated to.
Future<void> showCaptureScanModal(BuildContext context) async {
  final DeviceDetailAction? action =
      await showDSModalDialog<DeviceDetailAction?>(
    context: context,
    builder: (context, pop) => _CaptureScanModal(pop: pop),
  );

  // [context] here is the caller's — the page that opened the modal, which is
  // still on screen unless something navigated away while it was open.
  if (action == null || !context.mounted) return;

  switch (action) {
    // Pushed rather than gone to, so that the loading page's "Cancel loading"
    // has this page to return to.
    case DeviceDetailAction.statusScan:
      context.push(AppRoutes.scanLoading);
  }
}

/// Holds which of the modal's two views is on screen, and the "All devices"
/// toggle of the list view, for the duration of the modal.
///
/// Both live here rather than in [DeviceModal] because both are the caller's:
/// the component renders one view or the other from the constructor it is
/// given, and the filtering the button stands for is a property of the data,
/// not of the modal.
class _CaptureScanModal extends StatefulWidget {
  const _CaptureScanModal({required this.pop});

  /// Closes the modal, optionally with the flow the tester picked out of it.
  final Pop<DeviceDetailAction?> pop;

  @override
  State<_CaptureScanModal> createState() => _CaptureScanModalState();
}

class _CaptureScanModalState extends State<_CaptureScanModal> {
  /// Whether the non-selectable devices are listed too.
  bool _showAll = false;

  /// The index into [MockData.devices] of the device whose detail view is
  /// showing, or null while the list view is.
  int? _openedIndex;

  @override
  Widget build(BuildContext context) {
    final openedIndex = _openedIndex;
    return openedIndex == null
        ? _buildSelectView()
        : _buildDetailsView(openedIndex);
  }

  /// The device list the modal opens on. Tapping a card shows that device's
  /// detail view rather than closing the modal.
  Widget _buildSelectView() {
    // The devices actually on screen, and their positions in the full list, so
    // a tap can be resolved against MockData.devices rather than the subset.
    final shown = <(int, Device)>[
      for (var i = 0; i < MockData.devices.length; i++)
        if (_showAll || MockData.devices[i].selectable) (i, MockData.devices[i]),
    ];

    return DeviceModal.selectDevice(
      devices: [for (final (_, device) in shown) _toModalDevice(device)],
      // The Figma frame shows no Confirm button: one tap picks the device.
      selectable: false,
      onClose: widget.pop,
      onConfirm: (index) => setState(() {
        _openedIndex = index == null ? null : shown[index].$1;
      }),
      secondaryLabel: _showAll ? _showSelectableOnlyLabel : _showAllLabel,
      onSecondaryPressed: () => setState(() => _showAll = !_showAll),
    );
  }

  /// The detail view of [index]'s device, per its Figma node.
  ///
  /// Every card here is tappable, but only the ones carrying a
  /// [DeviceDetailItem.action] lead anywhere — today that is the scanner's
  /// "Status scan". [DeviceModal] takes one callback for the whole list
  /// rather than one per card, and the alternative to a swallowed tap would
  /// be a card the design shows as a card but that does not even respond to
  /// hover. Same call as the in-card notification link below: a dead end that
  /// looks like the design beats one that reads as broken.
  Widget _buildDetailsView(int index) {
    final device = MockData.devices[index];

    return DeviceModal.deviceDetails(
      device: DeviceModalDeviceDetails(
        name: device.name,
        subline1: device.detailSubline,
        batteryPercent: device.batteryPercent,
        status: _toCardStatus(device.status),
        image: Padding(
          padding: EdgeInsets.all(device.detailImageInset),
          child: Image.asset(device.assetPath, fit: BoxFit.contain),
        ),
      ),
      otherDevices: [
        for (final item in device.detailItems)
          DeviceModalDevice(
            name: item.title,
            subline: item.subline,
            // A sentence, not a serial number: let it wrap instead of
            // truncating at the card's default two lines.
            sublineMaxLines: null,
            thumbnail: Image.asset(item.assetPath, fit: BoxFit.contain),
          ),
      ],
      onOtherDeviceSelected: (item) {
        final action = device.detailItems[item].action;
        if (action != null) widget.pop(action);
      },
      onClose: widget.pop,
      onSwitchDevice: () => setState(() => _openedIndex = null),
    );
  }
}

/// Maps a prototype [Device] onto the shape [DeviceModal] consumes.
DeviceModalDevice _toModalDevice(Device device) => DeviceModalDevice(
  name: device.name,
  subline: device.subline,
  batteryPercent: device.batteryPercent,
  status: _toCardStatus(device.status),
  statusLabel: device.statusLabel,
  selectable: device.selectable,
  notification: _toNotification(device),
  thumbnail: Padding(
    padding: EdgeInsets.all(device.thumbnailInset),
    child: Image.asset(device.assetPath, fit: BoxFit.contain),
  ),
);

/// Builds the in-card notification for a device that cannot be picked.
///
/// Returns null for a selectable device, and for a non-selectable one with
/// nothing to say — which leaves its card inert rather than tappable to no
/// effect.
DeviceCardNotification? _toNotification(Device device) {
  final description = device.statusDescription;
  if (device.selectable || description == null) return null;

  return DeviceCardNotification(
    description: description,
    linkText: device.statusLinkText,
    // A no-op rather than null: DSLinkWidget renders a link without a callback
    // in its disabled style, and the Figma node shows a live `text/interactive`
    // link. There is nothing behind it in this click-through prototype, so the
    // tap is swallowed — the link is a dead end that looks like the design,
    // rather than a live-looking one that navigates or a grey one that reads
    // as broken.
    onLinkPressed: () {},
  );
}

/// Maps the data layer's [DeviceStatus] onto the card's own status enum.
DeviceCardStatus _toCardStatus(DeviceStatus status) => switch (status) {
  DeviceStatus.online => DeviceCardStatus.online,
  DeviceStatus.offline => DeviceCardStatus.offline,
  DeviceStatus.inUse => DeviceCardStatus.inUse,
  DeviceStatus.warning => DeviceCardStatus.warning,
};
