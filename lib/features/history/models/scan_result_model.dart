/// UI model for a scan result (maps from API ScanModel).
class ScanResultModel {
  final String id;
  final String? imagePath;
  final String diseaseName;
  final double confidence;
  final String severity;
  final DateTime? scanDate;

  ScanResultModel({
    required this.id,
    this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.scanDate,
  });
}
