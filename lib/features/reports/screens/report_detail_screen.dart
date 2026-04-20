import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/models/scan_model.dart';

class ReportDetailScreen extends StatefulWidget {
  final ScanModel scan;

  const ReportDetailScreen({super.key, required this.scan});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final api = context.read<ApiClient>();
      final me = await api.getMe();
      if (mounted) setState(() => _user = me);
    } catch (_) {
      if (mounted) setState(() => _user = null);
    }
  }

  String get _patientName {
    if (_user == null) return 'Guest';
    final first = _user!['first_name'] as String? ?? '';
    final last = _user!['last_name'] as String? ?? '';
    return '$first $last'.trim();
  }

  String get _patientPhone => _user?['phone']?.toString() ?? '—';
  String get _patientEmail => _user?['email']?.toString() ?? '—';

  @override
  Widget build(BuildContext context) {
    final s = widget.scan;
    final dateStr = s.createdAt != null ? DateFormat.yMMMd().format(s.createdAt!) : '—';
    final confidence = s.confidenceScore != null
        ? '${(s.confidenceScore! * 100).toStringAsFixed(1)}%'
        : '—';

    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        title: const Text('Report details'),
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: appPrimaryGreenDark,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _row('Name', _patientName),
                    _row('Phone', _patientPhone),
                    _row('Email', _patientEmail),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (s.imagePath != null && s.imagePath!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: s.imagePath!.startsWith('http')
                    ? Image.network(
                        s.imagePath!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(height: 200),
                      )
                    : (File(s.imagePath!).existsSync()
                        ? Image.file(
                            File(s.imagePath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox.shrink()),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report results',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: appPrimaryGreenDark,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _row('Date of scan', dateStr),
                    _row('Type', s.diseaseType ?? '—'),
                    _row('Severity / Result', s.severity ?? '—'),
                    _row('Confidence', confidence),
                    if (s.recommendation != null && s.recommendation!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Notes / Recommendations',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: appPrimaryGreenDark,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(s.recommendation!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
