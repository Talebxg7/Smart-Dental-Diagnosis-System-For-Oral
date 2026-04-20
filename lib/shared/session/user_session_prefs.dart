import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors logged-in session for quick sync reads (with secure storage for auth).
class UserSessionPrefs {
  UserSessionPrefs._();

  static const String keyUserId = 'php_user_id';
  static const String keyRole = 'user_role';
  static const String keyIsApproved = 'user_is_approved';

  static Future<void> save({
    required int userId,
    required String role,
    int isApproved = 1,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(keyUserId, userId);
    await p.setString(keyRole, role);
    await p.setInt(keyIsApproved, isApproved);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(keyUserId);
    await p.remove(keyRole);
    await p.remove(keyIsApproved);
  }

  static Future<String?> loadRole() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(keyRole);
  }

  static Future<int?> loadUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(keyUserId);
  }

  /// 1 = approved; doctors pending use 0. Default 1 if missing (legacy installs).
  static Future<int> loadIsApproved() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(keyIsApproved) ?? 1;
  }
}
