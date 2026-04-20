import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../shared/auth/auth_provider.dart';
import '../../../../shared/models/scan_model.dart';

const _kAvatarPathKey = 'profile_avatar_path';
const _kNotificationsKey = 'profile_notifications_enabled';
const _kPrivacyKey = 'profile_privacy_show_scans';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  List<ScanModel> _scans = [];
  String? _avatarPath;
  bool _notificationsEnabled = true;
  bool _privacyShowScans = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _avatarPath = prefs.getString(_kAvatarPathKey);
        _notificationsEnabled = prefs.getBool(_kNotificationsKey) ?? true;
        _privacyShowScans = prefs.getBool(_kPrivacyKey) ?? true;
      });
    } catch (_) {
      // Ignore; use defaults
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final api = context.read<ApiClient>();
      // Timeout so we never hang forever (e.g. no backend or slow network)
      final me = await api.getMe().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );
      if (!mounted) return;
      final list = await api.getScans().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );
      if (!mounted) return;
      setState(() {
        _user = me;
        _scans = list.map((e) => ScanModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (_) {
      // Not logged in, timeout, or API error: show profile as Guest
      if (mounted) {
        setState(() {
          _user = null;
          _scans = [];
        });
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 400, imageQuality: 85);
    if (file == null || !mounted) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/profile_avatar.jpg');
    await dest.writeAsBytes(await file.readAsBytes());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarPathKey, dest.path);
    setState(() => _avatarPath = dest.path);
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsKey, _notificationsEnabled);
    await prefs.setBool(_kPrivacyKey, _privacyShowScans);
  }

  void _showEditProfile() {
    final first = TextEditingController(text: _user?['first_name']?.toString() ?? '');
    final last = TextEditingController(text: _user?['last_name']?.toString() ?? '');
    final phone = TextEditingController(text: _user?['phone']?.toString() ?? '');
    final email = TextEditingController(text: _user?['email']?.toString() ?? '');
    final api = context.read<ApiClient>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppLocalizations.of(ctx)!.editProfile, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: first, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.firstName)),
              const SizedBox(height: 12),
              TextField(controller: last, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.lastName)),
              const SizedBox(height: 12),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.phone)),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.email),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  try {
                    await api.updateMe(
                      firstName: first.text.trim(),
                      lastName: last.text.trim(),
                      phone: phone.text.trim(),
                      email: email.text.trim(),
                    );
                    if (!mounted) return;
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _load();
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                },
                child: Text(AppLocalizations.of(ctx)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePassword() {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final confirm = TextEditingController();
    final api = context.read<ApiClient>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_reset, color: appPrimaryGreen, size: 28),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(ctx)!.changePassword, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: appPrimaryGreenDark)),
                ],
              ),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(ctx)!.changePasswordDescription, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 20),
              TextField(
                controller: current,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx)!.currentPassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx)!.newPassword,
                  prefixIcon: const Icon(Icons.lock, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  helperText: AppLocalizations.of(ctx)!.atLeast6Chars,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(ctx)!.confirmNewPassword,
                  prefixIcon: const Icon(Icons.lock, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final loc = AppLocalizations.of(ctx)!;
                  if (_user == null) {
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.pleaseSignInToChangePassword)));
                    return;
                  }
                  if (current.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.enterCurrentPassword)));
                    return;
                  }
                  if (newPass.text != confirm.text) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.passwordsDoNotMatch)));
                    return;
                  }
                  if (newPass.text.length < 6) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(loc.newPasswordMinLength)));
                    return;
                  }
                  try {
                    await api.changePassword(current.text, newPass.text);
                    if (!mounted) return;
                    Navigator.pop(context);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.passwordUpdated)));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(AppLocalizations.of(ctx)!.updatePassword),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    await auth.logout();
    if (!mounted) return;
    router.go('/login');
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: Text(l10n.password),
          content: TextField(
            controller: c,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.password,
              hintText: l10n.enterCurrentPassword,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (password == null || password.isEmpty || !mounted) return;
    final api = context.read<ApiClient>();
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.deleteAccount(accountPassword: password);
      await auth.logout();
      if (!mounted) return;
      router.go('/login');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user != null
        ? '${_user!['first_name'] ?? ''} ${_user!['last_name'] ?? ''}'.trim()
        : 'Guest';
    final email = _user?['email']?.toString() ?? '—';
    final phone = _user?['phone']?.toString() ?? '—';

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UserInfoSection(
              avatarPath: _avatarPath,
              displayName: displayName.isEmpty ? l10n.guest : displayName,
              email: email,
              phone: phone,
              isGuest: _user == null,
              onPickAvatar: _pickAvatar,
              onEdit: _showEditProfile,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            _AccountSettingsSection(
              isGuest: _user == null,
              notificationsEnabled: _notificationsEnabled,
              privacyShowScans: _privacyShowScans,
              onNotificationsChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _savePrefs();
              },
              onPrivacyChanged: (v) {
                setState(() => _privacyShowScans = v);
                _savePrefs();
              },
              onChangePassword: _showChangePassword,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            _ActivitySection(
              scanCount: _scans.length,
              onRecentScans: () => context.push('/history'),
              onHistory: () => context.push('/history'),
              onReports: () => context.push('/reports'),
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            _AppPreferencesSection(
              themeNotifier: context.watch<ThemeModeNotifier>(),
              l10n: AppLocalizations.of(context)!,
            ),
            const SizedBox(height: 24),
            _LogoutDeleteSection(
              isGuest: _user == null,
              onLogout: _logout,
              onDeleteAccount: _deleteAccount,
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppPreferencesSection extends StatelessWidget {
  final ThemeModeNotifier themeNotifier;
  final AppLocalizations l10n;

  const _AppPreferencesSection({
    required this.themeNotifier,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appPreferences, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: appPrimaryGreenDark)),
            const SizedBox(height: 12),
            Text(l10n.theme, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, icon: const Icon(Icons.light_mode), label: Text(l10n.light)),
                ButtonSegment(value: true, icon: const Icon(Icons.dark_mode), label: Text(l10n.dark)),
              ],
              selected: {themeNotifier.isDark},
              onSelectionChanged: (s) => themeNotifier.setThemeMode(s.first),
              style: ButtonStyle(visualDensity: VisualDensity.compact, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language, color: appPrimaryGreen),
              title: Text(l10n.language),
              subtitle: Text(
                themeNotifier.locale.languageCode == 'ar'
                    ? l10n.arabic
                    : themeNotifier.locale.languageCode == 'tr'
                        ? l10n.turkish
                        : l10n.english,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final chosen = await showModalBottomSheet<Locale>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(l10n.english),
                          leading: const Icon(Icons.language),
                          onTap: () => Navigator.pop(ctx, const Locale('en')),
                        ),
                        ListTile(
                          title: Text(l10n.arabic),
                          leading: const Icon(Icons.language),
                          onTap: () => Navigator.pop(ctx, const Locale('ar')),
                        ),
                        ListTile(
                          title: Text(l10n.turkish),
                          leading: const Icon(Icons.language),
                          onTap: () => Navigator.pop(ctx, const Locale('tr')),
                        ),
                      ],
                    ),
                  ),
                );
                if (chosen != null) await themeNotifier.setLocale(chosen);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final String? avatarPath;
  final String displayName;
  final String email;
  final String phone;
  final bool isGuest;
  final VoidCallback onPickAvatar;
  final VoidCallback onEdit;
  final AppLocalizations l10n;

  const _UserInfoSection({
    required this.avatarPath,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.isGuest,
    required this.onPickAvatar,
    required this.onEdit,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: onPickAvatar,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: appLightMint,
                backgroundImage: avatarPath != null && File(avatarPath!).existsSync()
                    ? FileImage(File(avatarPath!))
                    : null,
                child: avatarPath != null && File(avatarPath!).existsSync()
                    ? null
                    : Icon(Icons.person, size: 48, color: appPrimaryGreen),
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.tapToChangePhoto, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Text(displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: appPrimaryGreenDark)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.email_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(email, style: TextStyle(color: Colors.grey.shade700)),
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(phone, style: TextStyle(color: Colors.grey.shade700)),
            ]),
            if (!isGuest) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: Text(l10n.editProfile),
                style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountSettingsSection extends StatelessWidget {
  final bool isGuest;
  final bool notificationsEnabled;
  final bool privacyShowScans;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final VoidCallback onChangePassword;
  final AppLocalizations l10n;

  const _AccountSettingsSection({
    required this.isGuest,
    required this.notificationsEnabled,
    required this.privacyShowScans,
    required this.onNotificationsChanged,
    required this.onPrivacyChanged,
    required this.onChangePassword,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.accountSettings, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: appPrimaryGreenDark)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline, color: appPrimaryGreen),
              title: Text(l10n.changePassword),
              subtitle: Text(l10n.changePasswordSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: onChangePassword,
            ),
            SwitchListTile(
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
              title: Text(l10n.notifications),
              subtitle: Text(l10n.notificationsSubtitle),
              activeColor: appPrimaryGreen,
            ),
            SwitchListTile(
              value: privacyShowScans,
              onChanged: onPrivacyChanged,
              title: Text(l10n.scanVisibility),
              subtitle: Text(l10n.scanVisibilitySubtitle),
              activeColor: appPrimaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final int scanCount;
  final VoidCallback onRecentScans;
  final VoidCallback onHistory;
  final VoidCallback onReports;
  final AppLocalizations l10n;

  const _ActivitySection({
    required this.scanCount,
    required this.onRecentScans,
    required this.onHistory,
    required this.onReports,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.activitySummary, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: appPrimaryGreenDark)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.photo_camera, color: appPrimaryGreen, size: 28),
                const SizedBox(width: 12),
                Text(l10n.scans, style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('$scanCount', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: appPrimaryGreen)),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.recent_actors, color: appPrimaryGreen),
              title: Text(l10n.recentScans),
              subtitle: Text(l10n.quickAccessLatestScans),
              trailing: const Icon(Icons.chevron_right),
              onTap: onRecentScans,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: appPrimaryGreen),
              title: Text(l10n.scanHistory),
              trailing: const Icon(Icons.chevron_right),
              onTap: onHistory,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description, color: appPrimaryGreen),
              title: Text(l10n.reports),
              subtitle: Text(l10n.viewYourReports),
              trailing: const Icon(Icons.chevron_right),
              onTap: onReports,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutDeleteSection extends StatelessWidget {
  final bool isGuest;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final AppLocalizations l10n;

  const _LogoutDeleteSection({
    required this.isGuest,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout, size: 20),
          label: Text(l10n.logOut),
          style: FilledButton.styleFrom(backgroundColor: appPrimaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
        ),
        if (!isGuest) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onDeleteAccount,
            child: Text(l10n.deleteAccount, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}
