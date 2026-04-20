import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/models/scan_model.dart';

enum _SortOrder { latestFirst, oldestFirst }
enum _SeverityFilter { all, mild, moderate, severe }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<ScanModel> _scans = [];
  final _searchController = TextEditingController();
  String _query = '';
  _SortOrder _sortOrder = _SortOrder.latestFirst;
  _SeverityFilter _severityFilter = _SeverityFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = context.read<ApiClient>();
      final list = await api.getScans();
      if (!mounted) return;
      setState(() {
        _scans = list.map((e) => ScanModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _scans = []);
    }
  }

  List<ScanModel> get _filteredScans {
    var list = List<ScanModel>.from(_scans);
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) {
        final dateStr = s.createdAt != null ? DateFormat.yMMMd().format(s.createdAt!) : '';
        final type = (s.diseaseType ?? '').toLowerCase();
        final severity = (s.severity ?? '').toLowerCase();
        final rec = (s.recommendation ?? '').toLowerCase();
        return dateStr.toLowerCase().contains(q) ||
            type.contains(q) ||
            severity.contains(q) ||
            rec.contains(q);
      }).toList();
    }
    switch (_severityFilter) {
      case _SeverityFilter.mild:
        list = list.where((s) => (s.severity ?? '').toLowerCase().contains('mild')).toList();
        break;
      case _SeverityFilter.moderate:
        list = list.where((s) => (s.severity ?? '').toLowerCase().contains('moderate')).toList();
        break;
      case _SeverityFilter.severe:
        list = list.where((s) => (s.severity ?? '').toLowerCase().contains('severe')).toList();
        break;
      case _SeverityFilter.all:
        break;
    }
    if (_sortOrder == _SortOrder.oldestFirst) {
      list.sort((a, b) {
        final ta = a.createdAt ?? DateTime(0);
        final tb = b.createdAt ?? DateTime(0);
        return ta.compareTo(tb);
      });
    } else {
      list.sort((a, b) {
        final ta = a.createdAt ?? DateTime(0);
        final tb = b.createdAt ?? DateTime(0);
        return tb.compareTo(ta);
      });
    }
    return list;
  }

  void _openDetail(ScanModel scan) {
    context.push('/reports/detail', extra: scan);
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
    if (chosen != null) await themeNotifier.setLocale(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredScans;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        title: Text(l10n.reports),
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onPressed: () => _showLanguagePicker(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by date, type, severity…',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<_SortOrder>(
                              value: _sortOrder,
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: _SortOrder.latestFirst, child: Text('Latest first')),
                                DropdownMenuItem(value: _SortOrder.oldestFirst, child: Text('Oldest first')),
                              ],
                              onChanged: (v) => setState(() => _sortOrder = v ?? _SortOrder.latestFirst),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<_SeverityFilter>(
                              value: _severityFilter,
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: _SeverityFilter.all, child: Text('All severity')),
                                DropdownMenuItem(value: _SeverityFilter.mild, child: Text('Mild')),
                                DropdownMenuItem(value: _SeverityFilter.moderate, child: Text('Moderate')),
                                DropdownMenuItem(value: _SeverityFilter.severe, child: Text('Severe')),
                              ],
                              onChanged: (v) => setState(() => _severityFilter = v ?? _SeverityFilter.all),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    _scans.isEmpty ? 'No reports yet' : 'No reports match your search',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                itemCount: filtered.length,
                                itemBuilder: (_, i) {
                                  final s = filtered[i];
                                  final dateStr = s.createdAt != null
                                      ? DateFormat.yMMMd().format(s.createdAt!)
                                      : '—';
                                  final type = s.diseaseType ?? 'Unknown';
                                  final severity = s.severity ?? '—';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () => _openDetail(s),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 18, color: appPrimaryGreen),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateStr,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                          color: appPrimaryGreenDark,
                                                          fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              type,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Result: $severity'
                                                  '${s.confidenceScore != null ? " • ${(s.confidenceScore! * 100).toStringAsFixed(0)}%" : ""}',
                                              style: TextStyle(color: Colors.grey.shade700),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'View details',
                                                  style: TextStyle(
                                                    color: appPrimaryGreen,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(Icons.chevron_right, size: 20, color: appPrimaryGreen),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
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
                  label: 'Scan History',
                  onTap: () => context.go('/history'),
                ),
              ),
              Expanded(
                child: _FooterNavItem(
                  icon: Icons.description,
                  label: 'Reports',
                  onTap: () {}, // current
                ),
              ),
              Expanded(
                child: _FooterNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () => context.go('/profile'),
                ),
              ),
            ],
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
