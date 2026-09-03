import 'package:flutter/material.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../shell/app_shell.dart';

/// The device and accessory page (`/equipment`).
///
/// The prototype has no device inventory, so both tabs always render an
/// empty state matching the DS Core "no devices yet" screen. The two "New
/// device"/"New accessory" buttons are inert — there is no add-device flow
/// on this page (device pairing only happens through the scan-capture flow).
class EquipmentPage extends StatelessWidget {
  /// Creates the equipment page.
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context) => AppShell(
        selectedItem: AppShellItem.equipment,
        bodySlivers: [
          DSSliverScrollablePage.withTabs(
            title: 'Geräte',
            subtitle: 'Verwalten Sie alle Ihre Geräte und Medienquellen an '
                'einem Ort.',
            tabbedScrollableViews: [
              DSScrollableTabbedView(
                title: 'Geräte',
                slivers: [
                  DSSliversContainer(
                    slivers: [
                      SliverToBoxAdapter(
                        child: DSEmptyState(
                          size: DSEmptyStateSize.large,
                          headline: 'Noch keine Geräte',
                          body: 'Alle Ihre Geräte und Medienquellen werden '
                              'hier angezeigt.',
                          illustration: DSSpotIllustrations.equipment,
                          actions: [
                            DSButton.primary(
                              buttonText: 'Neues Gerät',
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
              DSScrollableTabbedView(
                title: 'Zubehör',
                slivers: [
                  DSSliversContainer(
                    slivers: [
                      SliverToBoxAdapter(
                        child: DSEmptyState(
                          size: DSEmptyStateSize.large,
                          headline: 'Noch kein Zubehör',
                          body: 'Ihr gesamtes Zubehör wird hier angezeigt.',
                          illustration: DSSpotIllustrations.equipment,
                          actions: [
                            DSButton.primary(
                              buttonText: 'Neues Zubehör',
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
          ),
        ],
      );
}
