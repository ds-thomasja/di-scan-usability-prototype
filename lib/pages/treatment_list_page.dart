import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../shell/app_shell.dart';

/// The treatment list page (`/treatments`).
///
/// Shows every [Treatment] in [MockData] as a DS table. Typing in the search
/// field filters the list case-insensitively by [Treatment.id]; that is the
/// only piece of real interactivity on this page besides row navigation.
///
/// The filter/sort controls in the toolbar are deliberately inert — the
/// prototype has no service/teeth taxonomy to filter against — and so is the
/// "New treatment" button and the per-row kebab menu.
class TreatmentListPage extends StatefulWidget {
  /// Creates the treatment list page.
  const TreatmentListPage({super.key});

  @override
  State<TreatmentListPage> createState() => _TreatmentListPageState();
}

class _TreatmentListPageState extends State<TreatmentListPage> {
  /// Owned here rather than left to [DSSearchField]'s internal hook, so the
  /// typed text is guaranteed to survive the `setState` rebuilds this page
  /// triggers on every keystroke.
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Frontend input handling: the raw query is trimmed and lower-cased before
  /// it is matched, so leading/trailing whitespace and casing are ignored.
  void _onSearch(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == _query) return;
    setState(() => _query = normalized);
  }

  List<Treatment> get _visibleTreatments {
    if (_query.isEmpty) return MockData.treatments;
    return MockData.treatments
        .where((t) => t.id.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final treatments = _visibleTreatments;

    return AppShell(
      selectedItem: AppShellItem.treatments,
      bodySlivers: [
        DSSliverScrollablePage(
          title: 'Treatments',
          subtitle: 'Manage all of your treatments from one place.',
          actions: [
            // Inert: the prototype has no create-treatment flow. A null
            // `onPressed` would render the button disabled, which is not what
            // the design shows.
            DSButton.primary(
              buttonText: 'New treatment',
              icon: DSIcons.add,
              onPressed: () {},
            ),
          ],
          detailsContent: _TreatmentListToolbar(
            searchController: _searchController,
            onSearch: _onSearch,
            resultCount: treatments.length,
          ),
          bodySlivers: [
            if (treatments.isEmpty)
              DSSliversContainer(
                slivers: [
                  SliverToBoxAdapter(
                    child: DSEmptyState(
                      size: DSEmptyStateSize.large,
                      headline: 'No treatments found',
                      body: 'No treatment matches the treatment ID you '
                          'searched for. Try a different ID.',
                      illustration: DSSpotIllustrations.treatments,
                    ),
                  ),
                ],
              )
            else
              // DSSliverTable applies the DSSliversContainer card decoration
              // itself, so it needs no extra wrapper here.
              DSSliverTable(
                columns: const [
                  DSTableColumn(title: 'Patient'),
                  DSTableColumn(title: 'Treatment ID'),
                  DSTableColumn(title: 'Service'),
                  DSTableColumn(title: 'Teeth'),
                  DSTableColumn(title: 'Created on'),
                  DSTableColumn(title: 'Created by'),
                  DSTableColumn(title: 'Last activity'),
                ],
                rows: [
                  for (final treatment in treatments)
                    DSTableRow(
                      onTap: () =>
                          context.go(AppRoutes.treatment(treatment.id)),
                      // `visibleActionButtons` defaults to 0, so every action
                      // is folded into the trailing kebab menu — matching the
                      // action column in the design.
                      actions: [
                        DSAction(
                          title: 'View details',
                          icon: DSIcons.open,
                          onTrigger: () {},
                        ),
                      ],
                      cells: [
                        DSTableCell.text(text: treatment.patientName),
                        DSTableCell.text(text: treatment.id),
                        DSTableCell.text(text: treatment.service),
                        DSTableCell.tag(text: treatment.teeth),
                        DSTableCell.text(text: treatment.createdOn),
                        DSTableCell.text(text: treatment.createdBy),
                        DSTableCell.text(text: treatment.lastActivity),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// The search + filter bar rendered between the page header and the table.
///
/// Only the search field is wired up; the four selection buttons are visual
/// placeholders (see [_InertFilterButton]).
class _TreatmentListToolbar extends StatelessWidget {
  const _TreatmentListToolbar({
    required this.searchController,
    required this.onSearch,
    required this.resultCount,
  });

  /// Not a design token: a plain layout width chosen to match the search field
  /// proportions in the Figma reference. The DS system has no token for this.
  static const double _searchFieldWidth = 300;

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);
    final region = DSRegion.of(context);

    final countLabel = '${region.formatDecimal(resultCount)} '
        '${resultCount == 1 ? 'treatment' : 'treatments'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: _searchFieldWidth,
            child: DSSearchField<String>(
              controller: searchController,
              hintText: 'Search by Treatment ID',
              // `onChanged` filters live while typing; `onSearch` covers the
              // enter key and the clear (x) button, which submits an empty
              // string.
              onChanged: onSearch,
              onSearch: onSearch,
            ),
          ),
        ),
        const DSSpacing.layoutXs(),
        Row(
          children: [
            const _InertFilterButton(label: 'All services'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Teeth'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Creation date'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Last activity'),
            const Spacer(),
            DSText(
              countLabel,
              style: tokens.text.textSm.copyWith(color: tokens.text.subdued),
            ),
          ],
        ),
      ],
    );
  }
}

/// A tertiary [DSSelectionButton] rendered purely for visual fidelity.
///
/// It is given a single option — its own label — so opening the menu never
/// changes the caption and no filtering is implied. The prototype's mock data
/// has no service/teeth/date taxonomy to filter against.
class _InertFilterButton extends StatelessWidget {
  const _InertFilterButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DSSelectionButton<String>.tertiary(
        options: [
          [DSSelectionButtonOption(value: label, title: label)],
        ],
        value: label,
        onChanged: (_) {},
      );
}
