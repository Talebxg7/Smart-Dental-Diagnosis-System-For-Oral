import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class DentalTipCard extends StatefulWidget {
  const DentalTipCard({super.key});

  @override
  State<DentalTipCard> createState() => _DentalTipCardState();
}

class _DentalTipCardState extends State<DentalTipCard> {
  late int _tipIndex;

  @override
  void initState() {
    super.initState();
    _tipIndex = Random().nextInt(15) + 1; // 1..15
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tipText = l10n.getDailyTip(_tipIndex);
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: appLightMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lightbulb_outline, color: appPrimaryGreen, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyDentalTip,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appPrimaryGreenDark,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tipText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
