import 'dart:convert';

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../storage/token_storage.dart';

/// HTTP client for **XAMPP PHP** backend (`php_backend`).
class ApiClient {
  late final Dio _dio;
  final TokenStorage _storage;

  ApiClient({TokenStorage? storage}) : _storage = storage ?? TokenStorage() {
    _dio = Dio(BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));
    _initInterceptors();
  }

  void _initInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // PHP backend does not use Bearer tokens; session is user_id in secure storage.
        return handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          await _storage.clear();
        }
        return handler.next(err);
      },
    ));
  }

  /// All patient reports (doctor dashboard). Requires logged-in user to be a doctor in DB.
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final doctorId = await _storage.getPhpUserId();
    if (doctorId == null) throw Exception('Not logged in');
    final path = '${ApiConstants.getAllReportsPath}?doctor_id=$doctorId';
    try {
      final res = await _dio.get(path);
      final d = _asMap(res.data);
      if (d['status'] != 'success') {
        throw Exception(d['message']?.toString() ?? 'Failed to load reports');
      }
      final list = d['reports'];
      if (list is! List) return [];
      return list.map((e) => _asMap(e as Map)).toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final fullUrl = '${ApiConstants.baseUrl}$path';
      if (status == 404) {
        throw Exception(
          'Doctor reports API not found (404).\n\n'
          '1) Copy php_backend into XAMPP htdocs.\n'
          '2) Set phpProjectPath in api_constants.dart to match the URL path.\n'
          '3) Test in browser: $fullUrl',
        );
      }
      if (status == 403) {
        if (data is Map && data['message'] != null) {
          throw Exception(data['message'].toString());
        }
        throw Exception(
          'Forbidden (403). Your user must have role=doctor in the MySQL users table.',
        );
      }
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception(
        e.message ?? 'Could not load reports. Check XAMPP, Wi‑Fi, and api_constants.dart.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(int reportId) async {
    try {
      final res = await _dio.get('${ApiConstants.getMessagesPath}?report_id=$reportId');
      final d = _asMap(res.data);
      if (d['status'] != 'success') {
        throw Exception(d['message']?.toString() ?? 'Failed to load messages');
      }
      final list = d['messages'];
      if (list is! List) return [];
      return list.map((e) => _asMap(e as Map)).toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception(
        e.message ?? 'Could not load messages. Check your connection and XAMPP.',
      );
    }
  }

  Future<void> sendMessage({
    required int reportId,
    int? doctorId,
    required int patientId,
    required String senderRole,
    required String message,
    String? appointmentDate,
  }) async {
    final body = <String, dynamic>{
      'report_id': reportId,
      'patient_id': patientId,
      'sender_role': senderRole,
      'message': message,
    };
    if (doctorId != null && doctorId > 0) {
      body['doctor_id'] = doctorId;
    }
    if (appointmentDate != null && appointmentDate.isNotEmpty) {
      body['appointment_date'] = appointmentDate;
    }
    try {
      final res = await _dio.post(
        ApiConstants.sendMessagePath,
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final d = _asMap(res.data);
      if (d['status'] != 'success') {
        throw Exception(d['message']?.toString() ?? 'Send failed');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      throw Exception(
        e.message ?? 'Could not send message. Check your connection and XAMPP.',
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Invalid JSON response');
  }

  /// PHP: `phone` + `password`. Returns `{ status, user }`.
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.loginPath,
        data: jsonEncode({'phone': phone, 'password': password}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final d = _asMap(res.data);
      if (d['status'] != 'success') {
        throw Exception(d['message']?.toString() ?? 'Login failed');
      }
      return d;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }
      if (e.response?.statusCode == 403) {
        throw Exception('Pending admin approval');
      }
      rethrow;
    }
  }

  /// PHP: `name`, `phone`, `email`, `password`.
  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password, {
    String? sex,
    String role = 'patient',
  }) async {
    final name = '$firstName $lastName'.trim();
    final data = <String, dynamic>{
      'name': name.isEmpty ? phone : name,
      'phone': phone.trim(),
      'email': email.trim(),
      'password': password,
      'role': role == 'doctor' ? 'doctor' : 'patient',
    };
    if (sex != null) data['sex'] = sex;
    final res = await _dio.post(
      ApiConstants.registerPath,
      data: jsonEncode(data),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Registration failed');
    }
    return d;
  }

  /// Profile shape expected by UI: `first_name`, `last_name`, `email`, `phone`.
  Future<Map<String, dynamic>> getMe() async {
    final id = await _storage.getPhpUserId();
    if (id == null) {
      throw Exception('Not logged in');
    }
    final res = await _dio.get(
      '${ApiConstants.getUserPath}?user_id=$id',
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Failed to load user');
    }
    final u = _asMap(d['user']);
    return {
      'first_name': u['first_name']?.toString() ?? '',
      'last_name': u['last_name']?.toString() ?? '',
      'email': u['email']?.toString() ?? '',
      'phone': u['phone']?.toString() ?? '',
      'role': u['role']?.toString() ?? 'patient',
    };
  }

  Future<Map<String, dynamic>> updateMe({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
  }) async {
    final id = await _storage.getPhpUserId();
    if (id == null) throw Exception('Not logged in');
    final res = await _dio.post(
      ApiConstants.updateUserPath,
      data: {
        'user_id': id,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
        'phone': phone ?? '',
        'email': email ?? '',
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Update failed');
    }
    return getMe();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final id = await _storage.getPhpUserId();
    if (id == null) throw Exception('Not logged in');
    final res = await _dio.post(
      ApiConstants.changePasswordPath,
      data: {
        'user_id': id,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Could not change password');
    }
  }

  /// [accountPassword] is required by PHP (your current login password).
  Future<void> deleteAccount({required String accountPassword}) async {
    final id = await _storage.getPhpUserId();
    if (id == null) throw Exception('Not logged in');
    final res = await _dio.post(
      ApiConstants.deleteUserPath,
      data: {
        'user_id': id,
        'password': accountPassword,
      },
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Could not delete account');
    }
  }

  String _absoluteImageUrl(String relativeOrAbsolute) {
    if (relativeOrAbsolute.startsWith('http')) return relativeOrAbsolute;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = relativeOrAbsolute.startsWith('/') ? relativeOrAbsolute : '/$relativeOrAbsolute';
    return '$base$path';
  }

  /// Public helper for UI (e.g. doctor dashboard thumbnails).
  String resolveImageUrl(String relativeOrAbsolute) =>
      _absoluteImageUrl(relativeOrAbsolute);

  Map<String, dynamic> _phpReportToScanJson(Map<String, dynamic> r) {
    final conf = r['confidence'];
    double? score;
    if (conf is num) {
      final v = conf.toDouble();
      score = v > 1.0 ? v / 100.0 : v;
    }
    return {
      'id': r['id']?.toString() ?? '',
      'image_path': _absoluteImageUrl(r['image_path']?.toString() ?? ''),
      'disease_type': r['result']?.toString(),
      'severity': null,
      'confidence_score': score,
      'recommendation': null,
      'created_at': r['created_at']?.toString(),
    };
  }

  /// Upload image; PHP stores report. Returns shape compatible with [NewScanScreen].
  Future<Map<String, dynamic>> uploadScan(String imagePath) async {
    final userId = await _storage.getPhpUserId();
    if (userId == null) {
      throw Exception('Please sign in to upload a scan.');
    }
    const placeholderResult = 'review_required';
    const placeholderConfidence = 0.5;
    final form = FormData.fromMap({
      'user_id': userId.toString(),
      'result': placeholderResult,
      'confidence': placeholderConfidence.toString(),
      'image': await MultipartFile.fromFile(imagePath, filename: 'scan.jpg'),
    });
    final res = await _dio.post(
      ApiConstants.createReportPath,
      data: form,
      options: Options(
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Upload failed');
    }
    return {
      'id': d['report_id']?.toString(),
      'disease_type': placeholderResult,
      'severity': null,
      'confidence_score': placeholderConfidence,
      'recommendation':
          'Image saved on server. This PHP API does not run AI — connect an AI service for automatic diagnosis.',
    };
  }

  Future<List<dynamic>> getScans() async {
    final id = await _storage.getPhpUserId();
    if (id == null) return [];
    final res = await _dio.get('${ApiConstants.getReportsPath}?user_id=$id');
    final d = _asMap(res.data);
    if (d['status'] != 'success') return [];
    final list = d['reports'];
    if (list is! List) return [];
    return list
        .map((e) => _phpReportToScanJson(_asMap(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> getScan(String id) async {
    final all = await getScans();
    for (final e in all) {
      if (e is Map<String, dynamic> && e['id']?.toString() == id) {
        return Map<String, dynamic>.from(e);
      }
    }
    throw Exception('Scan not found');
  }

  Future<void> deleteScan(String id) async {
    final reportId = int.tryParse(id);
    if (reportId == null) throw Exception('Invalid scan id');
    final res = await _dio.post(
      ApiConstants.deleteReportPath,
      data: {'report_id': reportId},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Delete failed');
    }
  }

  Future<List<int>> getScanReport(String id) async {
    throw Exception('PDF reports are not available with the PHP backend.');
  }

  Future<int> _requirePhpUserId() async {
    final id = await _storage.getPhpUserId();
    if (id == null) throw Exception('Not logged in');
    return id;
  }

  Future<List<Map<String, dynamic>>> adminGetUsers() async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.get('${ApiConstants.adminGetUsersPath}?admin_id=$adminId');
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Failed to load users');
    }
    final list = d['users'];
    if (list is! List) return [];
    return list.map((e) => _asMap(e as Map)).toList();
  }

  Future<void> adminDeleteUser(int userId) async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.post(
      ApiConstants.adminDeleteUserPath,
      data: jsonEncode({'admin_id': adminId, 'user_id': userId}),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Delete failed');
    }
  }

  Future<void> adminChangeRole(int userId, String newRole) async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.post(
      ApiConstants.adminChangeRolePath,
      data: jsonEncode({
        'admin_id': adminId,
        'user_id': userId,
        'new_role': newRole,
      }),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Role update failed');
    }
  }

  Future<void> adminApproveDoctor(int userId, int isApproved) async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.post(
      ApiConstants.adminApproveDoctorPath,
      data: jsonEncode({
        'admin_id': adminId,
        'user_id': userId,
        'is_approved': isApproved,
      }),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Approval failed');
    }
  }

  Future<Map<String, dynamic>> adminGetStats() async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.get('${ApiConstants.adminGetStatsPath}?admin_id=$adminId');
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Failed to load stats');
    }
    final stats = d['stats'];
    if (stats is! Map) {
      throw Exception('Invalid stats response');
    }
    return _asMap(stats);
  }

  Future<List<Map<String, dynamic>>> adminGetAllMessages() async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.get('${ApiConstants.adminGetAllMessagesPath}?admin_id=$adminId');
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Failed to load messages');
    }
    final list = d['messages'];
    if (list is! List) return [];
    return list.map((e) => _asMap(e as Map)).toList();
  }

  Future<void> adminDeleteMessage(int messageId) async {
    final adminId = await _requirePhpUserId();
    final res = await _dio.post(
      ApiConstants.adminDeleteMessagePath,
      data: jsonEncode({'admin_id': adminId, 'message_id': messageId}),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    final d = _asMap(res.data);
    if (d['status'] != 'success') {
      throw Exception(d['message']?.toString() ?? 'Delete failed');
    }
  }

  Dio get dio => _dio;
}
