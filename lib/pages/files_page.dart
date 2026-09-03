import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../shell/app_shell.dart';

/// The unassigned-files page (`/files`).
///
/// The prototype has no unassigned uploads, so this always renders the
/// "no unassigned files" empty state below a search field, a "select all"
/// checkbox and two inert sort/filter pills. "Go to home page" is the only
/// working control on the page.
class FilesPage extends StatelessWidget {
  /// Creates the files page.
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
        selectedItem: AppShellItem.files,
        bodySlivers: [
          DSSliverScrollablePage(
            title: 'Dateien',
            subtitle: 'Dateien Patienten zuordnen.',
            detailsContent: const _FilesToolbar(),
            bodySlivers: [
              DSSliversContainer(
                slivers: [
                  SliverToBoxAdapter(
                    child: DSEmptyState(
                      size: DSEmptyStateSize.large,
                      headline: 'Keine nicht zugeordneten Dateien gefunden.',
                      body: 'Sie können den automatischen Abgleich '
                          'verbessern, indem Sie den Namen des Patienten, '
                          'die Patienten-ID und das Geburtsdatum exakt so '
                          'verwenden, wie sie beim Erfassen des Scans auf '
                          'Ihrem CEREC- oder CONNECT-Gerät in Ihrem '
                          'Praxisverwaltungssystem angezeigt wurden.',
                      illustration: DSSpotIllustrations.media,
                      actions: [
                        DSButton.secondary(
                          buttonText: 'Zur Startseite',
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}

/// The search + filter bar rendered between the page header and the empty
/// state card.
///
/// Every control here is a visual placeholder: the prototype has no files to
/// search, filter or select.
class _FilesToolbar extends StatelessWidget {
  const _FilesToolbar();

  static const double _searchFieldWidth = 400;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: _searchFieldWidth,
              child: DSSearchField<String>(
                hintText: 'Patientenname oder Karten-ID suchen',
                onChanged: (_) {},
                onSearch: (_) {},
              ),
            ),
            const Spacer(),
            DSText(
              '0 Dateien',
              style: tokens.text.textSm.copyWith(color: tokens.text.subdued),
            ),
            const DSSpacing.componentM(),
            DSCheckbox(
              label: 'Alle auswählen',
              value: false,
              onChanged: (_) {},
            ),
          ],
        ),
        const DSSpacing.layoutXs(),
        Row(
          children: [
            const _InertFilterButton(label: 'Medientyp auswählen'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Nach Upload-Datum'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Neueste zuerst'),
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
