import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class ScanButton extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const ScanButton({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  void _showSourceSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.uploadDentalImage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appPrimaryGreenDark,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: appLightMint,
                  child: const Icon(Icons.camera_alt, color: appPrimaryGreen),
                ),
                title: Text(l10n.camera),
                subtitle: Text(l10n.takeNewPhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  onCamera();
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: appLightMint,
                  child: const Icon(Icons.photo_library, color: appPrimaryGreen),
                ),
                title: Text(l10n.gallery),
                subtitle: Text(l10n.chooseGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  onGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: appPrimaryGreen,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: appPrimaryGreen.withValues(alpha: 0.4),
      child: InkWell(
        onTap: () => _showSourceSheet(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scanTeeth,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.uploadDentalImage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
