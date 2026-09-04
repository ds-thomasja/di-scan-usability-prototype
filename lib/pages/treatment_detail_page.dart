import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../components/media_grid/media_grid.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../flows/capture_scan.dart';
import '../shell/app_shell.dart';

/// Width of the right-hand "quick view" panel (Activities / Notes).
///
/// A layout decision taken from the Figma frame rather than a design token:
/// the DS design system exposes no token for an inline docked side panel.
const double _quickViewPanelWidth = 320;

/// Height of the right-hand "quick view" panel.
///
/// [DSTabbedViews] renders its body through a `SizedBox.expand`, so it must be
/// given a bounded height. The value approximates the card height in the Figma
/// frame.
const double _quickViewPanelHeight = 260;

/// The treatment detail page: `/treatments/<id>`.
///
/// Shows a treatment header (back link to the patient, title, subtitle,
/// inert actions), a patient/treatment summary card and four tabs. The
/// **Details** tab carries the treatment definition (tooth chart +
/// Implantology section); the other three are empty states because the
/// prototype has no data model for media, orders or manufacturing.
///
/// A quick-view panel (Activities / Notes) is docked to the right of the tab
/// content.
class TreatmentDetailPage extends StatelessWidget {
  /// Creates the treatment detail page for the treatment with [treatmentId].
  const TreatmentDetailPage({required this.treatmentId, super.key});

  /// The id of the treatment to display, as passed by the router.
  final String treatmentId;

  @override
  Widget build(BuildContext context) {
    final treatment = MockData.treatmentById(treatmentId);

    if (treatment == null) {
      return const AppShell(
        selectedItem: AppShellItem.treatments,
        bodySlivers: [
          SliverToBoxAdapter(
            child: Center(child: Text('Behandlung nicht gefunden')),
          ),
        ],
      );
    }

    void goToPatient() => context.go(AppRoutes.patient(treatment.patientId));

    return AppShell(
      selectedItem: AppShellItem.treatments,
      bodySlivers: [
        DSSliverScrollablePage.withTabs(
          title: treatment.title,
          subtitle:
              'Erstellt am ${treatment.createdOn} von ${treatment.createdBy}',
          // The Figma frame labels the back button with the patient's name.
          backButtonText: treatment.patientName,
          onBackPressed: goToPatient,
          actions: [
            // "Aufnehmen" > "Scan" opens the device-selection modal;
            // every other header action is inert in this click-through
            // prototype.
            DSActionsButton.secondary(
              buttonText: 'Aufnehmen',
              actions: [
                [
                  DSAction(
                    title: 'Scan',
                    icon: DSIcons.deviceDSPrimescan,
                    onTrigger: () => showCaptureScanModal(
                      context,
                      patient: MockData.patientById(treatment.patientId),
                      fromTreatmentDetail: true,
                    ),
                  ),
                  DSAction(
                    title: 'X-Ray',
                    icon: DSIcons.deviceDSXRay,
                    onTrigger: () {},
                  ),
                ],
              ],
            ),
            DSButton.secondary(
              buttonText: 'Erstellen',
              icon: DSIcons.chevronDown,
              iconLeft: false,
              onPressed: () {},
            ),
            DSButton.secondary(
              buttonText: 'Canvas',
              icon: DSIcons.canvas,
              onPressed: () {},
            ),
            DSButton.tertiary(
              icon: DSIcons.dotsHorizontal,
              tooltip: 'Weitere Aktionen',
              onPressed: () {},
            ),
          ],
          detailsContent: _SummaryCard(
            treatment: treatment,
            onPatientPressed: goToPatient,
          ),
          tabbedScrollableViews: [
            DSScrollableTabbedView(
              title: 'Details',
              slivers: [
                SliverToBoxAdapter(
                  child: _TabBodyWithQuickView(
                    treatment: treatment,
                    content: _TreatmentDefinition(treatment: treatment),
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Medien',
              slivers: [
                SliverToBoxAdapter(
                  child: _TabBodyWithQuickView(
                    treatment: treatment,
                    content: _MediaTabContent(media: treatment.media),
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Bestellungen',
              slivers: [
                SliverToBoxAdapter(
                  child: _TabBodyWithQuickView(
                    treatment: treatment,
                    content: const DSContainer(
                      child: DSEmptyState(
                        size: DSEmptyStateSize.large,
                        headline: 'Noch keine Bestellungen',
                        body:
                            'Für diese Behandlung aufgegebene Bestellungen '
                            'werden hier angezeigt.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Fertigung',
              slivers: [
                SliverToBoxAdapter(
                  child: _TabBodyWithQuickView(
                    treatment: treatment,
                    content: const DSContainer(
                      child: DSEmptyState(
                        size: DSEmptyStateSize.large,
                        headline: 'Noch keine Fertigungsdaten',
                        body:
                            'Fertigungsaufträge für diese Behandlung '
                            'werden hier angezeigt.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The Patient / Treatment summary shown directly under the page subtitle.
///
/// Rendered into [DSSliverScrollablePage.detailsContent], which already wraps
/// it in a [DSContainer], so no extra surface decoration is applied here.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.treatment, required this.onPatientPressed});

  final Treatment treatment;
  final VoidCallback onPatientPressed;

  /// Derives avatar initials from a `Last, First` formatted name.
  String get _initials {
    final parts = treatment.patientName
        .split(RegExp(r'[,\s]+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    // `Castaneda, Izzy` -> `IC` (given name first, then family name).
    return '${parts[1].characters.first}${parts[0].characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DSAvatar(text: _initials),
                SizedBox(width: tokens.spacing.component.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Patient', style: tokens.text.textBaseStrong),
                      SizedBox(height: tokens.spacing.component.xxs),
                      DSLinkWidget(
                        text: treatment.patientName,
                        onPressed: onPatientPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacing.layout.m),
          const DSDivider.vertical(),
          SizedBox(width: tokens.spacing.layout.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Behandlung', style: tokens.text.textBaseStrong),
                SizedBox(height: tokens.spacing.component.xxs),
                Text(treatment.title, style: tokens.text.textBase),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Medias" tab body: the same media grid the patient detail page's
/// Media tab shows, scoped to [Treatment.media].
///
/// [MediaGridSliver] is a sliver widget, so it is wrapped in a `shrinkWrap`
/// [CustomScrollView] here rather than placed directly in [content] — this
/// tab's slot is a box context (the [_TabBodyWithQuickView] row), not a
/// sliver one.
class _MediaTabContent extends StatelessWidget {
  const _MediaTabContent({required this.media});

  final List<MediaItem> media;

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const DSContainer(
        child: DSEmptyState(
          size: DSEmptyStateSize.large,
          headline: 'Noch keine Medien',
          body:
              'Für diese Behandlung erfasste Scans und Bilder werden '
              'hier angezeigt.',
        ),
      );
    }

    final tokens = DSTokens.of(context);

    return DSContainer(
      child: CustomScrollView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: MediaSectionHeading(label: 'Medien', count: media.length),
          ),
          SliverToBoxAdapter(child: SizedBox(height: tokens.spacing.layout.s)),
          MediaGridSliver(media: media),
        ],
      ),
    );
  }
}

/// Lays out a tab's [content] with the quick-view panel docked to its right.
class _TabBodyWithQuickView extends StatelessWidget {
  const _TabBodyWithQuickView({required this.treatment, required this.content});

  final Treatment treatment;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: content),
        SizedBox(width: tokens.spacing.layout.s),
        SizedBox(
          width: _quickViewPanelWidth,
          child: _QuickViewPanel(treatment: treatment),
        ),
      ],
    );
  }
}

/// The right-hand quick-view panel with the Activities and Notes tabs.
class _QuickViewPanel extends StatelessWidget {
  const _QuickViewPanel({required this.treatment});

  final Treatment treatment;

  @override
  Widget build(BuildContext context) => DSContainer(
    child: SizedBox(
      height: _quickViewPanelHeight,
      child: DSTabbedViews(
        tabbedViews: [
          DSTabbedView(
            title: 'Aktivitäten',
            child: _ActivitiesTimeline(activities: treatment.activities),
          ),
          DSTabbedView(
            title: 'Notizen',
            child: const SingleChildScrollView(
              child: DSEmptyState(
                size: DSEmptyStateSize.small,
                headline: 'Noch keine Notizen',
                body:
                    'Zu dieser Behandlung hinzugefügte Notizen werden '
                    'hier angezeigt.',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// A vertical timeline of [ActivityEntry]s.
class _ActivitiesTimeline extends StatelessWidget {
  const _ActivitiesTimeline({required this.activities});

  final List<ActivityEntry> activities;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    if (activities.isEmpty) {
      return const SingleChildScrollView(
        child: DSEmptyState(
          size: DSEmptyStateSize.small,
          headline: 'Noch keine Aktivitäten',
          body: 'Änderungen an dieser Behandlung werden hier angezeigt.',
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.component.m),
      itemCount: activities.length,
      separatorBuilder: (_, _) => SizedBox(height: tokens.spacing.component.m),
      itemBuilder: (_, index) {
        final activity = activities[index];
        // `IntrinsicHeight` gives this Row a bounded height (the natural
        // height of the text column), which the rail's `Expanded` divider
        // needs — without it, the divider sits inside an unbounded-height
        // Column (each `ListView` item otherwise offers infinite height) and
        // throws "RenderFlex children have non-zero flex but incoming height
        // constraints are unbounded".
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The timeline rail: a dot on a subdued vertical line.
              SizedBox(
                width: tokens.spacing.component.s,
                child: Column(
                  children: [
                    DSIcon.small(
                      iconRef: DSIcons.circleFilled,
                      color: tokens.text.subdued,
                    ),
                    const Expanded(child: DSDivider.vertical()),
                  ],
                ),
              ),
              SizedBox(width: tokens.spacing.component.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(activity.title, style: tokens.text.textBaseStrong),
                    SizedBox(height: tokens.spacing.component.xxs),
                    Text(
                      '${activity.author} · ${activity.timestamp}',
                      style: tokens.text.textSm.copyWith(
                        color: tokens.text.subdued,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The "Treatment definition" panel of the Details tab.
class _TreatmentDefinition extends StatelessWidget {
  const _TreatmentDefinition({required this.treatment});

  final Treatment treatment;

  /// Maps [Treatment.selectedTeeth] onto [DSTooth]s.
  ///
  /// The chart is rendered in universal notation (matching the Figma frame:
  /// 1-16 upper, 32-17 lower), so the stored integers are read as universal
  /// tooth numbers. Values with no universal counterpart are skipped rather
  /// than throwing.
  Set<DSTooth> get _selectedTeeth {
    final teeth = <DSTooth>{};
    for (final number in treatment.selectedTeeth) {
      try {
        teeth.add(DSTooth.fromUniversal('$number'));
      } on RangeError {
        // Unknown tooth number in the mock data - ignore it.
        continue;
      }
    }
    return teeth;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return DSContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Behandlungsdefinition',
                  style: tokens.text.headingBase,
                ),
              ),
              // Inert in this prototype.
              DSButton.secondary(buttonText: 'Bearbeiten', onPressed: () {}),
            ],
          ),
          SizedBox(height: tokens.spacing.layout.s),
          // The chart's intrinsic width (16 teeth per arch) is wider than the
          // space left beside the docked quick-view panel, so it's wrapped in
          // a horizontal scroll view rather than letting it clip/overflow.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DSDentalChart.readOnly(
              set: DSToothSet.permanent,
              notation: DSDentalNotation.universal,
              selectedTeeth: _selectedTeeth,
              stretch: false,
            ),
          ),
          SizedBox(height: tokens.spacing.layout.s),
          DSAccordion(
            items: [
              DSAccordionItem(
                title: 'Implantologie',
                expandableContent: _ImplantologySection(treatment: treatment),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The expandable "Implantology" section under the tooth chart.
///
/// The content is static: the radio option is preselected and the two
/// dropzones are inert (no upload flow exists in this prototype).
class _ImplantologySection extends StatelessWidget {
  const _ImplantologySection({required this.treatment});

  final Treatment treatment;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    final teethLabel = treatment.selectedTeeth.isEmpty
        ? 'Implantat'
        : 'Implantat · ${treatment.selectedTeeth.join(', ')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(teethLabel, style: tokens.text.textBaseStrong),
            ),
            DSButton.tertiary(
              icon: DSIcons.trash,
              tooltip: 'Entfernen',
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.component.m),
        DSRadio<int>(
          value: 0,
          groupValue: 0,
          label: 'CBCT- und DI-Scan hinzufügen',
          info:
              'Durch Hinzufügen eines DI-Scans können Sie eine '
              'chirurgische Schablone erstellen.',
          maxLines: 2,
          // Inert: the single option is always selected.
          onChanged: (_) {},
        ),
        SizedBox(height: tokens.spacing.component.m),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              child: _ScanDropSlot(title: 'CBCT-Scan', formats: 'Format: DCM'),
            ),
            _ScanDropSlotGap(),
            Expanded(
              child: _ScanDropSlot(title: 'DI-Scan', formats: 'Formate: DXD'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Spacing between the two scan drop slots, as a widget so the surrounding
/// `children` list can stay `const`.
class _ScanDropSlotGap extends StatelessWidget {
  const _ScanDropSlotGap();

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: DSTokens.of(context).spacing.component.m);
}

/// A labelled, inert file-drop slot.
class _ScanDropSlot extends StatelessWidget {
  const _ScanDropSlot({required this.title, required this.formats});

  final String title;
  final String formats;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: tokens.text.textBase),
        SizedBox(height: tokens.spacing.component.xxs),
        Text(
          formats,
          style: tokens.text.textSm.copyWith(color: tokens.text.subdued),
        ),
        SizedBox(height: tokens.spacing.component.s),
        // Inert: `onPressed` is supplied so the widget does not open the
        // browser's file picker, and `onDrop` intentionally does nothing.
        DSDropzoneDedicated(onDrop: (_, _) {}, onPressed: () {}),
      ],
    );
  }
}
