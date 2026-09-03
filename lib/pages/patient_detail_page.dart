import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../components/media_grid/media_grid.dart';
import '../data/mock_data.dart';
import '../flows/capture_scan.dart';
import '../shell/app_shell.dart';

/// The patient detail page: header with inert actions plus four tabs
/// (Media / Orders / Collaboration / Treatments).
///
/// Only the Media tab carries content — a grid of [DSMediaTile]s built from
/// [Patient.media]. The remaining tabs render a [DSEmptyState] because the
/// prototype has no order, collaboration or cross-linked treatment data.
///
/// "Capture scan" opens the "Select device" modal (see [showCaptureScanModal]).
/// Every other header action and every Media-tab toolbar control is
/// deliberately inert (`onPressed: () {}`): no upload, filter or sort flow
/// exists in this click-through prototype.
class PatientDetailPage extends StatelessWidget {
  /// Creates the detail page for the patient identified by [patientId].
  const PatientDetailPage({required this.patientId, super.key});

  /// The id of the patient to display, as passed by the router.
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final patient = MockData.patientById(patientId);

    if (patient == null) {
      return AppShell(
        selectedItem: AppShellItem.patients,
        bodySlivers: [
          SliverToBoxAdapter(
            child: DSEmptyState(
              size: DSEmptyStateSize.large,
              headline: 'Patient nicht gefunden',
              body: 'Es gibt keinen Patienten mit der ID "$patientId".',
              illustration: DSSpotIllustrations.patients,
              actions: [
                DSButton.primary(
                  buttonText: 'Zurück zu Patienten',
                  onPressed: () => context.go(AppRoutes.patients),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return AppShell(
      selectedItem: AppShellItem.patients,
      bodySlivers: [
        DSSliverScrollablePage.withTabs(
          title: patient.name,
          subtitle: patient.dateOfBirth,
          onBackPressed: () => context.go(AppRoutes.patients),
          backButtonText: 'Patienten',
          actions: _headerActions(context),
          tabbedScrollableViews: [
            DSScrollableTabbedView(
              title: 'Medien',
              slivers: [
                SliverToBoxAdapter(child: _MediaToolbar()),
                SliverToBoxAdapter(child: _LayoutSGap()),
                DSSliversContainer(
                  slivers: [
                    SliverToBoxAdapter(
                      child: MediaSectionHeading(
                        label: 'Letzte 3 Monate',
                        count: patient.media.length,
                      ),
                    ),
                    SliverToBoxAdapter(child: _LayoutSGap()),
                    MediaGridSliver(media: patient.media),
                  ],
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Bestellungen',
              slivers: [
                SliverToBoxAdapter(
                  child: DSEmptyState(
                    size: DSEmptyStateSize.large,
                    headline: 'Noch keine Bestellungen',
                    body: 'Für diesen Patienten erstellte Bestellungen '
                        'werden hier angezeigt.',
                    illustration: DSSpotIllustrations.orders,
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Zusammenarbeit',
              slivers: [
                SliverToBoxAdapter(
                  child: DSEmptyState(
                    size: DSEmptyStateSize.large,
                    headline: 'Noch keine Zusammenarbeit',
                    body:
                        'Mit Kollegen oder Laboren geteilte Fälle werden '
                        'hier angezeigt.',
                    illustration: DSSpotIllustrations.collaboration,
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Behandlungen',
              slivers: [
                SliverToBoxAdapter(
                  child: DSEmptyState(
                    size: DSEmptyStateSize.large,
                    headline: 'Noch keine Behandlungen',
                    body:
                        'Für diesen Patienten geplante Behandlungen werden '
                        'hier angezeigt.',
                    illustration: DSSpotIllustrations.treatments,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// The page-header action buttons. All but "Capture scan" are visually
  /// enabled but inert.
  List<Widget> _headerActions(BuildContext context) => [
    DSButton.secondary(
      buttonText: 'Scan aufnehmen',
      icon: DSIcons.deviceDSPrimescan,
      onPressed: () => showCaptureScanModal(context),
    ),
    DSActionsButton.secondary(
      buttonText: 'Erstellen',
      actions: [
        [
          DSAction(
            title: 'Behandlung',
            icon: DSIcons.treatment,
            onTrigger: () {},
          ),
          DSAction(
            title: 'Bestellung',
            icon: DSIcons.shoppingCart,
            onTrigger: () {},
          ),
        ],
      ],
    ),
    DSButton.secondary(
      buttonText: 'Canvas',
      icon: DSIcons.canvas,
      onPressed: () {},
    ),
    DSActionsButton.iconTertiary(
      icon: DSIcons.dotsHorizontal,
      tooltip: 'Weitere Aktionen',
      actions: [
        [
          DSAction(
            title: 'Patient bearbeiten',
            icon: DSIcons.edit,
            onTrigger: () {},
          ),
          DSAction(title: 'Freigeben', icon: DSIcons.share, onTrigger: () {}),
        ],
        [
          DSAction(
            title: 'Patient archivieren',
            icon: DSIcons.archive,
            onTrigger: () {},
          ),
        ],
      ],
    ),
  ];
}

/// The cosmetic toolbar above the media grid: search, filter, sort, upload.
///
/// Nothing here is wired up — there is no filtering, sorting or upload flow in
/// the prototype. The controls exist so the screen matches the Figma design.
class _MediaToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.spacing.component.m,
      runSpacing: tokens.spacing.component.s,
      children: [
        SizedBox(
          width: 320,
          child: DSSearchField<void>(hintText: 'Suchen', onSearch: (_) {}),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: tokens.spacing.component.s,
          runSpacing: tokens.spacing.component.xs,
          children: [
            DSButton.tertiary(
              buttonText: 'Alles anzeigen',
              icon: DSIcons.chevronDown,
              iconLeft: false,
              onPressed: () {},
            ),
            DSButton.tertiary(
              buttonText: 'Neu nach alt',
              icon: DSIcons.chevronDown,
              iconLeft: false,
              onPressed: () {},
            ),
            DSButton.secondary(
              buttonText: 'Medien hochladen',
              icon: DSIcons.upload,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

/// A vertical gap of `spacing.layout.s`, for use inside sliver lists where
/// [DSSpacing] (which requires a [Flex] parent) cannot be used.
class _LayoutSGap extends StatelessWidget {
  const _LayoutSGap();

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: DSTokens.of(context).spacing.layout.s);
}
