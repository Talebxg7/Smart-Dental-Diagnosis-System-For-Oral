/// Row from [ApiClient.getAllReports] for navigation to detail.
class DoctorReportSummary {
  final int reportId;
  final int patientId;
  final String patientName;
  final String imagePath;
  final String diagnosis;
  final double confidence;
  final String? createdAt;

  const DoctorReportSummary({
    required this.reportId,
    required this.patientId,
    required this.patientName,
    required this.imagePath,
    required this.diagnosis,
    required this.confidence,
    this.createdAt,
  });

  factory DoctorReportSummary.fromPhp(Map<String, dynamic> j) {
    final conf = j['confidence'];
    double c = 0;
    if (conf is num) {
      c = conf.toDouble();
      if (c > 1) c /= 100;
    }
    return DoctorReportSummary(
      reportId: (j['id'] as num).toInt(),
      patientId: (j['patient_id'] as num).toInt(),
      patientName: j['patient_name']?.toString() ?? 'Patient',
      imagePath: j['image_path']?.toString() ?? '',
      diagnosis: j['result']?.toString() ?? '—',
      confidence: c,
      createdAt: j['created_at']?.toString(),
    );
  }
}
