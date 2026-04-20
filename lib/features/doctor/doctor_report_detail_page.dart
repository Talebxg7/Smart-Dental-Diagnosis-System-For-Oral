import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/api/api_client.dart';
import 'doctor_diagnosis_style.dart';
import 'models/doctor_report_detail_args.dart';
import 'models/doctor_report_summary.dart';

const Color _appointmentCardBlue = Color(0xFFE0F2FE);
const Color _appointmentCardBorder = Color(0xFF38BDF8);

class DoctorReportDetailPage extends StatefulWidget {
  const DoctorReportDetailPage({
    super.key,
    required this.args,
  });

  final DoctorReportDetailArgs args;

  @override
  State<DoctorReportDetailPage> createState() => _DoctorReportDetailPageState();
}

class _DoctorReportDetailPageState extends State<DoctorReportDetailPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  DateTime? _pendingAppointment;
  bool _headerVisible = false;

  DoctorReportSummary get _summary => widget.args.summary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (mounted) setState(() => _headerVisible = true);
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final list = await api.getMessages(_summary.reportId);
      if (!mounted) return;
      list.sort((a, b) {
        final ta = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(1970);
        final tb = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(1970);
        return ta.compareTo(tb);
      });
      setState(() {
        _messages = list;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  String _formatMessageTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return raw;
    return DateFormat.jm().format(dt.toLocal());
  }

  String _formatScanDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return raw;
    return DateFormat.yMMMd().add_jm().format(dt.toLocal());
  }

  String _formatAppointmentChip(DateTime dt) {
    return DateFormat('EEE d MMM, h:mm a').format(dt.toLocal());
  }

  String _patientInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _pickAppointment() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pendingAppointment ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pendingAppointment ?? now),
    );
    if (!mounted || time == null) return;
    setState(() {
      _pendingAppointment = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    final apptIso = _pendingAppointment?.toIso8601String();
    if (text.isEmpty && (apptIso == null || apptIso.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a message or pick an appointment time.')),
      );
      return;
    }
    final messageBody = text.isEmpty ? 'Suggested appointment' : text;

    setState(() => _sending = true);
    try {
      final api = context.read<ApiClient>();
      await api.sendMessage(
        reportId: _summary.reportId,
        doctorId: widget.args.doctorId,
        patientId: _summary.patientId,
        senderRole: 'doctor',
        message: messageBody,
        appointmentDate: apptIso,
      );
      if (!mounted) return;
      _textController.clear();
      setState(() => _pendingAppointment = null);
      await _loadMessages();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiClient>();
    final imgUrl = api.resolveImageUrl(_summary.imagePath);
    final pct = (_summary.confidence * 100).clamp(0, 100).toStringAsFixed(0);
    final confValue = _summary.confidence.clamp(0.0, 1.0);
    final badgeColor = DoctorDiagnosisStyle.color(_summary.diagnosis);
    final badgeLabel = DoctorDiagnosisStyle.displayLabel(_summary.diagnosis);

    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Patient Report',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: AnimatedOpacity(
                    opacity: _headerVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOut,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                          child: SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: imgUrl.isEmpty
                                ? ColoredBox(
                                    color: Colors.grey.shade300,
                                    child: Icon(Icons.image_not_supported, size: 56, color: Colors.grey.shade500),
                                  )
                                : Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => ColoredBox(
                                      color: Colors.grey.shade300,
                                      child: Icon(Icons.broken_image_outlined, size: 56, color: Colors.grey.shade500),
                                    ),
                                  ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -28),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Material(
                              elevation: 4,
                              shadowColor: Colors.black.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: appPrimaryGreen.withValues(alpha: 0.15),
                                          child: Text(
                                            _patientInitials(_summary.patientName),
                                            style: TextStyle(
                                              color: appPrimaryGreenDark,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _summary.patientName,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w800,
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: badgeColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
                                                ),
                                                child: Text(
                                                  badgeLabel,
                                                  style: TextStyle(
                                                    color: badgeColor,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text(
                                          '$pct% confidence',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: confValue,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.shade200,
                                        color: appPrimaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, size: 18, color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Scan: ${_formatScanDate(_summary.createdAt)}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                            child: Text(
                              'Conversation',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF334155),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loading)
                  SliverToBoxAdapter(child: _ChatShimmer())
                else if (_error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _loadMessages,
                              style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_messages.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No messages yet. Start the conversation below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final m = _messages[index];
                          final role = m['sender_role']?.toString() ?? '';
                          final isDoctor = role == 'doctor';
                          final body = m['message']?.toString() ?? '';
                          final appt = m['appointment_date']?.toString();
                          final timeStr = _formatMessageTime(m['created_at']?.toString());

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 280 + (index * 25).clamp(0, 120)),
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: isDoctor
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (appt != null && appt.isNotEmpty)
                                    Align(
                                      alignment: isDoctor
                                          ? AlignmentDirectional.centerEnd
                                          : AlignmentDirectional.centerStart,
                                      child: _AppointmentScheduledCard(
                                        formatted: _formatAppointmentCard(appt),
                                      ),
                                    ),
                                  Align(
                                    alignment: isDoctor
                                        ? AlignmentDirectional.centerEnd
                                        : AlignmentDirectional.centerStart,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isDoctor
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: isDoctor ? appPrimaryGreen : Colors.grey.shade200,
                                              borderRadius: BorderRadiusDirectional.only(
                                                topStart: const Radius.circular(18),
                                                topEnd: const Radius.circular(18),
                                                bottomStart: Radius.circular(isDoctor ? 18 : 4),
                                                bottomEnd: Radius.circular(isDoctor ? 4 : 18),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              child: Text(
                                                body,
                                                style: TextStyle(
                                                  color: isDoctor ? Colors.white : const Color(0xFF1E293B),
                                                  height: 1.35,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
                                            child: Text(
                                              timeStr,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 2),
                                            child: Text(
                                              isDoctor ? 'You' : _summary.patientName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDoctor ? appPrimaryGreenDark : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            builder: (context, t, child) => Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(0, 6 * (1 - t)),
                                child: child,
                              ),
                            ),
                          );
                        },
                        childCount: _messages.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Material(
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_pendingAppointment != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: InputChip(
                            avatar: const Text('📅', style: TextStyle(fontSize: 14)),
                            label: Text(
                              _formatAppointmentChip(_pendingAppointment!),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => setState(() => _pendingAppointment = null),
                            backgroundColor: appLightMint,
                            side: BorderSide(color: appPrimaryGreen.withValues(alpha: 0.35)),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          ),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: 4,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Write a message...',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: appPrimaryGreen, width: 1.5),
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Schedule appointment',
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                          ),
                          onPressed: _pickAppointment,
                          icon: const Icon(Icons.calendar_month_rounded),
                        ),
                        _sending
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: appPrimaryGreen),
                                ),
                              )
                            : Material(
                                color: appPrimaryGreen,
                                shape: const CircleBorder(),
                                elevation: 2,
                                shadowColor: appPrimaryGreen.withValues(alpha: 0.45),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _send,
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAppointmentCard(String raw) {
    final dt = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return raw;
    return DateFormat.yMMMMEEEEd().add_jm().format(dt.toLocal());
  }
}

class _AppointmentScheduledCard extends StatelessWidget {
  const _AppointmentScheduledCard({required this.formatted});

  final String formatted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _appointmentCardBlue,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _appointmentCardBorder.withValues(alpha: 0.65)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_month_rounded, color: Colors.blue.shade700, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '📅 ',
                          style: TextStyle(fontSize: 15, height: 1.2, color: Colors.blue.shade900),
                        ),
                        Expanded(
                          child: Text(
                            'Appointment Scheduled',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatted,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: List.generate(
            5,
            (i) => Padding(
              padding: EdgeInsetsDirectional.only(
                bottom: 12,
                start: i.isEven ? 0 : 48,
                end: i.isEven ? 48 : 0,
              ),
              child: Container(
                height: i.isEven ? 52 : 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
