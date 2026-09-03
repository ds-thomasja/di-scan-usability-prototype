import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../shell/app_shell.dart';

/// The order list page (`/orders`).
///
/// The prototype has no `Order` model, so this always renders the empty
/// state: a search field, four inert filter pills and a result count sit
/// above a [DSEmptyState] card, matching the DS Core "no orders yet" screen.
/// The search field and filters are purely cosmetic.
class OrdersPage extends StatelessWidget {
  /// Creates the order list page.
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
        selectedItem: AppShellItem.orders,
        bodySlivers: [
          DSSliverScrollablePage(
            title: 'Bestellungen',
            subtitle: 'Alle Ihre Bestellungen, organisiert und leicht zu '
                'filtern.',
            actions: [
              // Inert: the prototype has no create-order flow.
              DSButton.primary(
                buttonText: 'Neue Bestellung',
                icon: DSIcons.add,
                onPressed: () {},
              ),
            ],
            detailsContent: const _OrdersToolbar(),
            bodySlivers: [
              DSSliversContainer(
                slivers: [
                  SliverToBoxAdapter(
                    child: DSEmptyState(
                      size: DSEmptyStateSize.large,
                      headline: 'Noch keine Bestellungen',
                      body: 'Alle Ihre Bestellungen werden hier angezeigt.',
                      illustration: DSSpotIllustrations.orders,
                      actions: [
                        DSButton.primary(
                          buttonText: 'Neue Bestellung',
                          icon: DSIcons.add,
                          onPressed: () {},
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
/// Every control here is a visual placeholder: the prototype has no order
/// data to search or filter.
class _OrdersToolbar extends StatelessWidget {
  const _OrdersToolbar();

  static const double _searchFieldWidth = 300;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: _searchFieldWidth,
            child: DSSearchField<String>(
              hintText: 'Bestellungen suchen',
              onChanged: (_) {},
              onSearch: (_) {},
            ),
          ),
        ),
        const DSSpacing.layoutXs(),
        Row(
          children: [
            const _InertFilterButton(label: 'Alle Status'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Alle Leistungen'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Erstellungsdatum'),
            const DSSpacing.componentM(),
            const _InertFilterButton(label: 'Fälligkeitsdatum'),
            const Spacer(),
            DSText(
              '0 Bestellungen',
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
