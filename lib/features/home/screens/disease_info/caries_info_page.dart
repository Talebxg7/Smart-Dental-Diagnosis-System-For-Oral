import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'widgets/disease_header.dart';
import 'widgets/section_card.dart';

class CariesInfoPage extends StatelessWidget {
  const CariesInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        title: const Text('Caries'),
        backgroundColor: appPrimaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DiseaseHeader(
              title: 'Caries (Tooth Decay)',
              imageAsset: 'assets/images/caries_logo.png',
            ),
            const SizedBox(height: 28),
            SectionCard(
              title: 'What is Caries',
              child: Text(
                'Caries is tooth decay caused by bacteria that produce acids which damage the tooth enamel.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Symptoms',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet('Tooth sensitivity'),
                  _bullet('Visible holes in teeth'),
                  _bullet('Tooth pain while eating or drinking'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Prevention',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet('Brush teeth twice daily'),
                  _bullet('Use dental floss regularly'),
                  _bullet('Reduce sugary foods and drinks'),
                  _bullet('Visit the dentist regularly'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: appPrimaryGreen, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
