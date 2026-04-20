import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class _DiseaseItem {
  final String id;
  final String imageAsset;

  const _DiseaseItem({
    required this.id,
    required this.imageAsset,
  });
}

class DiseaseCards extends StatelessWidget {
  /// Called when a disease card is tapped. Passes route id: caries, tartar, gingivitis.
  final void Function(String diseaseId)? onTapDisease;

  const DiseaseCards({super.key, this.onTapDisease});

  static const _items = [
    _DiseaseItem(id: 'caries', imageAsset: 'assets/images/caries_logo.png'),
    _DiseaseItem(id: 'tartar', imageAsset: 'assets/images/tartar_logo.png'),
    _DiseaseItem(id: 'gingivitis', imageAsset: 'assets/images/gingivitis_logo.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detectableConditions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appPrimaryGreenDark,
              ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < _items.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _DiseaseCard(
                            item: _items[i],
                            title: _titleFor(_items[i].id, l10n),
                            description: _descriptionFor(_items[i].id, l10n),
                            onTap: onTapDisease != null
                                ? () => onTapDisease!(_items[i].id)
                                : null,
                          ),
                        ),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      for (final e in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DiseaseCard(
                            item: e,
                            title: _titleFor(e.id, l10n),
                            description: _descriptionFor(e.id, l10n),
                            onTap: onTapDisease != null
                                ? () => onTapDisease!(e.id)
                                : null,
                          ),
                        ),
                    ],
                  );
          },
        ),
      ],
    );
  }

  static String _titleFor(String id, AppLocalizations l10n) {
    switch (id) {
      case 'caries': return l10n.caries;
      case 'tartar': return l10n.tartar;
      case 'gingivitis': return l10n.gingivitis;
      default: return id;
    }
  }

  static String _descriptionFor(String id, AppLocalizations l10n) {
    switch (id) {
      case 'caries': return l10n.cariesDescription;
      case 'tartar': return l10n.tartarDescription;
      case 'gingivitis': return l10n.gingivitisDescription;
      default: return '';
    }
  }
}

class _DiseaseCard extends StatelessWidget {
  final _DiseaseItem item;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _DiseaseCard({
    required this.item,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: appPrimaryGreen.withValues(alpha: 0.2),
        highlightColor: appLightMint,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                item.imageAsset,
                height: 48,
                width: 48,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.medical_services, color: appPrimaryGreen, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appPrimaryGreenDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
