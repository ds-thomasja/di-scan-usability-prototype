import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../components/device_card/device_card.dart';
import '../components/device_modal/device_modal.dart';
import '../data/device_scenario.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import 'create_treatment.dart';

/// Opens the "Select device" modal that every "Capture scan" button leads to.
///
/// Matches the Figma frame *DI Scan · Projects*, in all four of its states:
///
/// - node `40250-121538` — a one-click list of the selectable devices;
/// - node `40428-152410` — the devices that cannot be picked (in use, or
///   reporting warnings) join the list, rendered with a dimmed thumbnail, and
///   are always shown alongside the selectable ones. Tapping one of those
///   opens the in-card notification explaining why it cannot be picked, per
///   Figma "Device card" node `5389:18149`.
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
/// Which devices and states the list shows depends on [DeviceScenarioState]:
/// [MockData.devices] for the "Scans" scenario, or
/// [MockData.notificationDevices] — outdated calibration/firmware tags in
/// place of "in use"/"warning" — for "Notifikationen". Both scenarios reuse
/// this exact same modal; see [DeviceScenario].
///
/// [fromTreatmentDetail] marks the call from [TreatmentDetailPage]: picking a
/// device there skips straight to the treatment-scan flow instead of
/// stopping at that device's detail view, since a treatment scan is the only
/// thing "Capture scan" can mean from inside a treatment. See
/// [_CaptureScanModalState._buildSelectView].
///
/// [patient] is whichever patient the flow is scoped to — the one whose page
/// this was opened from, or (from [TreatmentDetailPage]) the treatment's own
/// patient — and is only used should [DeviceDetailAction.treatmentScan] be
/// picked, to decide whether [showTreatmentScanFlow] offers "Use a previous
/// scan as a reference" at all.
///
/// The returned future completes once the modal has closed and any flow it
/// started has been navigated to.
Future<void> showCaptureScanModal(
  BuildContext context, {
  required Patient? patient,
  bool fromTreatmentDetail = false,
}) async {
  final DeviceDetailAction? action =
      await showDSModalDialog<DeviceDetailAction?>(
        context: context,
        builder: (context, pop) => _CaptureScanModal(
          pop: pop,
          fromTreatmentDetail: fromTreatmentDetail,
        ),
      );

  // [context] here is the caller's — the page that opened the modal, which is
  // still on screen unless something navigated away while it was open.
  if (action == null || !context.mounted) return;

  switch (action) {
    // Pushed rather than gone to, so that the loading page's "Cancel loading"
    // has this page to return to.
    case DeviceDetailAction.statusScan:
      context.push(AppRoutes.scanLoading);
    // Two more modals first — "New treatment", then "Use a previous scan as
    // a reference" — both entirely independent of the one that just closed;
    // see [showTreatmentScanFlow].
    case DeviceDetailAction.treatmentScan:
      await showTreatmentScanFlow(
        context,
        patient: patient,
        skipNewTreatment: fromTreatmentDetail,
      );
  }
}

/// Holds which of the modal's two views is on screen, for the duration of the
/// modal.
class _CaptureScanModal extends StatefulWidget {
  const _CaptureScanModal({
    required this.pop,
    required this.fromTreatmentDetail,
  });

  /// Closes the modal, optionally with the flow the tester picked out of it.
  final Pop<DeviceDetailAction?> pop;

  /// See [showCaptureScanModal]'s parameter of the same name.
  final bool fromTreatmentDetail;

  @override
  State<_CaptureScanModal> createState() => _CaptureScanModalState();
}

class _CaptureScanModalState extends State<_CaptureScanModal> {
  /// The device list backing this instance of the modal: [MockData.devices]
  /// or [MockData.notificationDevices], per whichever [DeviceScenario] the
  /// tester picked on [StartMenuPage]. Read once — like the scenario itself,
  /// nothing changes it while the modal is open.
  late final List<Device> _devices = switch (DeviceScenarioState.current) {
    DeviceScenario.exclusive || DeviceScenario.scans => MockData.devices,
    DeviceScenario.notifications => MockData.notificationDevices,
  };

  /// The index into [_devices] of the device whose detail view is showing, or
  /// null while the list view is.
  int? _openedIndex;

  @override
  Widget build(BuildContext context) {
    final openedIndex = _openedIndex;
    return openedIndex == null
        ? _buildSelectView()
        : _buildDetailsView(openedIndex);
  }

  /// The device list the modal opens on. Tapping a card shows that device's
  /// detail view rather than closing the modal — unless [_startsTreatmentScan]
  /// says this pick should skip straight to the treatment-scan flow instead.
  Widget _buildSelectView() => DeviceModal.selectDevice(
    devices: [for (final device in _devices) _toModalDevice(device)],
    // The Figma frame shows no Confirm button: one tap picks the device.
    selectable: false,
    onClose: widget.pop,
    onConfirm: (index) {
      if (index != null && _startsTreatmentScan(_devices[index])) {
        widget.pop(DeviceDetailAction.treatmentScan);
      } else {
        setState(() => _openedIndex = index);
      }
    },
  );

  /// Whether picking [device] from the list should bypass its detail view and
  /// go straight to the treatment-scan flow: only from
  /// [TreatmentDetailPage]'s "Capture scan" (per [widget.fromTreatmentDetail]),
  /// and only for a device that actually offers a treatment scan.
  bool _startsTreatmentScan(Device device) =>
      widget.fromTreatmentDetail &&
      device.detailItems.any(
        (item) => item.action == DeviceDetailAction.treatmentScan,
      );

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
    final device = _devices[index];

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
  DeviceStatus.calibrationOutdated => DeviceCardStatus.calibrationOutdated,
  DeviceStatus.firmwareOutdated => DeviceCardStatus.firmwareOutdated,
};
