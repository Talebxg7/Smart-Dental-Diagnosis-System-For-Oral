import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeHeader extends StatelessWidget {
  /// Display name (e.g. first name or "FirstName LastName"). If null/empty, shows localized Guest.
  final String? userName;

  const WelcomeHeader({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = (userName ?? '').trim().isEmpty ? l10n.guest : userName!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, color: appPrimaryGreen, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.hello} ( $displayName )',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appPrimaryGreenDark,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: appPrimaryGreen,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.scanTagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
      ],
    );
  }
}
