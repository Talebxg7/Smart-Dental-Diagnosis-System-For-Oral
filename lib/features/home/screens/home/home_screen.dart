import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/models/scan_model.dart';
import '../../widgets/welcome_header.dart';
import '../../widgets/scan_button.dart';
import '../../widgets/disease_cards.dart';
import '../../widgets/recent_scans_section.dart';
import '../../widgets/dental_tip_card.dart';
import '../../widgets/last_scan_result_card.dart';
import '../../../messages/patient_messages_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScanModel> _recentScans = [];
  ScanModel? _lastScan;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadScans();
  }

  Future<void> _loadUser() async {
    try {
      final api = context.read<ApiClient>();
      final data = await api.getMe();
      if (!mounted) return;
      final first = data['first_name'] as String? ?? '';
      final last = data['last_name'] as String? ?? '';
      setState(() => _userName = '$first $last'.trim());
    } catch (_) {
      if (mounted) {
        setState(() => _userName = null);
      }
    }
  }

  Future<void> _loadScans() async {
    try {
      final api = context.read<ApiClient>();
      final list = await api.getScans();
      if (!mounted) return;
      final scans = list
          .map((e) => ScanModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _recentScans = scans.take(5).toList();
        _lastScan = scans.isNotEmpty ? scans.first : null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _recentScans = [];
          _lastScan = null;
        });
      }
    }
  }

  void _openScanWithSource(String source) {
    context.push('/scan', extra: {'source': source}).then((_) => _loadScans());
  }

  void _openResult(ScanModel scan) {
    context.push('/result', extra: {
      'scanId': scan.id,
      'diseaseType': scan.diseaseType,
      'severity': scan.severity,
      'confidence': scan.confidenceScore,
      'recommendation': scan.recommendation,
    });
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final themeNotifier = context.read<ThemeModeNotifier>();
    final chosen = await showModalBottomSheet<Locale>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.english),
              onTap: () => Navigator.pop(ctx, const Locale('en')),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.arabic),
              onTap: () => Navigator.pop(ctx, const Locale('ar')),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.turkish),
              onTap: () => Navigator.pop(ctx, const Locale('tr')),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) {
      await themeNotifier.setLocale(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onPressed: () => _showLanguagePicker(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUser();
          await _loadScans();
        },
        color: appPrimaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeHeader(
                userName: _userName ?? l10n.guest,
              ),
              const SizedBox(height: 24),
              ScanButton(
                onCamera: () => _openScanWithSource('camera'),
                onGallery: () => _openScanWithSource('gallery'),
              ),
              const SizedBox(height: 28),
              DiseaseCards(
                onTapDisease: (id) => context.push('/disease/$id'),
              ),
              const SizedBox(height: 24),
              if (_lastScan != null) ...[
                LastScanResultCard(
                  scan: _lastScan,
                  onTap: () => _openResult(_lastScan!),
                ),
                const SizedBox(height: 24),
              ],
              RecentScansSection(
                scans: _recentScans,
                loading: false,
                onTapScan: _openResult,
                onTapEmpty: () => _openScanWithSource('gallery'),
              ),
              const SizedBox(height: 24),
              const DentalTipCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _FooterNavItem(
                    icon: Icons.history,
                    label: l10n.scanHistory,
                    onTap: () => context.push('/history'),
                  ),
                ),
                Expanded(
                  child: _FooterNavItem(
                    icon: Icons.chat_rounded,
                    label: 'Messages',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PatientMessagesPage(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _FooterNavItem(
                    icon: Icons.description,
                    label: l10n.reports,
                    onTap: () => context.push('/reports'),
                  ),
                ),
                Expanded(
                  child: _FooterNavItem(
                    icon: Icons.person,
                    label: l10n.profile,
                    onTap: () => context.push('/profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: appPrimaryGreen, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: appPrimaryGreenDark,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
