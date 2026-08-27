import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../data/mock_data.dart';
import '../shell/app_shell.dart';

/// The dashboard landing page (`/home`).
///
/// Renders the DS Core page header ("Welcome, Dr. Ada" + subtitle + a "New"
/// action) followed by four equal-width dashboard cards side by side:
///
/// 1. **Patients** — a cosmetic search field plus a list of
///    [MockData.patients]. Each row navigates to the patient detail page.
/// 2. **All orders** — display-only content. The prototype has no `Order`
///    model and no order detail route, so the rows are hardcoded to match the
///    Figma design and are deliberately not tappable.
/// 3. **Collaboration** — likewise display-only, hardcoded content.
/// 4. **Treatments** — a list of [MockData.treatments]. Each row navigates to
///    the treatment detail page.
///
/// The four-column row is handed to [DSSliverScrollablePage.withExpandingBody]
/// so it consumes exactly the viewport height that is left below the header;
/// each card then scrolls its own mini-list internally. This is the layout the
/// design shows and it is only ever used on a laptop during the moderated
/// usability test, so no small/medium form-factor fallback is implemented.
class HomePage extends StatelessWidget {
  /// Creates the dashboard page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);

    return AppShell(
      selectedItem: AppShellItem.home,
      bodySlivers: [
        // DSScaffold's own documentation recommends combining it with
        // DSSliverScrollablePage; the latter already wraps its header and body
        // in DSSliverResponsiveBody, so no extra margin handling is needed.
        DSSliverScrollablePage.withExpandingBody(
          title: 'Welcome, Dr. Ada',
          subtitle: 'Welcome to the dashboard of your DS CORE account.',
          actions: [
            // Inert: the prototype has no create flow behind this button.
            DSButton.primary(
              buttonText: 'New',
              icon: DSIcons.chevronDown,
              iconLeft: false,
              onPressed: () {},
            ),
          ],
          expandingBody: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.spacing.layout.s,
            children: [
              Expanded(child: _PatientsCard()),
              Expanded(child: _OrdersCard()),
              Expanded(child: _CollaborationCard()),
              Expanded(child: _TreatmentsCard()),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card shell
// ---------------------------------------------------------------------------

/// The white rounded surface shared by all four dashboard cards.
///
/// [DSContainer] provides the surface colour, corner radius and padding from
/// the design tokens, so none of that is hardcoded here.
///
/// The card lays out a header row (title + a cosmetic collapse chevron), an
/// optional [aboveList] slot (used by the Patients card for its search field)
/// and finally the [list], which receives all remaining vertical space and
/// scrolls internally.
class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.list,
    this.aboveList,
  });

  /// The card title, including its count where the design shows one.
  final String title;

  /// The scrollable mini-list. Gets the card's remaining height.
  final Widget list;

  /// Optional content between the header and the list.
  final Widget? aboveList;

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);
    final aboveList = this.aboveList;

    return DSContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DSText(title, style: tokens.text.headingXl),
              ),
              // Cosmetic only — collapsing cards is out of scope for the
              // prototype, but the affordance is part of the design.
              DSButton.tertiary(
                icon: DSIcons.chevronDown,
                tooltip: 'Collapse $title',
                onPressed: () {},
              ),
            ],
          ),
          if (aboveList != null) ...[
            SizedBox(height: tokens.spacing.component.s),
            aboveList,
          ],
          SizedBox(height: tokens.spacing.component.s),
          Expanded(child: list),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. Patients
// ---------------------------------------------------------------------------

class _PatientsCard extends StatelessWidget {
  const _PatientsCard();

  @override
  Widget build(BuildContext context) {
    final patients = MockData.patients;

    return _DashboardCard(
      title: 'Patients (${patients.length})',
      // Cosmetic: filtering is the dedicated Patients page's job.
      aboveList: DSSearchField<String>(
        hintText: 'Search',
        onSearch: (_) {},
      ),
      list: DSList<DSListTextItem>(
        items: [
          for (final patient in patients)
            DSListTextItem(
              header: patient.name,
              body: '${patient.dateOfBirth} - ID ${patient.cardId}',
              onPressed: () => context.go(AppRoutes.patient(patient.id)),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. All orders (display-only)
// ---------------------------------------------------------------------------

/// A single hardcoded order row.
///
/// Deliberately private and minimal: the prototype has no order data model and
/// no order detail page, so this only carries the strings visible in the
/// design.
class _OrderRow {
  const _OrderRow({
    required this.code,
    required this.status,
    required this.statusType,
    required this.description,
    required this.orderedOn,
    required this.patient,
    required this.owner,
  });

  final String code;
  final String status;
  final DSStatusTagType statusType;
  final String description;
  final String orderedOn;
  final String patient;
  final String owner;
}

const List<_OrderRow> _orders = [
  _OrderRow(
    code: '2AA009KP',
    status: 'Declined',
    statusType: DSStatusTagType.critical,
    description: 'Nightguard / Splint',
    orderedOn: 'May 3, 2023',
    patient: 'Briant, Holly',
    owner: 'Dr. Ada, Angelina',
  ),
  _OrderRow(
    code: '2AA00AC3',
    status: 'Canceled',
    statusType: DSStatusTagType.neutral,
    description: 'CEREC Guide',
    orderedOn: 'May 3, 2023',
    patient: 'Briant, Holly',
    owner: 'Dr. Ada, Angelina',
  ),
  _OrderRow(
    code: '2AA00AC2',
    status: 'Requested',
    statusType: DSStatusTagType.neutral,
    description: 'CEREC Guide',
    orderedOn: 'May 3, 2023',
    patient: 'Briant, Holly',
    owner: 'Dr. Ada, Angelina',
  ),
  _OrderRow(
    code: '2AA009XU',
    status: 'Completed',
    statusType: DSStatusTagType.success,
    description: 'Temporary Restoration',
    orderedOn: 'May 10, 2023',
    patient: 'Paula, Theodora',
    owner: 'Dr. Ada, Angelina',
  ),
  _OrderRow(
    code: '2AA009KG',
    status: 'Completed',
    statusType: DSStatusTagType.success,
    description: 'Custom Impression Tray',
    orderedOn: 'May 10, 2023',
    patient: 'Briant, Holly',
    owner: 'Dr. Ada, Angelina',
  ),
  _OrderRow(
    code: '2AA008LJ',
    status: 'Requested',
    statusType: DSStatusTagType.neutral,
    description: 'Custom Abutment',
    orderedOn: 'Apr 4, 2023',
    patient: 'Briant, Holly',
    owner: 'Dr. Ada, Angelina',
  ),
];

class _OrdersCard extends StatelessWidget {
  const _OrdersCard();

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);
    // Mirrors DSListItemThemeData so the custom rows match the DS list rows in
    // the neighbouring cards.
    final headerStyle = tokens.text.textBase;
    final bodyStyle = tokens.text.textSm.copyWith(color: tokens.text.subdued);

    return _DashboardCard(
      title: 'All orders (${_orders.length})',
      list: DSList<DSListCustomItem>(
        items: [
          for (final order in _orders)
            DSListCustomItem(
              // No `onPressed`: there is no order detail page to navigate to.
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: tokens.spacing.component.xs,
                    children: [
                      Expanded(child: DSText(order.code, style: headerStyle)),
                      DSTag.status(
                        text: order.status,
                        statusType: order.statusType,
                        tagSize: DSTagSize.small,
                      ),
                    ],
                  ),
                  DSText(
                    '${order.description}\n'
                    'Ordered on: ${order.orderedOn}\n'
                    'Patient: ${order.patient}\n'
                    'Owner: ${order.owner}',
                    style: bodyStyle,
                    maxLines: null,
                    overflow: null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Collaboration (display-only)
// ---------------------------------------------------------------------------

/// A single hardcoded collaboration row, copied from the design.
class _ShareRow {
  const _ShareRow({
    required this.title,
    required this.party,
    required this.daysLeft,
    required this.direction,
  });

  final String title;
  final String party;
  final String daysLeft;
  final String direction;
}

const List<_ShareRow> _shares = [
  _ShareRow(
    title: 'Share of Endo, Tim',
    party: 'From with Dr. Ada, Angelina',
    daysLeft: '19 days left',
    direction: 'Received',
  ),
  _ShareRow(
    title: 'Share of Holly, Briant',
    party: 'Shared with Dr. Ada, Angelina',
    daysLeft: '21 days left',
    direction: 'Sent',
  ),
  _ShareRow(
    title: 'Share of Endo, Tim',
    party: 'Shared with Dr. Ada, Angelina',
    daysLeft: '19 days left',
    direction: 'Received',
  ),
  _ShareRow(
    title: 'Share of Holly, Briant',
    party: 'Shared with Dr. Ada, Angelina',
    daysLeft: '21 days left',
    direction: 'Sent',
  ),
];

class _CollaborationCard extends StatelessWidget {
  const _CollaborationCard();

  @override
  Widget build(BuildContext context) => _DashboardCard(
        // No count in the design for this card.
        title: 'Collaboration',
        list: DSList<DSListTextItem>(
          items: [
            for (final share in _shares)
              // No `onPressed`: there is no collaboration detail page.
              DSListTextItem(
                header: share.title,
                body: '${share.party}\n'
                    '${share.daysLeft}\n'
                    '${share.direction}',
              ),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// 4. Treatments
// ---------------------------------------------------------------------------

class _TreatmentsCard extends StatelessWidget {
  const _TreatmentsCard();

  @override
  Widget build(BuildContext context) {
    final treatments = MockData.treatments;

    return _DashboardCard(
      title: 'Treatments (${treatments.length})',
      list: DSList<DSListTextItem>(
        items: [
          for (final treatment in treatments)
            DSListTextItem(
              header: treatment.id,
              body: '${treatment.title}\n'
                  'Created on: ${treatment.createdOn}\n'
                  'Patient: ${treatment.patientName}\n'
                  'Owner: ${treatment.createdBy}',
              onPressed: () => context.go(AppRoutes.treatment(treatment.id)),
            ),
        ],
      ),
    );
  }
}
