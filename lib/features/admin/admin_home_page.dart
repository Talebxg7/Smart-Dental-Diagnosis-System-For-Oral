import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/api/api_client.dart';
import '../../shared/auth/auth_provider.dart';
import 'admin_messages_page.dart';
import 'admin_users_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _tab = 0;
  int _usersTabKey = 0;
  String _usersInitialFilter = 'all';
  bool _pendingShortcut = false;

  void _goUsersWithPending() {
    setState(() {
      _pendingShortcut = true;
      _usersTabKey++;
      _usersInitialFilter = 'pending';
      _tab = 1;
    });
  }

  void _onNavSelected(int index) {
    setState(() {
      if (index == 1) {
        _usersTabKey++;
        if (!_pendingShortcut) {
          _usersInitialFilter = 'all';
        }
        _pendingShortcut = false;
      }
      _tab = index;
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _AdminDashboardTab(onPendingTap: _goUsersWithPending),
          AdminUsersPage(
            key: ValueKey(_usersTabKey),
            initialFilter: _usersInitialFilter,
          ),
          const AdminMessagesPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onNavSelected,
        indicatorColor: appPrimaryGreen.withValues(alpha: 0.28),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardTab extends StatefulWidget {
  const _AdminDashboardTab({required this.onPendingTap});

  final VoidCallback onPendingTap;

  @override
  State<_AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<_AdminDashboardTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await context.read<ApiClient>().adminGetStats();
      if (!mounted) return;
      setState(() {
        _stats = s;
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

  int _i(String k) {
    final v = _stats?[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: appPrimaryGreen));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final top = _stats?['most_common_diagnosis'];
    String diagLabel = '—';
    String diagCount = '';
    if (top is Map) {
      diagLabel = top['result']?.toString() ?? '—';
      final c = top['count'];
      if (c != null) diagCount = ' ($c scans)';
    }

    return RefreshIndicator(
      color: appPrimaryGreen,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                _StatCard(
                  title: 'Total Users',
                  value: '${_i('total_users')}',
                  icon: Icons.groups_outlined,
                  color: Colors.blue.shade700,
                ),
                _StatCard(
                  title: 'Total Doctors',
                  value: '${_i('total_doctors')}',
                  icon: Icons.medical_services_outlined,
                  color: Colors.green.shade700,
                ),
                _StatCard(
                  title: 'Pending Approvals',
                  value: '${_i('pending_doctors')}',
                  icon: Icons.hourglass_top_outlined,
                  color: Colors.orange.shade800,
                  onTap: widget.onPendingTap,
                ),
                _StatCard(
                  title: 'Total Scans',
                  value: '${_i('total_reports')}',
                  icon: Icons.document_scanner_outlined,
                  color: Colors.teal.shade700,
                ),
                _StatCard(
                  title: 'Scans Today',
                  value: '${_i('reports_today')}',
                  icon: Icons.today_outlined,
                  color: Colors.red.shade700,
                ),
                _StatCard(
                  title: 'Top Diagnosis',
                  value: diagLabel,
                  subtitle: diagCount.isEmpty ? null : diagCount.trim(),
                  icon: Icons.analytics_outlined,
                  color: Colors.deepPurple.shade700,
                  multilineValue: true,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.multilineValue = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool multilineValue;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: multilineValue ? 3 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: multilineValue ? 14 : 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }
    return card;
  }
}
