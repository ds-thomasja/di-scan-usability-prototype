import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lightning_core_ui/lightning_core_ui.dart';

import '../app_router.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../shell/app_shell.dart';

/// The patient list screen: `/patients`.
///
/// Shows every patient in [MockData.patients] in a [DSSliverTable], filterable
/// by name through a [DSSearchField]. Tapping a row (or picking "View details"
/// from the row's overflow menu) navigates to that patient's detail page.
///
/// Stateful because the search query is local, ephemeral UI state — there is no
/// backend and no shared state container in this prototype.
class PatientListPage extends StatefulWidget {
  /// Creates the patient list page.
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  /// Max width of the search field.
  ///
  /// The DS token set has no "input field width" token — field width is a
  /// layout decision left to the consuming page — so this mirrors the Figma
  /// measurement directly. Everything else on this page uses tokens.
  static const double _searchFieldMaxWidth = 296;

  /// The current, already-normalised search term (lower-cased, trimmed).
  String _query = '';

  /// [MockData.patients] filtered by [_query], case-insensitively, on `name`.
  List<Patient> get _visiblePatients {
    if (_query.isEmpty) return MockData.patients;
    return MockData.patients
        .where((patient) => patient.name.toLowerCase().contains(_query))
        .toList();
  }

  void _onQueryChanged(String value) {
    final normalised = value.trim().toLowerCase();
    if (normalised == _query) return;
    setState(() => _query = normalised);
  }

  void _openPatient(Patient patient) =>
      context.go(AppRoutes.patient(patient.id));

  DSTableRow _buildRow(Patient patient) => DSTableRow(
        // Primary navigation affordance: the whole row is clickable, which is
        // what a user of the real DS Core patient list would expect.
        onTap: () => _openPatient(patient),
        // Renders the kebab / overflow button seen in the design. With
        // `DSSliverTable.visibleActionButtons` left at its default of 0, every
        // action is collapsed into that menu.
        actions: [
          DSAction(
            title: 'View details',
            icon: DSIcons.open,
            onTrigger: () => _openPatient(patient),
          ),
        ],
        cells: [
          DSTableCell.text(text: patient.name),
          DSTableCell.text(text: patient.cardId),
          DSTableCell.text(text: patient.dateOfBirth),
          DSTableCell.text(text: patient.creationDate),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final tokens = DSTokens.of(context);
    final patients = _visiblePatients;

    return AppShell(
      selectedItem: AppShellItem.patients,
      // DSSliverScrollablePage is the sliver page template intended to fill
      // DSScaffold.bodySlivers; it supplies the title/subtitle/actions header
      // and wraps its own bodySlivers in a DSSliverResponsiveBody for margins.
      bodySlivers: [
        DSSliverScrollablePage(
          title: 'Patients',
          subtitle: 'View, manage, and add new patients here.',
          actions: [
            DSButton.primary(
              buttonText: 'Create patient',
              icon: DSIcons.add,
              // Inert: no create-patient flow exists in this prototype.
              onPressed: () {},
            ),
          ],
          bodySlivers: [
            DSSliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.layout.m),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _searchFieldMaxWidth,
                    ),
                    child: DSSearchField<String>(
                      hintText: 'Search',
                      // Filter as the user types; `onSearch` additionally
                      // covers Enter and the clear (x) button.
                      onChanged: _onQueryChanged,
                      onSearch: _onQueryChanged,
                    ),
                  ),
                ),
              ),
            ),
            if (patients.isEmpty)
              SliverToBoxAdapter(
                child: DSEmptyState(
                  size: DSEmptyStateSize.large,
                  headline: 'No patients found',
                  body: 'No patient matches your search. '
                      'Try a different name.',
                  illustration: DSSpotIllustrations.patients,
                ),
              )
            else
              DSSliverTable(
                // DSSliverTable draws its own DSContainer card decoration, so
                // it does not need to be wrapped in a DSSliversContainer.
                columns: const [
                  DSTableColumn(title: 'Name'),
                  DSTableColumn(title: 'Card ID'),
                  DSTableColumn(title: 'Date of birth'),
                  DSTableColumn(title: 'Creation date'),
                ],
                rows: [for (final patient in patients) _buildRow(patient)],
              ),
          ],
        ),
      ],
    );
  }
}
