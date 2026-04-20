import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/scan_model.dart';

class ScanCard extends StatelessWidget {
  final ScanModel scan;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;

  const ScanCard({
    super.key,
    required this.scan,
    required this.onViewDetails,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = scan.createdAt != null
        ? DateFormat('d MMMM yyyy').format(scan.createdAt!)
        : '—';
    final disease = scan.diseaseType ?? l10n.unknown;
    final confidence = scan.confidenceScore != null
        ? '${(scan.confidenceScore! * 100).toStringAsFixed(0)}%'
        : '—';

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildThumbnail(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.diagnosisDetected(disease),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: appPrimaryGreenDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.confidence}: $confidence',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.date}: $dateStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  onViewDetails();
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: Text(l10n.viewDetails),
                style: FilledButton.styleFrom(
                  backgroundColor: appPrimaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildThumbnail() {
    if (scan.imagePath == null || scan.imagePath!.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        color: appLightMint,
        child: Icon(Icons.image_not_supported, color: appPrimaryGreen, size: 32),
      );
    }
    if (scan.imagePath!.startsWith('http')) {
      return Image.network(
        scan.imagePath!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 72,
          height: 72,
          color: appLightMint,
          child: Icon(Icons.broken_image, color: appPrimaryGreen, size: 28),
        ),
      );
    }
    if (File(scan.imagePath!).existsSync()) {
      return Image.file(
        File(scan.imagePath!),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: 72,
      height: 72,
      color: appLightMint,
      child: Icon(Icons.image, color: appPrimaryGreen, size: 28),
    );
  }
}
