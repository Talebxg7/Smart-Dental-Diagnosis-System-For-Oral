import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/api/api_client.dart';
import '../../shared/auth/auth_provider.dart';

class PatientMessagesPage extends StatefulWidget {
  const PatientMessagesPage({super.key});

  @override
  State<PatientMessagesPage> createState() => _PatientMessagesPageState();
}

class _PatientMessagesPageState extends State<PatientMessagesPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReports());
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final raw = await api.getScans();
      if (!mounted) return;
      setState(() {
        _reports = raw.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return raw;
    return DateFormat.yMMMd().add_jm().format(dt.toLocal());
  }

  String _diagnosisLabel(String? d) {
    if (d == null || d.isEmpty) return 'Unknown';
    return d
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Color _diagnosisColor(String? d) {
    switch ((d ?? '').toLowerCase()) {
      case 'caries':
        return const Color(0xFFEF4444);
      case 'tartar':
        return const Color(0xFFF59E0B);
      case 'gingivitis':
        return const Color(0xFF8B5CF6);
      case 'healthy':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? _MessagesShimmer()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _loadReports,
                          style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 72, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No scans yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'After you scan, doctors can send you messages here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: appPrimaryGreen,
                      onRefresh: _loadReports,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final r = _reports[index];
                          final id = r['id']?.toString() ?? '';
                          final diagnosis = r['disease_type']?.toString() ?? '';
                          final color = _diagnosisColor(diagnosis);
                          final label = _diagnosisLabel(diagnosis);
                          final date = _formatDate(r['created_at']?.toString());
                          final confidence = ((r['confidence_score'] as num?)?.toDouble() ?? 0) * 100;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Material(
                              color: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  if (id.isEmpty) return;
                                  final reportIdInt = int.tryParse(id);
                                  if (reportIdInt == null) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => _PatientChatPage(
                                        reportId: reportIdInt,
                                        diagnosisLabel: label,
                                        diagnosisColor: color,
                                        date: date,
                                        imageUrl: r['image_path']?.toString() ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.chat_rounded,
                                          color: color,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: color.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                                  ),
                                                  child: Text(
                                                    label,
                                                    style: TextStyle(
                                                      color: color,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${confidence.toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              date,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─── Patient Chat Page ──────────────────────────────────────────────────────

class _PatientChatPage extends StatefulWidget {
  const _PatientChatPage({
    required this.reportId,
    required this.diagnosisLabel,
    required this.diagnosisColor,
    required this.date,
    required this.imageUrl,
  });

  final int reportId;
  final String diagnosisLabel;
  final Color diagnosisColor;
  final String date;
  final String imageUrl;

  @override
  State<_PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<_PatientChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  int? _patientId;
  String _doctorName = 'Doctor'; // resolved after first doctor message loads

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      _patientId = auth.currentUserId;
      await _loadMessages();
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
      final list = await api.getMessages(widget.reportId);
      if (!mounted) return;
      list.sort((a, b) {
        final ta = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime(1970);
        final tb = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime(1970);
        return ta.compareTo(tb);
      });
      setState(() {
        _messages = list;
        _loading = false;
        // Resolve doctor name from the first doctor message that has one
        for (final msg in list) {
          if (msg['sender_role'] == 'doctor') {
            final name = msg['doctor_name']?.toString();
            if (name != null && name.isNotEmpty) {
              _doctorName = 'Dr. $name';
              break;
            }
          }
        }
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

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return raw;
    return DateFormat.jm().format(dt.toLocal());
  }

  String _formatAppointment(String raw) {
    final dt = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (dt == null) return raw;
    return DateFormat.yMMMMEEEEd().add_jm().format(dt.toLocal());
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (_patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final api = context.read<ApiClient>();
      await api.sendMessage(
        reportId: widget.reportId,
        doctorId: 0,
        patientId: _patientId!,
        senderRole: 'patient',
        message: text,
      );
      if (!mounted) return;
      _textController.clear();
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
    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _doctorName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              widget.diagnosisLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.diagnosisColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.diagnosisColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.diagnosisLabel,
                  style: TextStyle(
                    color: widget.diagnosisColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '•  ${widget.date}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Messages
          Expanded(
            child: _loading
                ? _ChatShimmer()
                : _error != null
                    ? Center(
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
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No messages yet.\nSend a message to your doctor.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final m = _messages[index];
                              final role = m['sender_role']?.toString() ?? '';
                              final isPatient = role == 'patient';
                              final body = m['message']?.toString() ?? '';
                              final appt = m['appointment_date']?.toString();
                              final timeStr = _formatTime(m['created_at']?.toString());

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment: isPatient
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (appt != null && appt.isNotEmpty)
                                      Align(
                                        alignment: isPatient
                                            ? AlignmentDirectional.centerEnd
                                            : AlignmentDirectional.centerStart,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.65)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.calendar_month_rounded, color: Colors.blue.shade700, size: 22),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Appointment Scheduled',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 13,
                                                      color: Colors.blue.shade900,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _formatAppointment(appt),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 13,
                                                      color: Colors.blue.shade800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    Align(
                                      alignment: isPatient
                                          ? AlignmentDirectional.centerEnd
                                          : AlignmentDirectional.centerStart,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isPatient
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: isPatient ? appPrimaryGreen : Colors.white,
                                                borderRadius: BorderRadiusDirectional.only(
                                                  topStart: const Radius.circular(18),
                                                  topEnd: const Radius.circular(18),
                                                  bottomStart: Radius.circular(isPatient ? 18 : 4),
                                                  bottomEnd: Radius.circular(isPatient ? 4 : 18),
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
                                                    color: isPatient ? Colors.white : const Color(0xFF1E293B),
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
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 2),
                                              child: Text(
                                                isPatient ? 'You' : _doctorName,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isPatient ? appPrimaryGreenDark : Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          // Input bar
          Material(
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Write a message to your doctor...',
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
              ),
            ),
          ),
        ],
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

class _MessagesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
