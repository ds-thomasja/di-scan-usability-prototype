import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../shell/app_shell.dart';

/// How the (empty) job list would be laid out, were there any jobs to show.
enum _ViewMode {
  /// A grid of tiles.
  grid,

  /// A table-like list.
  list,
}

/// The manufacturing job list page (`/jobs`).
///
/// The prototype has no `Job` model, so the single "Manufacturing" tab always
/// renders a plain "No items found" message — no card, no illustration,
/// matching the DS Core screen. The machine-type/status filters and the
/// grid/list toggle above it are purely cosmetic.
class JobsPage extends StatefulWidget {
  /// Creates the jobs page.
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  _ViewMode _viewMode = _ViewMode.list;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return AppShell(
      selectedItem: AppShellItem.jobs,
      bodySlivers: [
        DSSliverScrollablePage.withTabs(
          title: 'Aufträge',
          subtitle: 'Finden Sie hier alle Ihre Aufträge und deren Details.',
          tabbedScrollableViews: [
            DSScrollableTabbedView(
              title: 'Fertigung',
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const _InertFilterButton(label: 'Maschinentyp'),
                      const DSSpacing.componentM(),
                      const _InertFilterButton(label: 'Status'),
                      const Spacer(),
                      DSSegmentedControl<_ViewMode>.withIcons(
                        items: [
                          DSSegmentedControlItemWithIcon(
                            value: _ViewMode.grid,
                            icon: DSIcons.tiles,
                            tooltip: 'Rasteransicht',
                          ),
                          DSSegmentedControlItemWithIcon(
                            value: _ViewMode.list,
                            icon: DSIcons.list,
                            tooltip: 'Listenansicht',
                          ),
                        ],
                        selectedValue: _viewMode,
                        onSegmentPressed: (value) =>
                            setState(() => _viewMode = value),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: tokens.spacing.layout.xs),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: tokens.spacing.layout.xl,
                    ),
                    child: Center(
                      child: DSText(
                        'Keine Einträge gefunden',
                        style: tokens.text.textBase
                            .copyWith(color: tokens.text.subdued),
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

/// A tertiary [DSSelectionButton] rendered purely for visual fidelity.
///
/// It is given a single option — its own label — so opening the menu never
/// changes the caption and no filtering is implied.
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
