import 'package:flutter/material.dart';

/// Shared diagnosis colors for doctor dashboard (matches product spec).
abstract final class DoctorDiagnosisStyle {
  static Color color(String diagnosis) {
    final d = diagnosis.toLowerCase();
    if (d.contains('healthy') || d.contains('normal')) {
      return const Color(0xFF16A34A);
    }
    if (d.contains('caries') || d.contains('decay')) {
      return const Color(0xFFDC2626);
    }
    if (d.contains('tartar') || d.contains('plaque')) {
      return const Color(0xFFEA580C);
    }
    if (d.contains('gingivitis')) {
      return const Color(0xFF9333EA);
    }
    return const Color(0xFF64748B);
  }

  /// Filter chip key → matches diagnosis string from API.
  static bool matchesFilter(String diagnosis, String filterKey) {
    if (filterKey == 'all') return true;
    final d = diagnosis.toLowerCase();
    switch (filterKey) {
      case 'caries':
        return d.contains('caries') || d.contains('decay');
      case 'tartar':
        return d.contains('tartar') || d.contains('plaque');
      case 'gingivitis':
        return d.contains('gingivitis');
      case 'healthy':
        return d.contains('healthy') || d.contains('normal');
      default:
        return true;
    }
  }

  static String displayLabel(String diagnosis) {
    final d = diagnosis.toLowerCase();
    if (d.contains('healthy') || d.contains('normal')) return 'Healthy';
    if (d.contains('caries') || d.contains('decay')) return 'Caries';
    if (d.contains('tartar') || d.contains('plaque')) return 'Tartar';
    if (d.contains('gingivitis')) return 'Gingivitis';
    return diagnosis;
  }
}
