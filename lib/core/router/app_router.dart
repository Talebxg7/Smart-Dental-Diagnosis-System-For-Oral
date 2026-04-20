import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login/login_screen.dart';
import '../../features/auth/screens/register/register_screen.dart';
import '../../features/home/screens/home/home_screen.dart';
import '../../features/scan/screens/new_scan/new_scan_screen.dart';
import '../../features/scan/screens/result/result_screen.dart';
import '../../features/history/screens/scan_history_page.dart';
import '../../features/history/screens/scan_details_page.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/reports/screens/report_detail_screen.dart';
import '../../shared/models/scan_model.dart';
import '../../features/profile/screens/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/screens/disease_info/caries_info_page.dart';
import '../../features/home/screens/disease_info/tartar_info_page.dart';
import '../../features/home/screens/disease_info/gingivitis_info_page.dart';
import '../../features/doctor/doctor_home_page.dart';
import '../../features/doctor/doctor_report_detail_page.dart';
import '../../features/doctor/models/doctor_report_detail_args.dart';
import '../../features/admin/admin_home_page.dart';
import '../../shared/auth/auth_provider.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (BuildContext context, GoRouterState state) {
      final loc = state.matchedLocation;

      if (!auth.isHydrated) {
        if (loc != '/splash') return '/splash';
        return null;
      }

      final loggedIn = auth.isLoggedInSync;
      final isAdmin = auth.isAdmin;
      final approvedDoctor = auth.isApprovedDoctor;
      final isAuthPage = loc == '/login' || loc == '/register';

      if (loggedIn && isAuthPage) {
        if (isAdmin) return '/admin-home';
        if (approvedDoctor) return '/doctor-home';
        return '/home';
      }

      if (loc == '/admin-home') {
        if (!loggedIn) return '/login';
        if (!isAdmin) return '/home';
        return null;
      }

      final isDoctorRoute = loc == '/doctor-home' || loc == '/doctor-report-detail';
      if (isDoctorRoute) {
        if (!loggedIn) return '/login';
        if (!approvedDoctor) return '/home';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin-home',
        builder: (_, __) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/doctor-home',
        builder: (_, __) => const DoctorHomePage(),
      ),
      GoRoute(
        path: '/doctor-report-detail',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is! DoctorReportDetailArgs) {
            return const DoctorHomePage();
          }
          return DoctorReportDetailPage(args: extra);
        },
      ),
      GoRoute(
        path: '/scan',
        builder: (_, state) {
          final extra = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
          final source = extra?['source'] as String?;
          return NewScanScreen(initialSource: source);
        },
      ),
      GoRoute(
        path: '/result',
        builder: (_, state) {
          final extra = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          return ResultScreen(
            scanId: extra?['scanId']?.toString(),
            diseaseType: extra?['diseaseType'] as String?,
            severity: extra?['severity'] as String?,
            confidence: (extra?['confidence'] as num?)?.toDouble(),
            recommendation: extra?['recommendation'] as String?,
            imagePath: extra?['imagePath'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const ScanHistoryPage(),
        routes: [
          GoRoute(
            path: 'details',
            builder: (_, state) {
              final scan = state.extra is ScanModel ? state.extra as ScanModel : null;
              if (scan == null) return const ScanHistoryPage();
              return ScanDetailsPage(scan: scan);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            builder: (_, state) {
              final scan = state.extra is ScanModel ? state.extra as ScanModel : null;
              if (scan == null) return const ReportsScreen();
              return ReportDetailScreen(scan: scan);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/disease/caries',
        builder: (_, __) => const CariesInfoPage(),
      ),
      GoRoute(
        path: '/disease/tartar',
        builder: (_, __) => const TartarInfoPage(),
      ),
      GoRoute(
        path: '/disease/gingivitis',
        builder: (_, __) => const GingivitisInfoPage(),
      ),
    ],
  );
}
