class ScanModel {
  final String id;
  final String? imagePath;
  final String? diseaseType;
  final String? severity;
  final double? confidenceScore;
  final String? recommendation;
  final DateTime? createdAt;

  ScanModel({
    required this.id,
    this.imagePath,
    this.diseaseType,
    this.severity,
    this.confidenceScore,
    this.recommendation,
    this.createdAt,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id']?.toString() ?? '',
      imagePath: json['image_path'] as String?,
      diseaseType: json['disease_type'] as String?,
      severity: json['severity'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      recommendation: json['recommendation'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
