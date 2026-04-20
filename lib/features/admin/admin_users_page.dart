import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/api/api_client.dart';

/// Role filter: `all` | `patients` | `doctors` | `pending`
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({
    super.key,
    this.initialFilter = 'all',
  });

  final String initialFilter;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  late String _filterKey;

  @override
  void initState() {
    super.initState();
    _filterKey = widget.initialFilter;
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<ApiClient>().adminGetUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
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

  Color _roleColor(String role) {
    switch (role) {
      case 'doctor':
        return Colors.green.shade700;
      case 'admin':
        return Colors.purple.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  bool _matchesFilter(Map<String, dynamic> u) {
    final role = u['role']?.toString() ?? 'patient';
    final approved = (u['is_approved'] is int)
        ? u['is_approved'] as int
        : int.tryParse(u['is_approved']?.toString() ?? '1') ?? 1;
    switch (_filterKey) {
      case 'patients':
        return role == 'patient';
      case 'doctors':
        return role == 'doctor';
      case 'pending':
        return role == 'doctor' && approved == 0;
      default:
        return true;
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _users.where((u) {
      if (!_matchesFilter(u)) return false;
      if (q.isEmpty) return true;
      final name = u['name']?.toString().toLowerCase() ?? '';
      final phone = u['phone']?.toString().toLowerCase() ?? '';
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  Future<void> _confirmDelete(Map<String, dynamic> u) async {
    final id = (u['id'] as num).toInt();
    final name = u['name']?.toString() ?? 'User';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Remove $name and their reports? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<ApiClient>().adminDeleteUser(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _changeRole(int userId, String newRole) async {
    try {
      await context.read<ApiClient>().adminChangeRole(userId, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role updated')));
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _approveDoctor(int userId, int flag) async {
    try {
      await context.read<ApiClient>().adminApproveDoctor(userId, flag);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(flag == 1 ? 'Doctor approved' : 'Doctor rejected')),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or phone',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _chip('All', 'all'),
              _chip('Patients', 'patients'),
              _chip('Doctors', 'doctors'),
              _chip('Pending', 'pending'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: appPrimaryGreen))
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: appPrimaryGreen,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final u = _filtered[index];
                          final id = (u['id'] as num).toInt();
                          final role = u['role']?.toString() ?? 'patient';
                          final approved = (u['is_approved'] is int)
                              ? u['is_approved'] as int
                              : int.tryParse(u['is_approved']?.toString() ?? '1') ?? 1;
                          final created = u['created_at']?.toString() ?? '';
                          final dateStr = DateTime.tryParse(created.replaceAll(' ', 'T')) != null
                              ? DateFormat.yMMMd()
                                  .format(DateTime.parse(created.replaceAll(' ', 'T')).toLocal())
                              : created;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              u['name']?.toString() ?? '—',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              u['phone']?.toString() ?? '',
                                              style: TextStyle(color: Colors.grey.shade700),
                                            ),
                                            Text(
                                              u['email']?.toString() ?? '',
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Chip(
                                            label: Text(
                                              role,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: _roleColor(role),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          if (role == 'doctor' && approved == 0)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Chip(
                                                label: const Text('⏳ Pending'),
                                                backgroundColor: Colors.orange.shade100,
                                                labelStyle: TextStyle(
                                                  color: Colors.orange.shade900,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 11,
                                                ),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Joined $dateStr',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  if (role == 'doctor' && approved == 0) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton(
                                            style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen),
                                            onPressed: () => _approveDoctor(id, 1),
                                            child: const Text('Approve'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _approveDoctor(id, 0),
                                            child: const Text('Reject'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: role,
                                          decoration: const InputDecoration(
                                            labelText: 'Role',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'patient', child: Text('Patient')),
                                            DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                          ],
                                          onChanged: (v) {
                                            if (v != null && v != role) {
                                              _changeRole(id, v);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton.filledTonal(
                                        onPressed: () => _confirmDelete(u),
                                        icon: const Icon(Icons.delete_outline),
                                        style: IconButton.styleFrom(foregroundColor: Colors.red.shade800),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _chip(String label, String key) {
    final selected = _filterKey == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filterKey = key),
        selectedColor: appPrimaryGreen.withValues(alpha: 0.25),
        checkmarkColor: appPrimaryGreen,
        labelStyle: TextStyle(
          color: selected ? appPrimaryGreenDark : Colors.grey.shade800,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
