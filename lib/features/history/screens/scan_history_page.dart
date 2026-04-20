import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/models/scan_model.dart';
import '../widgets/scan_card.dart';

enum _SortOrder { newestFirst, oldestFirst }
enum _DiseaseFilter { all, caries, tartar, gingivitis }

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  List<ScanModel> _scans = [];
  final _searchController = TextEditingController();
  String _query = '';
  _SortOrder _sortOrder = _SortOrder.newestFirst;
  _DiseaseFilter _diseaseFilter = _DiseaseFilter.all;

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
        final disease = (s.diseaseType ?? '').toLowerCase();
        final dateStr = s.createdAt != null
            ? DateFormat('d MMMM yyyy').format(s.createdAt!).toLowerCase()
            : '';
        final shortDate = s.createdAt != null
            ? DateFormat('yyyy-MM-dd').format(s.createdAt!)
            : '';
        return disease.contains(q) ||
            dateStr.contains(q) ||
            shortDate.contains(q);
      }).toList();
    }
    switch (_diseaseFilter) {
      case _DiseaseFilter.caries:
        list = list.where((s) => (s.diseaseType ?? '').toLowerCase().contains('caries')).toList();
        break;
      case _DiseaseFilter.tartar:
        list = list.where((s) => (s.diseaseType ?? '').toLowerCase().contains('tartar')).toList();
        break;
      case _DiseaseFilter.gingivitis:
        list = list.where((s) => (s.diseaseType ?? '').toLowerCase().contains('gingivitis')).toList();
        break;
      case _DiseaseFilter.all:
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

  void _openDetails(ScanModel scan) {
    context.push('/history/details', extra: scan);
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

  Future<void> _confirmDelete(ScanModel scan) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteScan),
        content: Text(l10n.deleteScanConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<ApiClient>().deleteScan(scan.id);
      if (!mounted) return;
      setState(() => _scans.removeWhere((s) => s.id == scan.id));
    } catch (_) {
      if (!mounted) return;
      setState(() => _scans.removeWhere((s) => s.id == scan.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredScans;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanHistory),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchScans,
                prefixIcon: const Icon(Icons.search, color: appPrimaryGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.all),
                  selected: _diseaseFilter == _DiseaseFilter.all,
                  onSelected: (_) => setState(() => _diseaseFilter = _DiseaseFilter.all),
                  selectedColor: appPrimaryGreen.withValues(alpha: 0.3),
                  checkmarkColor: appPrimaryGreenDark,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.caries),
                  selected: _diseaseFilter == _DiseaseFilter.caries,
                  onSelected: (_) => setState(() => _diseaseFilter = _DiseaseFilter.caries),
                  selectedColor: appPrimaryGreen.withValues(alpha: 0.3),
                  checkmarkColor: appPrimaryGreenDark,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.tartar),
                  selected: _diseaseFilter == _DiseaseFilter.tartar,
                  onSelected: (_) => setState(() => _diseaseFilter = _DiseaseFilter.tartar),
                  selectedColor: appPrimaryGreen.withValues(alpha: 0.3),
                  checkmarkColor: appPrimaryGreenDark,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(l10n.gingivitis),
                  selected: _diseaseFilter == _DiseaseFilter.gingivitis,
                  onSelected: (_) => setState(() => _diseaseFilter = _DiseaseFilter.gingivitis),
                  selectedColor: appPrimaryGreen.withValues(alpha: 0.3),
                  checkmarkColor: appPrimaryGreenDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  l10n.sort,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.newestFirst),
                  selected: _sortOrder == _SortOrder.newestFirst,
                  onSelected: (_) => setState(() => _sortOrder = _SortOrder.newestFirst),
                  selectedColor: appPrimaryGreen.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: Text(l10n.oldestFirst),
                  selected: _sortOrder == _SortOrder.oldestFirst,
                  onSelected: (_) => setState(() => _sortOrder = _SortOrder.oldestFirst),
                  selectedColor: appPrimaryGreen.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _scans.isEmpty ? l10n.noScansYet : l10n.noScansMatch,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (_scans.isEmpty) ...[
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => context.push('/scan'),
                            icon: const Icon(Icons.add_a_photo, size: 20),
                            label: Text(l10n.newScan),
                            style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: appPrimaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final scan = filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ScanCard(
                            scan: scan,
                            onViewDetails: () => _openDetails(scan),
                            onDelete: () => _confirmDelete(scan),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
