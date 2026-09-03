import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../shell/app_shell.dart';

/// Whether a collaboration tab shows resources received from, or sent to,
/// other practices.
enum _Direction {
  /// Resources received from other practices.
  received,

  /// Resources sent to other practices.
  sent,
}

/// The collaboration hub (`/collaboration`).
///
/// The prototype has no share/referral data, so both tabs always render an
/// empty state below a "Received"/"Sent" segmented control. Both the
/// segmented control and the tabs are otherwise purely cosmetic.
class CollaborationPage extends StatefulWidget {
  /// Creates the collaboration page.
  const CollaborationPage({super.key});

  @override
  State<CollaborationPage> createState() => _CollaborationPageState();
}

class _CollaborationPageState extends State<CollaborationPage> {
  _Direction _sharesDirection = _Direction.received;
  _Direction _referralsDirection = _Direction.received;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return AppShell(
      selectedItem: AppShellItem.collaboration,
      bodySlivers: [
        DSSliverScrollablePage.withTabs(
          title: 'Zusammenarbeit',
          subtitle: 'Verwalten Sie hier Freigaben und Überweisungen.',
          tabbedScrollableViews: [
            DSScrollableTabbedView(
              title: 'Freigaben',
              slivers: _tabSlivers(
                tokens: tokens,
                direction: _sharesDirection,
                onDirectionChanged: (value) =>
                    setState(() => _sharesDirection = value),
                headline: 'Keine Freigaben',
              ),
            ),
            DSScrollableTabbedView(
              title: 'Überweisungen',
              slivers: _tabSlivers(
                tokens: tokens,
                direction: _referralsDirection,
                onDirectionChanged: (value) =>
                    setState(() => _referralsDirection = value),
                headline: 'Keine Überweisungen',
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _tabSlivers({
    required DSTokensData tokens,
    required _Direction direction,
    required ValueChanged<_Direction> onDirectionChanged,
    required String headline,
  }) =>
      [
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.centerLeft,
            child: DSSegmentedControl<_Direction>.withTexts(
              items: [
                DSSegmentedControlItemWithText(
                  value: _Direction.received,
                  text: 'Empfangen',
                ),
                DSSegmentedControlItemWithText(
                  value: _Direction.sent,
                  text: 'Gesendet',
                ),
              ],
              selectedValue: direction,
              onSegmentPressed: onDirectionChanged,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: tokens.spacing.layout.xs),
        ),
        DSSliversContainer(
          slivers: [
            SliverToBoxAdapter(
              child: DSEmptyState(
                size: DSEmptyStateSize.large,
                headline: headline,
                body: direction == _Direction.received
                    ? 'Es scheint keine eingehenden Ressourcen zu geben.'
                    : 'Es scheint keine ausgehenden Ressourcen zu geben.',
                illustration: DSSpotIllustrations.collaboration,
              ),
            ),
          ],
        ),
      ];
}
