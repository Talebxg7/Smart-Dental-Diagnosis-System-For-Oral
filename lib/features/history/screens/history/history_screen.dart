import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/models/scan_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanModel> _scans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final list = await api.getScans();
      if (!mounted) return;
      setState(() {
        _scans = list
            .map((e) => ScanModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scans = [];
        _loading = false;
        _error = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _scans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No scans yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () => context.go('/scan'),
                            child: const Text('New Scan'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _scans.length,
                        itemBuilder: (_, i) {
                          final s = _scans[i];
                          final date = s.createdAt != null
                              ? DateFormat.yMMMd().format(s.createdAt!)
                              : '—';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(s.diseaseType ?? 'Unknown'),
                              subtitle: Text(
                                  '${s.severity ?? '—'} • ${s.confidenceScore != null ? '${(s.confidenceScore! * 100).toStringAsFixed(0)}%' : '—'} • $date'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push('/result', extra: {
                                'scanId': s.id,
                                'diseaseType': s.diseaseType,
                                'severity': s.severity,
                                'confidence': s.confidenceScore,
                                'recommendation': s.recommendation,
                              }),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
