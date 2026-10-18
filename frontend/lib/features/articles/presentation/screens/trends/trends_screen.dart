import 'package:flutter/material.dart';

import '../../widgets/status_message.dart';

/// Trends tab. Its content arrives with the social features.
class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tendencias')),
      body: const StatusMessage(
        icon: Icons.trending_up,
        message: 'Muy pronto verás aquí los temas y artículos más leídos.',
      ),
    );
  }
}
