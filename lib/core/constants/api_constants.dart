import 'package:flutter/foundation.dart';

/// XAMPP PHP backend (`php_backend` under htdocs).
///
/// **Path:** Must match your Apache URL, e.g. `http://10.0.2.2/dentist/php_backend/`
/// - **Android emulator:** `10.0.2.2` reaches the host PC.
/// - **iOS simulator:** use `127.0.0.1`.
/// - **Physical phone (same WiFi):** set [phpHostOverride] to `http://192.168.x.x` (your PC's IP).
class ApiConstants {
  ApiConstants._();

  /// Set to e.g. `http://192.168.1.32` for a real device; leave null to use [defaultPhpHost].
  static const String? phpHostOverride = 'http://192.168.1.32';

  static String get defaultPhpHost {
    if (kIsWeb) return 'http://localhost';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1';
      default:
        return 'http://127.0.0.1';
    }
  }

  static String get phpHost => phpHostOverride ?? defaultPhpHost;

  /// Path from htdocs root to `php_backend` (no trailing slash here).
  ///
  /// Must match where Apache serves this folder, e.g. after copying `php_backend`
  /// to `C:\xampp\htdocs\myapp\php_backend` use `/myapp/php_backend`.
  /// **404 on doctor dashboard** almost always means this path or host is wrong —
  /// paste `baseUrl + 'api/get_all_reports.php?doctor_id=1'` in a browser to verify.
  static const String phpProjectPath = '/dentist/php_backend';

  /// Dio base URL (with trailing slash for correct path joining).
  static String get baseUrl => '$phpHost$phpProjectPath/';

  /// Not used for PHP (paths are absolute from [baseUrl]).
  static const String apiPrefix = '';

  // --- PHP endpoints (relative to [baseUrl]) ---
  static const String loginPath = 'api/login.php';
  static const String registerPath = 'api/register.php';
  static const String getUserPath = 'api/get_user.php';
  static const String getReportsPath = 'api/get_reports.php';
  static const String createReportPath = 'api/create_report.php';
  static const String deleteReportPath = 'api/delete_report.php';
  static const String updateUserPath = 'api/update_user.php';
  static const String changePasswordPath = 'api/change_password.php';
  static const String deleteUserPath = 'api/delete_user.php';
  static const String getAllReportsPath = 'api/get_all_reports.php';
  static const String getMessagesPath = 'api/get_messages.php';
  static const String sendMessagePath = 'api/send_message.php';
  static const String adminGetUsersPath = 'api/admin_get_users.php';
  static const String adminDeleteUserPath = 'api/admin_delete_user.php';
  static const String adminChangeRolePath = 'api/admin_change_role.php';
  static const String adminApproveDoctorPath = 'api/admin_approve_doctor.php';
  static const String adminGetStatsPath = 'api/admin_get_stats.php';
  static const String adminGetAllMessagesPath = 'api/admin_get_all_messages.php';
  static const String adminDeleteMessagePath = 'api/admin_delete_message.php';

  // Kept for any legacy references (not used with PHP).
  static const String usersMePath = 'api/get_user.php';
  static const String scansPath = 'api/get_reports.php';
  static const String scanUploadPath = 'api/create_report.php';
}
