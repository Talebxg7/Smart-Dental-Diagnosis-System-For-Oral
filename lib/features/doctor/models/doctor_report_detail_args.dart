import 'doctor_report_summary.dart';

/// Passed as [GoRouterState.extra] to [DoctorReportDetailPage].
class DoctorReportDetailArgs {
  final DoctorReportSummary summary;
  final int doctorId;

  const DoctorReportDetailArgs({
    required this.summary,
    required this.doctorId,
  });
}
