import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'widgets/disease_header.dart';
import 'widgets/section_card.dart';

class TartarInfoPage extends StatelessWidget {
  const TartarInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLightMint,
      appBar: AppBar(
        title: const Text('Tartar'),
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
              title: 'Tartar',
              imageAsset: 'assets/images/tartar_logo.png',
            ),
            const SizedBox(height: 28),
            SectionCard(
              title: 'What is Tartar',
              child: Text(
                'Tartar is hardened dental plaque that forms on teeth when plaque is not removed properly.',
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
                  _bullet('Yellow or brown buildup on teeth'),
                  _bullet('Bad breath'),
                  _bullet('Gum irritation'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Prevention',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet('Brush and floss daily'),
                  _bullet('Use mouthwash'),
                  _bullet('Regular professional dental cleaning'),
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
