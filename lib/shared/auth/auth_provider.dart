import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../session/user_session_prefs.dart';
import '../storage/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiClient _api;
  final TokenStorage _storage = TokenStorage();

  /// PHP may return odd casing; router uses lowercase roles.
  static String normalizeRole(dynamic raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    if (s == 'admin') return 'admin';
    if (s == 'doctor') return 'doctor';
    return 'patient';
  }

  bool _isLoading = false;
  String? _error;
  bool _hydrated = false;
  String _sessionRole = 'patient';
  int _isApproved = 1;
  bool _loggedIn = false;
  int? _userId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isHydrated => _hydrated;
  bool get isLoggedInSync => _loggedIn;
  bool get isAdmin => _sessionRole == 'admin';
  bool get isDoctor => _sessionRole == 'doctor';
  /// Doctor who can use the doctor dashboard and APIs.
  bool get isApprovedDoctor => _sessionRole == 'doctor' && _isApproved == 1;
  String get sessionRole => _sessionRole;
  int get isApprovedFlag => _isApproved;
  int? get currentUserId => _userId;

  /// Load secure storage + SharedPreferences (call from splash before routing).
  Future<void> hydrate() async {
    final token = await _storage.getAccessToken();
    final id = await _storage.getPhpUserId();
    final role = await UserSessionPrefs.loadRole() ?? 'patient';
    final ap = await UserSessionPrefs.loadIsApproved();
    _sessionRole = normalizeRole(role);
    _isApproved = ap;
    _userId = id;
    _loggedIn = token != null && token.isNotEmpty && id != null;
    _hydrated = true;
    notifyListeners();
  }

  /// PHP login: **phone** + password (not email).
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.login(phone.trim(), password);
      final user = data['user'];
      if (user is! Map) {
        throw Exception('Invalid server response');
      }
      final id = user['id'];
      if (id is! int && id is! num) {
        throw Exception('Invalid user id');
      }
      final userId = id is int ? id : (id as num).toInt();
      final role = normalizeRole(user['role']);
      final apRaw = user['is_approved'];
      var isAp = 1;
      if (apRaw is int) {
        isAp = apRaw;
      } else if (apRaw is num) {
        isAp = apRaw.toInt();
      }
      await _storage.saveTokens('php_auth', null);
      await _storage.savePhpUserId(userId);
      await UserSessionPrefs.save(userId: userId, role: role, isApproved: isAp);
      _sessionRole = role;
      _isApproved = isAp;
      _userId = userId;
      _loggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (_error!.startsWith('DioException')) {
        _error = 'Cannot reach server.\n\n'
            'Backend baseUrl: ${ApiConstants.baseUrl}\n\n'
            'Check:\n'
            '- XAMPP Apache is running\n'
            '- The URL path in api_constants.dart (phpProjectPath) matches your htdocs folder\n'
            '- If testing on a phone, set phpHostOverride to your PC IP';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password, {
    String? sex,
    String role = 'patient',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.register(
        firstName,
        lastName,
        email,
        phone,
        password,
        sex: sex,
        role: role,
      );
      // New doctors must be approved — login is blocked until then.
      if (normalizeRole(role) == 'doctor') {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      final ok = await login(phone.trim(), password);
      _isLoading = false;
      notifyListeners();
      return ok;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      if (_error!.startsWith('DioException')) {
        _error = 'Cannot reach server.\n\n'
            'Backend baseUrl: ${ApiConstants.baseUrl}\n\n'
            'Check:\n'
            '- XAMPP Apache is running\n'
            '- The URL path in api_constants.dart (phpProjectPath) matches your htdocs folder\n'
            '- If testing on a phone, set phpHostOverride to your PC IP';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    final id = await _storage.getPhpUserId();
    return token != null && token.isNotEmpty && id != null;
  }

  Future<void> logout() async {
    await _storage.clear();
    await UserSessionPrefs.clear();
    _sessionRole = 'patient';
    _isApproved = 1;
    _userId = null;
    _loggedIn = false;
    notifyListeners();
  }
}
