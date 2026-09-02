import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_gate.dart';
import 'auth/auth_state.dart';
import 'pages/home_page.dart';
import 'pages/patient_detail_page.dart';
import 'pages/patient_list_page.dart';
import 'pages/scan_loading_page.dart';
import 'pages/switch_prototype_page.dart';
import 'pages/treatment_detail_page.dart';
import 'pages/treatment_list_page.dart';

/// Route paths used throughout the prototype.
///
/// Kept as constants so page widgets can navigate without repeating string
/// literals: `context.go(AppRoutes.patients)`.
abstract final class AppRoutes {
  /// The password gate. Only reachable while locked.
  static const String login = '/';

  /// The landing page shown right after unlocking.
  static const String home = '/home';

  /// The patient list.
  static const String patients = '/patients';

  /// A single patient's detail page. Append `/<id>`.
  static const String patientDetail = '/patients/:id';

  /// The treatment list.
  static const String treatments = '/treatments';

  /// A single treatment's detail page. Append `/<id>`.
  static const String treatmentDetail = '/treatments/:id';

  /// The wait after picking "Status scan" for a device. Pushed on top of the
  /// page the scan was started from, so that "Cancel loading" can return
  /// there.
  static const String scanLoading = '/scan/loading';

  /// The signpost the status-scan flow ends on.
  static const String switchPrototype = '/switch-prototype';

  /// Builds the concrete path for a patient detail page.
  static String patient(String id) => '/patients/$id';

  /// Builds the concrete path for a treatment detail page.
  static String treatment(String id) => '/treatments/$id';
}

/// The application router.
///
/// [GoRouter.refreshListenable] is wired to [AuthState.instance] (a
/// [ChangeNotifier]) so that [GoRouter.redirect] is re-evaluated as soon as
/// the prototype is unlocked, without the calling widget having to navigate
/// itself.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  refreshListenable: AuthState.instance,
  redirect: (context, state) {
    final bool unlocked = AuthState.instance.isUnlocked;
    final bool goingToLogin = state.matchedLocation == AppRoutes.login;

    // Locked: everything funnels back to the password gate.
    if (!unlocked && !goingToLogin) return AppRoutes.login;

    // Unlocked: the password gate is pointless, send the user home.
    if (unlocked && goingToLogin) return AppRoutes.home;

    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.patients,
      name: 'patients',
      builder: (context, state) => const PatientListPage(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: 'patientDetail',
          builder: (context, state) =>
              PatientDetailPage(patientId: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.treatments,
      name: 'treatments',
      builder: (context, state) => const TreatmentListPage(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: 'treatmentDetail',
          builder: (context, state) =>
              TreatmentDetailPage(treatmentId: state.pathParameters['id']!),
        ),
      ],
    ),
    // Both of these are full-screen: they replace the app chrome rather than
    // render inside it, so neither is nested under a content route.
    GoRoute(
      path: AppRoutes.scanLoading,
      name: 'scanLoading',
      builder: (context, state) => const ScanLoadingPage(),
    ),
    GoRoute(
      path: AppRoutes.switchPrototype,
      name: 'switchPrototype',
      builder: (context, state) => const SwitchPrototypePage(),
    ),
  ],
);
