import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';

/// The main-menu entries that a page can mark as selected.
enum AppShellItem {
  /// The Home destination (`/home`).
  home,

  /// The Patients destination (`/patients` and its detail pages).
  patients,

  /// The Orders destination (`/orders`).
  orders,

  /// The Collaboration destination (`/collaboration`).
  collaboration,

  /// The Treatments destination (`/treatments` and its detail pages).
  treatments,

  /// The Jobs destination (`/jobs`).
  jobs,

  /// The Files destination (`/files`).
  files,

  /// The Equipment destination (`/equipment`).
  equipment,
}

/// The shared application chrome: DS Core sidebar, top bar and body.
///
/// Every content page wraps its slivers in this widget so the sidebar and top
/// bar stay identical across the prototype.
///
/// ```dart
/// AppShell(
///   selectedItem: AppShellItem.patients,
///   bodySlivers: [
///     DSSliverResponsiveBody(sliver: SliverList(...)),
///     SliverToBoxAdapter(child: MyBoxWidget()),
///   ],
/// );
/// ```
///
/// [bodySlivers] must contain slivers — this is the caller's responsibility.
/// Wrap box widgets in `SliverToBoxAdapter` (or `DSSliverStrictlyFillRemaining`
/// to fill the remaining viewport height), and wrap content in
/// `DSSliverResponsiveBody` for correct left/right margins.
class AppShell extends StatelessWidget {
  /// Creates the application shell.
  const AppShell({
    required this.selectedItem,
    required this.bodySlivers,
    super.key,
  });

  /// The main-menu entry to highlight as active.
  final AppShellItem selectedItem;

  /// The body content. Must already be slivers — caller's responsibility.
  final List<Widget> bodySlivers;

  @override
  Widget build(BuildContext context) => DSScaffold(
        // No logo asset exists for the prototype. DSScaffold renders the
        // default main-menu header (hamburger + logo area) on its own.
        appLogo: null,
        onAppLogoPressed: () => context.go(AppRoutes.home),
        mainMenuContent: DSMainMenuContent(
          items: [
            DSMainMenuItem(
              label: 'Start',
              icon: DSIcons.home,
              selected: selectedItem == AppShellItem.home,
              onPressed: () => context.go(AppRoutes.home),
            ),
            DSMainMenuItem(
              label: 'Patienten',
              icon: DSIcons.users,
              selected: selectedItem == AppShellItem.patients,
              onPressed: () => context.go(AppRoutes.patients),
            ),
            DSMainMenuItem(
              label: 'Bestellungen',
              icon: DSIcons.shoppingCart,
              selected: selectedItem == AppShellItem.orders,
              onPressed: () => context.go(AppRoutes.orders),
            ),
            DSMainMenuItem(
              label: 'Zusammenarbeit',
              icon: DSIcons.collaboration,
              selected: selectedItem == AppShellItem.collaboration,
              onPressed: () => context.go(AppRoutes.collaboration),
            ),
            DSMainMenuItem(
              label: 'Behandlungen',
              icon: DSIcons.treatment,
              selected: selectedItem == AppShellItem.treatments,
              onPressed: () => context.go(AppRoutes.treatments),
            ),
            DSMainMenuItem(
              label: 'Aufträge',
              icon: DSIcons.tasks,
              selected: selectedItem == AppShellItem.jobs,
              onPressed: () => context.go(AppRoutes.jobs),
            ),
            DSMainMenuItem(
              label: 'Nicht zugeordnete Dateien',
              icon: DSIcons.imageSeries,
              selected: selectedItem == AppShellItem.files,
              onPressed: () => context.go(AppRoutes.files),
            ),
            DSMainMenuItem(
              label: 'Geräte',
              icon: DSIcons.connectivity,
              selected: selectedItem == AppShellItem.equipment,
              onPressed: () => context.go(AppRoutes.equipment),
            ),
          ],
        ),
        actionWidgets: [
          // Present but functionally inert: a null `onPressed` would render
          // them greyed out, which is not what the design shows.
          DSButton.tertiary(
            icon: DSIcons.notification,
            tooltip: 'Benachrichtigungen',
            onPressed: () {},
          ),
          DSButton.tertiary(
            icon: DSIcons.helpCircle,
            tooltip: 'Hilfe',
            onPressed: () {},
          ),
          // Per DSScaffold's docs, a DSUserMenuButton must be the last action.
          DSUserMenuButton(
            userInitials: 'UN',
            builder: (context) => DSUserMenu.fromModel(
              userName: 'Test User',
              userAdditionalInfo: 'Dentsply Sirona',
              userInitials: 'UN',
              items: [
                const DSUserMenuItem(label: 'Profil', icon: DSIcons.user),
                const DSUserMenuItem(
                  label: 'Einstellungen',
                  icon: DSIcons.settingsCog,
                ),
                DSUserMenuItem(
                  label: 'Abmelden',
                  icon: DSIcons.logout,
                  onPressed: () => context.go(AppRoutes.start),
                ),
              ],
            ),
          ),
        ],
        bodySlivers: bodySlivers,
      );
}
