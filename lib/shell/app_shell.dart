import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';

/// The main-menu entries that a page can mark as selected.
///
/// Only the three navigable destinations are listed: `DSMainMenuItem.selected`
/// only reports `true` for items that also have a non-null `onPressed`, so the
/// inert entries (Orders, Collaboration, Jobs, ...) can never be selected.
enum AppShellItem {
  /// The Home destination (`/home`).
  home,

  /// The Patients destination (`/patients` and its detail pages).
  patients,

  /// The Treatments destination (`/treatments` and its detail pages).
  treatments,
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
              label: 'Home',
              icon: DSIcons.home,
              selected: selectedItem == AppShellItem.home,
              onPressed: () => context.go(AppRoutes.home),
            ),
            DSMainMenuItem(
              label: 'Patients',
              icon: DSIcons.users,
              selected: selectedItem == AppShellItem.patients,
              onPressed: () => context.go(AppRoutes.patients),
            ),
            // Inert entries: no `onPressed`, so DSMainMenuItem renders them
            // disabled. These screens are out of scope for the prototype but
            // are shown so the sidebar matches the Figma design.
            const DSMainMenuItem(
              label: 'Orders',
              icon: DSIcons.shoppingCart,
            ),
            const DSMainMenuItem(
              label: 'Collaboration',
              icon: DSIcons.collaboration,
            ),
            DSMainMenuItem(
              label: 'Treatments',
              icon: DSIcons.treatment,
              selected: selectedItem == AppShellItem.treatments,
              onPressed: () => context.go(AppRoutes.treatments),
            ),
            const DSMainMenuItem(
              label: 'Jobs',
              icon: DSIcons.tasks,
            ),
            const DSMainMenuItem(
              label: 'Uncategorised files',
              icon: DSIcons.imageSeries,
            ),
            const DSMainMenuItem(
              label: 'Equipment',
              icon: DSIcons.connectivity,
            ),
          ],
        ),
        actionWidgets: [
          // Present but functionally inert: a null `onPressed` would render
          // them greyed out, which is not what the design shows.
          DSButton.tertiary(
            icon: DSIcons.notification,
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          DSButton.tertiary(
            icon: DSIcons.helpCircle,
            tooltip: 'Help',
            onPressed: () {},
          ),
          // Per DSScaffold's docs, a DSUserMenuButton must be the last action.
          DSUserMenuButton(
            userInitials: 'UN',
            builder: (context) => const DSUserMenu.fromModel(
              userName: 'Test User',
              userAdditionalInfo: 'Dentsply Sirona',
              userInitials: 'UN',
              items: [
                DSUserMenuItem(label: 'Profile', icon: DSIcons.user),
                DSUserMenuItem(label: 'Settings', icon: DSIcons.settingsCog),
                DSUserMenuItem(label: 'Log out', icon: DSIcons.logout),
              ],
            ),
          ),
        ],
        bodySlivers: bodySlivers,
      );
}
