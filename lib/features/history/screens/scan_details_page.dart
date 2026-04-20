import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/scan_model.dart';

class ScanDetailsPage extends StatelessWidget {
  final ScanModel scan;

  const ScanDetailsPage({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = scan.createdAt != null
        ? DateFormat('d MMMM yyyy').format(scan.createdAt!)
        : '—';
    final timeStr = scan.createdAt != null
        ? DateFormat('HH:mm').format(scan.createdAt!)
        : '';
    final dateTimeStr = timeStr.isNotEmpty ? '$dateStr at $timeStr' : dateStr;
    final confidence = scan.confidenceScore != null
        ? '${(scan.confidenceScore! * 100).toStringAsFixed(0)}%'
        : '—';
    final severity = scan.severity ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanResultDetails),
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
              clipBehavior: Clip.antiAlias,
              child: _buildFullImage(),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(context, l10n.condition, scan.diseaseType ?? '—'),
                    const SizedBox(height: 12),
                    _detailRow(context, l10n.confidence, confidence),
                    const SizedBox(height: 12),
                    _detailRow(context, l10n.severity, severity),
                    const SizedBox(height: 12),
                    _detailRow(context, l10n.scanDate, dateTimeStr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullImage() {
    if (scan.imagePath == null || scan.imagePath!.isEmpty) {
      return Container(
        height: 220,
        color: appLightMint,
        child: Center(
          child: Icon(Icons.image_not_supported, size: 48, color: appPrimaryGreen),
        ),
      );
    }
    if (scan.imagePath!.startsWith('http')) {
      return Image.network(
        scan.imagePath!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 220,
          color: appLightMint,
          child: Center(
            child: Icon(Icons.broken_image, size: 48, color: appPrimaryGreen),
          ),
        ),
      );
    }
    if (File(scan.imagePath!).existsSync()) {
      return Image.file(
        File(scan.imagePath!),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Container(
      height: 220,
      color: appLightMint,
      child: Center(
        child: Icon(Icons.image, size: 48, color: appPrimaryGreen),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: appPrimaryGreenDark,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
