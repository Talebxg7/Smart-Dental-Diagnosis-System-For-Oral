import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/scan_model.dart';

class RecentScansSection extends StatelessWidget {
  final List<ScanModel> scans;
  final bool loading;
  final void Function(ScanModel scan) onTapScan;
  final VoidCallback? onTapEmpty;

  const RecentScansSection({
    super.key,
    required this.scans,
    required this.loading,
    required this.onTapScan,
    this.onTapEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: appPrimaryGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              l10n.recentScans,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: appPrimaryGreenDark,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: appPrimaryGreen),
            ),
          )
        else if (scans.isEmpty)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: InkWell(
              onTap: onTapEmpty,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noScansYet,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.startFirstScan,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...scans.take(5).map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ScanTile(scan: s, onTap: () => onTapScan(s)),
                ),
              ),
      ],
    );
  }
}

class _ScanTile extends StatelessWidget {
  final ScanModel scan;
  final VoidCallback onTap;

  const _ScanTile({required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = scan.createdAt != null
        ? DateFormat('d MMM').format(scan.createdAt!)
        : '—';
    final confidence = scan.confidenceScore != null
        ? '${(scan.confidenceScore! * 100).round()}%'
        : '—';
    final diseaseLabel = scan.diseaseType?.trim().isEmpty ?? true
        ? l10n.unknown
        : (scan.diseaseType!.toLowerCase() == 'caries'
            ? l10n.caries
            : scan.diseaseType!.toLowerCase() == 'tartar'
                ? l10n.tartar
                : scan.diseaseType!.toLowerCase() == 'gingivitis'
                    ? l10n.gingivitis
                    : scan.diseaseType!);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: appLightMint,
          child: Icon(Icons.medical_services, color: appPrimaryGreen, size: 22),
        ),
        title: Text(
          l10n.diseaseDetected(diseaseLabel),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${l10n.confidence}: $confidence • ${l10n.date}: $date'),
        trailing: const Icon(Icons.chevron_right, color: appPrimaryGreen),
        onTap: onTap,
      ),
    );
  }
}
