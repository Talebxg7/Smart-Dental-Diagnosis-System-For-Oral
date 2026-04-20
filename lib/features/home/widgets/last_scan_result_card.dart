import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/scan_model.dart';

class LastScanResultCard extends StatelessWidget {
  final ScanModel? scan;
  final VoidCallback? onTap;

  const LastScanResultCard({super.key, this.scan, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (scan == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final confidence = scan!.confidenceScore != null
        ? '${(scan!.confidenceScore! * 100).round()}%'
        : '—';
    final diseaseLabel = (scan!.diseaseType ?? '').trim().isEmpty
        ? l10n.unknown
        : (scan!.diseaseType!.toLowerCase() == 'caries'
            ? l10n.caries
            : scan!.diseaseType!.toLowerCase() == 'tartar'
                ? l10n.tartar
                : scan!.diseaseType!.toLowerCase() == 'gingivitis'
                    ? l10n.gingivitis
                    : scan!.diseaseType!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lastScanResult,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appPrimaryGreenDark,
              ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: appLightMint,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.diseaseDetected(diseaseLabel),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appPrimaryGreenDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(label: '${l10n.confidence}: $confidence'),
                      if (scan!.severity != null && scan!.severity!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _Chip(label: '${l10n.severity}: ${scan!.severity}'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: appPrimaryGreenDark,
            ),
      ),
    );
  }
}
