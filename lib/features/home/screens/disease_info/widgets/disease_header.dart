import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Reusable header for disease info pages: title and logo image or icon.
class DiseaseHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  /// When set, shows this asset image instead of [icon].
  final String? imageAsset;

  const DiseaseHeader({
    super.key,
    required this.title,
    this.icon = Icons.medical_services,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: imageAsset != null
              ? Image.asset(
                  imageAsset!,
                  height: 72,
                  width: 72,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(icon, size: 56, color: appPrimaryGreen),
                )
              : Icon(icon, size: 56, color: appPrimaryGreen),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: appPrimaryGreenDark,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
