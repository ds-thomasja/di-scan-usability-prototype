import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';
import 'package:lightning_core_ui/lightning_core_ui_experimental.dart';

import '../app_router.dart';
import '../data/mock_data.dart';
import '../data/models.dart';

/// Width of the "Treatment overview" / preview column on either modal.
const double _sidebarWidth = 360;

/// Width of each tile in the "Use a previous scan as a reference" gallery —
/// two of which, side by side, size that gallery's column (see
/// [_SelectReferenceModalState.build]).
const double _referenceTileWidth = 160;

/// Height of the "Use a previous scan as a reference" modal's body.
const double _referenceBodyHeight = 600;

/// Height of the "New treatment" modal's body, matching the `Body` slot of
/// Figma node `40275-781084` (707.375, rounded up).
const double _newTreatmentBodyHeight = 708;

/// Every tooth in [DSToothSet.permanent], upper and lower — used to disable
/// the whole "Tooth position" chart while no treatment option is picked (see
/// [_NewTreatmentModalState._buildTreatmentDefinition]): there is no
/// per-tooth condition or plain inclusion to record without one.
final Set<DSTooth> _allPermanentTeeth = {
  ...DSToothSet.permanent.upper,
  ...DSToothSet.permanent.lower,
};

/// Runs the treatment-scan flow started by [DeviceDetailAction.treatmentScan]:
/// "New treatment" (Figma node `40275-781084`), then
/// "Use a previous scan as a reference" (Figma node `40184-58978`), then the
/// same app-loading wait [DeviceDetailAction.statusScan] ends on — with its
/// "Fetch scan data" step, since this flow actually has a treatment and a
/// reference scan to fetch data for.
///
/// Both modals are independent of the "Select device" modal that led here: it
/// has already closed by the time this runs, and neither of these reopens it.
/// Cancelling (or closing) either one ends the flow — same as a swallowed tap
/// elsewhere in this click-through prototype, closing is simpler and no less
/// correct than pretending to undo a treatment that was never created.
///
/// [skipNewTreatment] drops the "New treatment" modal: set from
/// [TreatmentDetailPage]'s "Capture scan", where the treatment already
/// exists, so the flow starts straight at "Use a previous scan as a
/// reference" instead of offering to create another one.
///
/// [patient] backs "Use a previous scan as a reference": that modal is
/// skipped entirely when [patient] has no media in their Media tab
/// ([Patient.media]) — there is nothing it could offer as a reference — and
/// otherwise its gallery shows exactly as many scans as that Media tab does,
/// via [MockData.referenceScanGroupsForPatient].
Future<void> showTreatmentScanFlow(
  BuildContext context, {
  required Patient? patient,
  bool skipNewTreatment = false,
}) async {
  if (!skipNewTreatment) {
    final bool? createPressed = await showDSModalDialog<bool>(
      context: context,
      builder: (context, pop) => _NewTreatmentModal(pop: pop),
    );
    if (createPressed != true || !context.mounted) return;
  }

  if (patient != null && patient.media.isNotEmpty) {
    final bool? continuePressed = await showDSModalDialog<bool>(
      context: context,
      builder: (context, pop) =>
          _SelectReferenceModal(pop: pop, patient: patient),
    );
    if (continuePressed != true || !context.mounted) return;
  }

  // Pushed rather than gone to, for the same reason [DeviceDetailAction.
  // statusScan] pushes it: so "Cancel loading" has this page to return to.
  context.push(AppRoutes.scanLoading, extra: true);
}

/// The "New treatment" modal: a treatment-option picker, a tooth chart, and a
/// static-looking overview of the pick — Figma node `40275-781084`.
///
/// The option tiles and the tooth chart are genuinely selectable; the
/// overview panel reflects that pick (see [_TreatmentOverview]). Tapping a
/// tooth under Restoration, Aligner or Implant opens that option's popover
/// (see [_toothOptionsByLabel]) to pick the tooth's clinical sub-type, e.g.
/// "Crown"; Dentures and Splint have no such popover, so tapping a tooth
/// under either just toggles it in or out of the treatment.
class _NewTreatmentModal extends StatefulWidget {
  const _NewTreatmentModal({required this.pop});

  /// Closes the modal. `true` when "Create treatment" was pressed, `false`
  /// for Cancel, the close button, or Escape.
  final Pop<bool> pop;

  @override
  State<_NewTreatmentModal> createState() => _NewTreatmentModalState();
}

class _NewTreatmentModalState extends State<_NewTreatmentModal> {
  /// Index into [MockData.treatmentOptions] of the selected tile, or null
  /// while none is picked — the Figma node shows no tile pre-selected.
  int? _selectedOption;

  /// The one tooth marked in the "Tooth position" chart — only a single
  /// tooth may be selected at a time — mapped to the clinical sub-type
  /// picked in its popover (e.g. "Crown", "Missing"), or null for a
  /// treatment option with no per-tooth popover (Dentures, Splint), where
  /// tapping a tooth only marks it as part of the treatment. Empty while no
  /// tooth is picked.
  final Map<DSTooth, String?> _selectedTeeth = {};

  /// Anchors the popovers [DSDentalChart.onToothPressed] opens to the tapped
  /// tooth.
  final GlobalKey<DSNonModalPopupScopeState> _popupScopeKey = GlobalKey();

  /// Closes whichever tooth popover is currently open, or null if none is.
  ///
  /// Set right after a popover opens, and called before opening another one
  /// or switching [_selectedOption] — Figma shows only ever one popover, so
  /// picking a different tooth or a different treatment option closes
  /// whichever is open rather than leaving it stacked or orphaned.
  void Function()? _closeToothPopover;

  void _closePopoverIfOpen() {
    _closeToothPopover?.call();
    _closeToothPopover = null;
  }

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return DSModalDialog(
      variant: DSModalDialogVariant.large,
      title: 'Neue Behandlung',
      onClose: () => widget.pop(false),
      buttons: [
        DSButton.secondary(
          buttonText: 'Abbrechen',
          onPressed: () => widget.pop(false),
        ),
        DSButton.primary(
          buttonText: 'Behandlung erstellen',
          icon: DSIcons.add,
          onPressed: () => widget.pop(true),
        ),
      ],
      // A fixed height, matching Figma's own `Body` slot (707.375), rather
      // than [IntrinsicHeight]: [DSDentalChart] renders itself with a
      // `CustomScrollView`, which cannot report intrinsic dimensions, and
      // `DSModalDialog`'s default body wrapper hands `body` unbounded height
      // in the first place — [CrossAxisAlignment.stretch] needs one of the
      // two fixed for the vertical divider to size itself against its
      // siblings.
      body: SizedBox(
        height: _newTreatmentBodyHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildTreatmentDefinition(tokens),
              ),
            ),
            SizedBox(width: tokens.spacing.layout.m),
            const DSDivider.vertical(),
            SizedBox(width: tokens.spacing.layout.m),
            SizedBox(
              width: _sidebarWidth,
              child: _TreatmentOverview(
                option: switch (_selectedOption) {
                  final int i => MockData.treatmentOptions[i],
                  null => null,
                },
                selectedTeeth: _selectedTeeth,
                onClear: () => setState(() {
                  _closePopoverIfOpen();
                  _selectedOption = null;
                  _selectedTeeth.clear();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentDefinition(DSTokensData tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Behandlungsoption', style: tokens.text.textBase),
        SizedBox(height: tokens.spacing.component.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            // Three tiles per row regardless of the modal's width, per
            // Figma: two rows of the five options (3 + 2), rather than
            // [_optionTileWidth]'s fixed width, which only fits two.
            final double spacing = tokens.spacing.component.xs;
            final double tileWidth = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final (index, option) in MockData.treatmentOptions.indexed)
                  SizedBox(
                    width: tileWidth,
                    child: _TreatmentOptionTile(
                      option: option,
                      selected: _selectedOption == index,
                      onPressed: () => setState(() {
                        _closePopoverIfOpen();
                        _selectedOption = index;
                      }),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(height: tokens.spacing.layout.m),
        Text('Zahnposition', style: tokens.text.textBase),
        SizedBox(height: tokens.spacing.component.xs),
        DSNonModalPopupScope(
          key: _popupScopeKey,
          child: DSDentalChart(
            set: DSToothSet.permanent,
            // Figma's numbering (18…11, 21…28 / 48…41, 31…38) is FDI, not the
            // universal notation the rest of this prototype's read-only
            // charts use.
            notation: DSDentalNotation.fdi,
            selectedTeeth: _selectedTeeth.keys.toSet(),
            // No treatment option picked yet: there is nothing a tap could
            // record (see [_toothOptionsByLabel]), so the whole chart is
            // disabled rather than silently accepting taps that do nothing.
            disabledTeeth: _selectedOption == null
                ? _allPermanentTeeth
                : const {},
            onToothPressed:
                ({
                  required tooth,
                  required anchorKey,
                  required preferredPosition,
                }) {
                  // Tapping any tooth closes whichever popover is currently
                  // open — Figma shows only ever one at a time.
                  _closePopoverIfOpen();

                  final List<_ToothOption>? options = switch (_selectedOption) {
                    final int i =>
                      _toothOptionsByLabel[MockData.treatmentOptions[i].label],
                    null => null,
                  };
                  // Dentures and Splint (and no option picked yet) have no
                  // per-tooth condition to choose, so a tap just toggles the
                  // tooth in or out of the treatment — same as before this
                  // modal grew per-tooth popovers.
                  if (options == null) {
                    setState(() {
                      final bool wasSelected = _selectedTeeth.containsKey(
                        tooth,
                      );
                      _selectedTeeth.clear();
                      if (!wasSelected) _selectedTeeth[tooth] = null;
                    });
                    return;
                  }
                  _closeToothPopover = _popupScopeKey.currentState!
                      .anchoredPopover(
                        anchorKey: anchorKey,
                        preferredPosition: preferredPosition,
                        builder: (context, close) => DSPopoverContent(
                          title: tooth.fdiNumber,
                          onClose: () {
                            close();
                            _closeToothPopover = null;
                          },
                          body: _ToothOptionList(
                            options: options,
                            onSelected: (label) {
                              setState(() {
                                _selectedTeeth.clear();
                                _selectedTeeth[tooth] = label;
                              });
                              close();
                              _closeToothPopover = null;
                            },
                          ),
                        ),
                      );
                },
          ),
        ),
      ],
    );
  }
}

/// One tile of the "Treatment option" picker — a plain card rather than
/// [DSCompactCard]: the latest design gives it a fixed [_height] and a
/// transparent image area, neither of which fits that component's public
/// API — it locks the image to a 16:9 slot sized off the tile's width, and
/// always paints [DSTokensDataImageBackground] behind it.
class _TreatmentOptionTile extends StatelessWidget {
  const _TreatmentOptionTile({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final TreatmentOption option;
  final bool selected;
  final VoidCallback onPressed;

  static const double _height = 190;

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return SizedBox(
      height: _height,
      child: Material(
        color: selected
            ? tokens.surfaceSelected.standard
            : tokens.surface.standard,
        borderRadius: BorderRadius.circular(tokens.border.radius.standard),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.border.radius.standard),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(tokens.spacing.component.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                tokens.border.radius.standard,
              ),
              border: Border.all(
                color: selected
                    ? tokens.border.selectedStandard
                    : tokens.border.standard,
                width: tokens.border.width.standard,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: option.assetPath == null
                      ? const SizedBox.shrink()
                      : Center(
                          child: Image.asset(
                            option.assetPath!,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
                SizedBox(height: tokens.spacing.component.xs),
                Text(
                  option.label,
                  style: tokens.text.textBase,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of a tooth's popover — Figma nodes `41172-49404` (restoration),
/// `41172-49450` (aligner) and `41172-49480` (implant).
class _ToothOption {
  const _ToothOption(this.label, this.icon);

  final String label;
  final DSIconRef icon;
}

/// The per-tooth popover rows offered by each [TreatmentOption.label].
/// Restoration, Aligner and Implant are the only tiles Figma shows a popover
/// for; Dentures and Splint have no entry, so tapping a tooth under either
/// just toggles it in or out of the treatment instead of opening a popover.
const Map<String, List<_ToothOption>> _toothOptionsByLabel = {
  'Restauration': [
    _ToothOption('Krone', DSIcons.crown),
    _ToothOption('Inlay', DSIcons.inlay),
    _ToothOption('Onlay', DSIcons.onlay),
    _ToothOption('Veneer', DSIcons.veneer),
    _ToothOption('Brücke', DSIcons.bridge),
  ],
  'Aligner': [
    _ToothOption('Nicht bewegen', DSIcons.lock),
    _ToothOption('Fehlend', DSIcons.close),
    _ToothOption('Zu extrahieren', DSIcons.extract),
  ],
  'Implantat': [
    _ToothOption('Abutment', DSIcons.abutment),
    _ToothOption('Abutment + Krone', DSIcons.abutmentCrown),
    _ToothOption(
      'Implantatplanung / Chirurgische Schablone',
      DSIcons.surgicalGuide,
    ),
  ],
};

/// The stacked [DSButton.secondary] rows a tooth's popover shows, one per
/// [options] entry — a plain list rather than a dedicated DS menu widget,
/// since `lightning_core_ui` has no public "popover option list" component to
/// build these from.
class _ToothOptionList extends StatelessWidget {
  const _ToothOptionList({required this.options, required this.onSelected});

  final List<_ToothOption> options;

  /// Called with the picked option's [_ToothOption.label].
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options) ...[
          DSButton.secondary(
            buttonText: option.label,
            icon: option.icon,
            stretch: true,
            onPressed: () => onSelected(option.label),
          ),
          if (option != options.last)
            SizedBox(height: tokens.spacing.component.xs),
        ],
      ],
    );
  }
}

/// The "Treatment overview" panel of [_NewTreatmentModal].
///
/// Mirrors the Figma node's single summary card while [option] is picked,
/// listing [selectedTeeth] under it, together with the per-tooth sub-type
/// picked in that tooth's popover where [option] has one; shows nothing
/// below the heading while [option] is null, since there is nothing yet to
/// summarise.
class _TreatmentOverview extends StatelessWidget {
  const _TreatmentOverview({
    required this.option,
    required this.selectedTeeth,
    required this.onClear,
  });

  final TreatmentOption? option;
  final Map<DSTooth, String?> selectedTeeth;

  /// Empties both [option] and [selectedTeeth] — the trash icon Figma shows
  /// on the summary card.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);
    final TreatmentOption? option = this.option;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Behandlungsübersicht', style: tokens.text.headingXl),
        SizedBox(height: tokens.spacing.layout.s),
        if (option != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.spacing.component.m),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.border.standard),
              borderRadius: BorderRadius.circular(tokens.border.radius.large),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        option.label,
                        style: tokens.text.textLgStrong,
                      ),
                    ),
                    DSIcon(iconRef: DSIcons.chevronDown),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedTeeth.isEmpty
                            ? 'Keine Zähne ausgewählt'
                            : (selectedTeeth.entries.toList()..sort(
                                    (a, b) =>
                                        a.key.index.compareTo(b.key.index),
                                  ))
                                  .map(
                                    (entry) => entry.value == null
                                        ? entry.key.fdiNumber
                                        : '${entry.key.fdiNumber} '
                                              '(${entry.value})',
                                  )
                                  .join(', '),
                        style: tokens.text.textBase,
                      ),
                    ),
                    DSButton.tertiary(icon: DSIcons.trash, onPressed: onClear),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The "Use a previous scan as a reference" modal: a scrollable gallery of
/// [patient]'s media, via [MockData.referenceScanGroupsForPatient], beside a
/// preview of whichever scan is picked — Figma node `40184-58978`.
///
/// Picking a reference is optional, per the modal's own title: "Continue"
/// carries the flow forward whether or not a scan is selected. Only shown by
/// [showTreatmentScanFlow] when [patient] actually has media to offer.
class _SelectReferenceModal extends StatefulWidget {
  const _SelectReferenceModal({required this.pop, required this.patient});

  /// Closes the modal. `true` for "Continue", `false` for Cancel, the close
  /// button, or Escape.
  final Pop<bool> pop;

  /// Whose media backs the gallery — see [MockData.referenceScanGroupsForPatient].
  final Patient patient;

  @override
  State<_SelectReferenceModal> createState() => _SelectReferenceModalState();
}

class _SelectReferenceModalState extends State<_SelectReferenceModal> {
  /// The gallery's groups, built once rather than freshly on every build:
  /// [_selected] tracks its pick by identity (see [_buildGallery]'s
  /// `DSMediaTile.selected`), which only stays stable across rebuilds if
  /// the same [ReferenceScan] instances back the gallery throughout the
  /// modal's lifetime.
  late final List<ReferenceScanGroup> _groups =
      MockData.referenceScanGroupsForPatient(widget.patient);

  /// The picked scan, or null while none is — the pick is optional, but the
  /// modal opens with the gallery's first scan preselected rather than
  /// empty.
  ///
  /// [showTreatmentScanFlow] only shows this modal when [widget.patient] has
  /// media, so [_groups] always has at least this one scan to preselect.
  late ReferenceScan? _selected = _groups.first.scans.first;

  /// Which of the preview's view-angle toggle buttons is active.
  ///
  /// Cosmetic only: this click-through prototype has one flat image per scan,
  /// not a real 3D viewer to re-render from another angle.
  int _activeView = 0;

  @override
  Widget build(BuildContext context) {
    final DSTokensData tokens = DSTokens.of(context);

    // Two [_referenceTileWidth] columns, side by side — rather than
    // [_sidebarWidth], which fits only one at that width. The preview beside
    // it shrinks accordingly, since it takes whatever width this leaves.
    final double galleryWidth =
        _referenceTileWidth * 2 + tokens.spacing.layout.m;

    return DSModalDialog(
      variant: DSModalDialogVariant.large,
      title: 'Einen vorherigen Scan als Referenz verwenden (optional)',
      onClose: () => widget.pop(false),
      buttons: [
        DSButton.secondary(
          buttonText: 'Abbrechen',
          onPressed: () => widget.pop(false),
        ),
        DSButton.primary(
          buttonText: 'Weiter',
          onPressed: () => widget.pop(true),
        ),
      ],
      body: SizedBox(
        height: _referenceBodyHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: galleryWidth, child: _buildGallery(tokens)),
            SizedBox(width: tokens.spacing.layout.m),
            Expanded(child: _buildPreview(tokens)),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(DSTokensData tokens) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final group in _groups) ...[
            Text(group.title, style: tokens.text.textBaseStrong),
            SizedBox(height: tokens.spacing.component.xs),
            Wrap(
              spacing: tokens.spacing.layout.m,
              runSpacing: tokens.spacing.component.xs,
              children: [
                for (final scan in group.scans)
                  SizedBox(
                    width: _referenceTileWidth,
                    child: DSMediaTile(
                      title: scan.title,
                      subtitle: scan.timestamp,
                      imageProvider: AssetImage(scan.assetPath),
                      typeTagText: 'DI',
                      selected: identical(_selected, scan),
                      onSelectedChanged: (value) =>
                          setState(() => _selected = value ? scan : null),
                      onPressed: () => setState(() => _selected = scan),
                    ),
                  ),
              ],
            ),
            SizedBox(height: tokens.spacing.layout.m),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview(DSTokensData tokens) {
    final ReferenceScan? selected = _selected;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.background.standard,
        border: Border.all(color: tokens.border.standard),
        borderRadius: BorderRadius.circular(tokens.border.radius.standard),
      ),
      child: selected == null
          ? _buildEmptyPreview(tokens)
          : _buildScanPreview(tokens, selected),
    );
  }

  /// Figma node `33115:1659`: no scan picked yet.
  Widget _buildEmptyPreview(DSTokensData tokens) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Noch keine Vorschau',
            style: tokens.text.textLgStrong,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacing.component.xxs),
          Text(
            'Klicken Sie auf eine Datei, um hier eine Vorschau anzuzeigen.',
            style: tokens.text.textBase.copyWith(color: tokens.text.subdued),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Figma node `40258:775820`: the picked scan, its zoom controls, and the
  /// view-angle toggle — the zoom controls are inert, but the toggle picks
  /// which of [ReferenceScan.viewAssetPaths] is shown, per [_activeView].
  Widget _buildScanPreview(DSTokensData tokens, ReferenceScan scan) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.spacing.component.xl,
            80,
            tokens.spacing.component.xl,
            tokens.spacing.component.l,
          ),
          child: Center(
            child: Image.asset(
              scan.viewAssetPaths[_activeView],
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: tokens.spacing.layout.s,
          right: tokens.spacing.layout.s,
          child: _buildZoomControls(tokens),
        ),
        Positioned(
          top: tokens.spacing.layout.s,
          left: 0,
          right: 0,
          child: Center(child: _buildViewToggle(tokens)),
        ),
      ],
    );
  }

  Widget _buildZoomControls(DSTokensData tokens) {
    return DSFocusModeToolbar.vertical(
      groups: [
        DSFocusModeToolbarGroup(
          items: [
            DSButton.tertiary(icon: DSIcons.zoomIn, onPressed: () {}),
            DSButton.tertiary(icon: DSIcons.zoomOut, onPressed: () {}),
          ],
        ),
      ],
    );
  }

  /// The six view-angle buttons of Figma node `40258:775821`.
  static const List<DSIconRef> _viewIcons = [
    DSIcons.archUpper,
    DSIcons.buccalRight,
    DSIcons.buccalLeft,
    DSIcons.biteClosed,
    DSIcons.contactVisualisation,
    DSIcons.biteOpen,
  ];

  Widget _buildViewToggle(DSTokensData tokens) {
    return DSSegmentedControl<int>.withIcons(
      selectedValue: _activeView,
      onSegmentPressed: (value) => setState(() => _activeView = value),
      items: [
        for (final (index, icon) in _viewIcons.indexed)
          DSSegmentedControlItemWithIcon<int>(value: index, icon: icon),
      ],
    );
  }
}
