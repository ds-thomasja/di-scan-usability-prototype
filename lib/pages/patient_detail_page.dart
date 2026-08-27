import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../shell/app_shell.dart';

/// The patient detail page: header with inert actions plus four tabs
/// (Media / Orders / Collaboration / Treatments).
///
/// Only the Media tab carries content — a grid of [DSMediaTile]s built from
/// [Patient.media]. The remaining tabs render a [DSEmptyState] because the
/// prototype has no order, collaboration or cross-linked treatment data.
///
/// Every header action and every Media-tab toolbar control is deliberately
/// inert (`onPressed: () {}`): no capture, upload, filter or sort flow exists
/// in this click-through prototype.
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
              headline: 'Patient not found',
              body: 'There is no patient with the id "$patientId".',
              illustration: DSSpotIllustrations.patients,
              actions: [
                DSButton.primary(
                  buttonText: 'Back to patients',
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
          backButtonText: 'Patients',
          actions: _headerActions(),
          tabbedScrollableViews: [
            DSScrollableTabbedView(
              title: 'Media',
              slivers: [
                SliverToBoxAdapter(child: _MediaToolbar()),
                SliverToBoxAdapter(child: _LayoutSGap()),
                DSSliversContainer(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _SectionHeading(
                        label: 'Last 3 months',
                        count: patient.media.length,
                      ),
                    ),
                    SliverToBoxAdapter(child: _LayoutSGap()),
                    _MediaGridSliver(media: patient.media),
                  ],
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Orders',
              slivers: [
                SliverToBoxAdapter(
                  child: DSEmptyState(
                    size: DSEmptyStateSize.large,
                    headline: 'No orders yet',
                    body: 'Orders created for this patient will show up here.',
                    illustration: DSSpotIllustrations.orders,
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Collaboration',
              slivers: [
                SliverToBoxAdapter(
                  child: DSEmptyState(
                    size: DSEmptyStateSize.large,
                    headline: 'No collaboration yet',
                    body:
                        'Cases shared with colleagues or labs will show up '
                        'here.',
                    illustration: DSSpotIllustrations.collaboration,
                  ),
                ),
              ],
            ),
            DSScrollableTabbedView(
              title: 'Treatments',
              slivers: [
                SliverToBoxAdapter(
                  child: DSEmptyState(
                    size: DSEmptyStateSize.large,
                    headline: 'No treatments yet',
                    body:
                        'Treatments planned for this patient will show up '
                        'here.',
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

  /// The page-header action buttons. All are visually enabled but inert.
  List<Widget> _headerActions() => [
    DSButton.secondary(
      buttonText: 'Capture scan',
      icon: DSIcons.scanUpperJaw,
      onPressed: () {},
    ),
    DSActionsButton.secondary(
      buttonText: 'Create',
      actions: [
        [
          DSAction(
            title: 'Treatment',
            icon: DSIcons.treatment,
            onTrigger: () {},
          ),
          DSAction(
            title: 'Order',
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
      tooltip: 'More actions',
      actions: [
        [
          DSAction(title: 'Edit patient', icon: DSIcons.edit, onTrigger: () {}),
          DSAction(title: 'Share', icon: DSIcons.share, onTrigger: () {}),
        ],
        [
          DSAction(
            title: 'Archive patient',
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
          child: DSSearchField<void>(hintText: 'Search', onSearch: (_) {}),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: tokens.spacing.component.s,
          runSpacing: tokens.spacing.component.xs,
          children: [
            DSButton.tertiary(
              buttonText: 'Show everything',
              icon: DSIcons.chevronDown,
              iconLeft: false,
              onPressed: () {},
            ),
            DSButton.tertiary(
              buttonText: 'New to old',
              icon: DSIcons.chevronDown,
              iconLeft: false,
              onPressed: () {},
            ),
            DSButton.secondary(
              buttonText: 'Upload media',
              icon: DSIcons.upload,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

/// The "Last 3 months (7)" group heading above the media grid.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(child: DSText(label, style: tokens.text.headingBase)),
        SizedBox(width: tokens.spacing.component.xxs),
        DSText(
          '($count)',
          style: tokens.text.textLg.copyWith(color: tokens.text.subdued),
        ),
      ],
    );
  }
}

/// The responsive grid of media tiles, owning the tile selection state.
///
/// Selection is the one genuinely interactive part of this tab: the checkbox
/// on each tile toggles, and once anything is selected a plain tap on a tile
/// toggles it too (DS multi-select behaviour). Everything else is inert.
class _MediaGridSliver extends StatefulWidget {
  const _MediaGridSliver({required this.media});

  final List<MediaItem> media;

  @override
  State<_MediaGridSliver> createState() => _MediaGridSliverState();
}

class _MediaGridSliverState extends State<_MediaGridSliver> {
  final Set<int> _selected = <int>{};

  void _toggle(int index, bool value) => setState(() {
    if (value) {
      _selected.add(index);
    } else {
      _selected.remove(index);
    }
  });

  @override
  Widget build(BuildContext context) => DSMediaTileSliverGrid(
    tileCount: widget.media.length,
    tileBuilder: (context, index) {
      final item = widget.media[index];
      return DSMediaTile(
        title: item.title,
        subtitle: item.timestamp,
        typeTagText: item.tag,
        // MediaItem.assetPath points at files that do not exist in this
        // prototype, so no imageProvider/imageWidget is supplied. DSMediaTile
        // then renders its own token-styled placeholder surface with the
        // icon below, and no asset load is ever attempted.
        placeholderParams: DSMediaTilePlaceholderParams(
          icon: _placeholderIconFor(item.tag),
        ),
        selected: _selected.contains(index),
        selectionMode: _selected.isNotEmpty,
        onSelectedChanged: (value) => _toggle(index, value),
        onPressed: () {},
        actions: [
          [
            DSAction(
              title: 'Open in Canvas',
              icon: DSIcons.canvas,
              onTrigger: () {},
            ),
            DSAction(
              title: 'Download',
              icon: DSIcons.download,
              onTrigger: () {},
            ),
            DSAction(title: 'Share', icon: DSIcons.share, onTrigger: () {}),
          ],
          [
            DSAction(
              title: 'Delete',
              icon: DSIcons.trash,
              destructive: true,
              onTrigger: () {},
            ),
          ],
        ],
      );
    },
  );

  /// Picks a placeholder icon from the tile's tag, e.g. `DI · 7`, `PHOTO · 12`.
  static DSIconRef _placeholderIconFor(String? tag) =>
      (tag ?? '').toUpperCase().startsWith('PHOTO')
      ? DSIcons.image
      : DSIcons.jawFull;
}

/// A vertical gap of `spacing.layout.s`, for use inside sliver lists where
/// [DSSpacing] (which requires a [Flex] parent) cannot be used.
class _LayoutSGap extends StatelessWidget {
  const _LayoutSGap();

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: DSTokens.of(context).spacing.layout.s);
}
