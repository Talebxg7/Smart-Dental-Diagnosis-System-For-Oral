import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'widgets/disease_header.dart';
import 'widgets/section_card.dart';

class GingivitisInfoPage extends StatelessWidget {
  const GingivitisInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        title: const Text('Gingivitis'),
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
              title: 'Gingivitis',
              imageAsset: 'assets/images/gingivitis_logo.png',
            ),
            const SizedBox(height: 28),
            SectionCard(
              title: 'What is Gingivitis',
              child: Text(
                'Gingivitis is an early stage of gum disease that causes inflammation of the gums.',
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
                  _bullet('Red or swollen gums'),
                  _bullet('Bleeding when brushing'),
                  _bullet('Bad breath'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Prevention',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet('Brush teeth properly'),
                  _bullet('Use dental floss'),
                  _bullet('Maintain good oral hygiene'),
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
