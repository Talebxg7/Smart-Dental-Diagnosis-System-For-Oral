import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/api/api_client.dart';
import '../../shared/auth/auth_provider.dart';
import 'doctor_diagnosis_style.dart';
import 'models/doctor_report_detail_args.dart';
import 'models/doctor_report_summary.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  List<DoctorReportSummary> _reports = [];
  bool _loading = true;
  String? _error;
  String _doctorDisplayName = '';
  String _filterKey = 'all';
  bool _contentVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _contentVisible = false;
    });
    try {
      final api = context.read<ApiClient>();
      final results = await Future.wait([
        api.getAllReports(),
        _loadDoctorName(api),
      ]);
      final rows = results[0] as List<Map<String, dynamic>>;
      if (!mounted) return;
      setState(() {
        _reports = rows.map(DoctorReportSummary.fromPhp).toList();
        _loading = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (mounted) setState(() => _contentVisible = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _contentVisible = true;
      });
    }
  }

  Future<void> _loadDoctorName(ApiClient api) async {
    try {
      final me = await api.getMe();
      final first = me['first_name']?.toString().trim() ?? '';
      final last = me['last_name']?.toString().trim() ?? '';
      final combined = '$first $last'.trim();
      if (!mounted) return;
      setState(() {
        _doctorDisplayName = combined.isEmpty ? '' : combined.split(' ').first;
      });
    } catch (_) {
      if (mounted) setState(() => _doctorDisplayName = '');
    }
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw.replaceAll(' ', 'T'))?.toLocal();
  }

  bool _isToday(DateTime? dt) {
    if (dt == null) return false;
    final n = DateTime.now();
    return dt.year == n.year && dt.month == n.month && dt.day == n.day;
  }

  bool _isNewCase(DoctorReportSummary r) {
    final dt = _parseDate(r.createdAt);
    if (dt == null) return false;
    return DateTime.now().difference(dt) <= const Duration(hours: 24);
  }

  int _pendingRepliesHeuristic(List<DoctorReportSummary> list) {
    return list.where((r) {
      final dt = _parseDate(r.createdAt);
      if (dt == null) return false;
      return DateTime.now().difference(dt) <= const Duration(hours: 48);
    }).length;
  }

  List<DoctorReportSummary> get _filtered {
    return _reports
        .where((r) => DoctorDiagnosisStyle.matchesFilter(r.diagnosis, _filterKey))
        .toList();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = _parseDate(raw);
    if (dt == null) return raw;
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  void _onNotifications() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No new notifications',
              style: Theme.of(ctx).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Case alerts will appear here.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiClient>();
    final auth = context.watch<AuthProvider>();
    final doctorId = auth.currentUserId;
    final total = _reports.length;
    final todayCount = _reports.where((r) => _isToday(_parseDate(r.createdAt))).length;
    final pending = _pendingRepliesHeuristic(_reports);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_information_outlined, size: 22, color: Colors.white.withValues(alpha: 0.95)),
                const SizedBox(width: 8),
                Text(
                  'Doctor Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _doctorDisplayName.isEmpty
                  ? 'Welcome'
                  : 'Welcome, Dr. $_doctorDisplayName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _onNotifications,
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? _DoctorHomeShimmer()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade500),
                        const SizedBox(height: 16),
                        Text(
                          'Couldn’t load cases',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: appPrimaryGreenDark,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.42,
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _load,
                          style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: appPrimaryGreen,
                  onRefresh: _load,
                  child: AnimatedOpacity(
                    opacity: _contentVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 8),
                            child: SizedBox(
                              height: 118,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                                children: [
                                  _StatCard(
                                    color: const Color(0xFF2563EB),
                                    icon: Icons.folder_shared_outlined,
                                    value: '$total',
                                    label: 'Total Cases',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatCard(
                                    color: const Color(0xFFEA580C),
                                    icon: Icons.mark_chat_unread_outlined,
                                    value: '$pending',
                                    label: 'Pending Replies',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatCard(
                                    color: appPrimaryGreen,
                                    icon: Icons.today_outlined,
                                    value: '$todayCount',
                                    label: "Today's Cases",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                            child: Text(
                              'Patient Cases',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: 'All',
                                    selected: _filterKey == 'all',
                                    onSelected: () => setState(() => _filterKey = 'all'),
                                  ),
                                  _FilterChip(
                                    label: 'Caries',
                                    selected: _filterKey == 'caries',
                                    onSelected: () => setState(() => _filterKey = 'caries'),
                                  ),
                                  _FilterChip(
                                    label: 'Tartar',
                                    selected: _filterKey == 'tartar',
                                    onSelected: () => setState(() => _filterKey = 'tartar'),
                                  ),
                                  _FilterChip(
                                    label: 'Gingivitis',
                                    selected: _filterKey == 'gingivitis',
                                    onSelected: () => setState(() => _filterKey = 'gingivitis'),
                                  ),
                                  _FilterChip(
                                    label: 'Healthy',
                                    selected: _filterKey == 'healthy',
                                    onSelected: () => setState(() => _filterKey = 'healthy'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (filtered.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyCasesState(onRefresh: _load),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final r = filtered[index];
                                  final imgUrl = api.resolveImageUrl(r.imagePath);
                                  final pct = (r.confidence * 100).clamp(0, 100).toStringAsFixed(0);
                                  final badgeColor = DoctorDiagnosisStyle.color(r.diagnosis);
                                  final badgeLabel = DoctorDiagnosisStyle.displayLabel(r.diagnosis);
                                  final isNew = _isNewCase(r);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: 1),
                                      duration: Duration(milliseconds: 320 + (index * 40).clamp(0, 200)),
                                      curve: Curves.easeOutCubic,
                                      child: _PatientCaseCard(
                                        patientName: r.patientName,
                                        imageUrl: imgUrl,
                                        diagnosisLabel: badgeLabel,
                                        diagnosisColor: badgeColor,
                                        confidencePct: pct,
                                        dateText: _formatDate(r.createdAt),
                                        showNewDot: isNew,
                                        onViewRespond: doctorId == null
                                            ? null
                                            : () {
                                                context.push(
                                                  '/doctor-report-detail',
                                                  extra: DoctorReportDetailArgs(
                                                    summary: r,
                                                    doctorId: doctorId,
                                                  ),
                                                );
                                              },
                                      ),
                                      builder: (context, t, child) => Opacity(
                                        opacity: t,
                                        child: Transform.translate(
                                          offset: Offset(0, 8 * (1 - t)),
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: filtered.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.color,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: appPrimaryGreen.withValues(alpha: 0.22),
        checkmarkColor: appPrimaryGreen,
        labelStyle: TextStyle(
          color: selected ? appPrimaryGreenDark : const Color(0xFF64748B),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
        side: BorderSide(
          color: selected ? appPrimaryGreen : Colors.grey.shade300,
          width: selected ? 1.4 : 1,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }
}

class _PatientCaseCard extends StatelessWidget {
  const _PatientCaseCard({
    required this.patientName,
    required this.imageUrl,
    required this.diagnosisLabel,
    required this.diagnosisColor,
    required this.confidencePct,
    required this.dateText,
    required this.showNewDot,
    required this.onViewRespond,
  });

  final String patientName;
  final String imageUrl;
  final String diagnosisLabel;
  final Color diagnosisColor;
  final String confidencePct;
  final String dateText;
  final bool showNewDot;
  final VoidCallback? onViewRespond;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onViewRespond,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: imageUrl.isEmpty
                              ? ColoredBox(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image_not_supported, color: Colors.grey.shade500),
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => ColoredBox(
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade500),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patientName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: diagnosisColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: diagnosisColor.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                diagnosisLabel,
                                style: TextStyle(
                                  color: diagnosisColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$confidencePct% confidence',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateText,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showNewDot)
                    PositionedDirectional(
                      start: -4,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton(
                  onPressed: onViewRespond,
                  style: FilledButton.styleFrom(
                    backgroundColor: appPrimaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View & Respond'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCasesState extends StatelessWidget {
  const _EmptyCasesState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 88,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              'No patient cases yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'New scans from patients will show up here.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => onRefresh(),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: appPrimaryGreen,
                side: const BorderSide(color: appPrimaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorHomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsetsDirectional.only(end: i < 2 ? 12 : 0),
                  child: Container(
                    width: 132,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(height: 18, width: 140, color: Colors.white),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Container(
                  width: 72,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                height: 168,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
