import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_buttons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/daily_news_label.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// First screen when nobody is signed in: invites the journalist to create an account or to log in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Flexible(child: _WelcomeIllustration()),
              const SizedBox(height: 28),
              const Expanded(child: _WelcomeMessage()),
              AppPrimaryButton(
                label: 'Create account',
                onPressed: () => Navigator.pushNamed(context, RouteNames.register),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, RouteNames.signIn),
                child: const Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DailyNewsLabel(),
        const SizedBox(height: 12),
        const Text(
          'Read the news.\nPublish your own.',
          style: TextStyle(fontSize: 30, height: 1.2, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          'The day’s headlines and the articles written by journalists like you, in one place.',
          style: TextStyle(fontSize: 15, height: 1.5, color: palette.textSecondary),
        ),
      ],
    );
  }
}

/// Two article cards leaning on each other, the front one with the app's newspaper icon.
class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: context.palette.primarySoft,
          borderRadius: BorderRadius.circular(28),
        ),
        // Only shrinks the cards on small screens; they keep the size of the design otherwise.
        child: const Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 262,
              height: 210,
              child: Stack(
                children: [
                  Positioned(left: 0, top: 0, child: _ArticleCard(angleInDegrees: -6, isHighlighted: false)),
                  Positioned(left: 58, top: 36, child: _ArticleCard(angleInDegrees: 5, isHighlighted: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final double angleInDegrees;
  final bool isHighlighted;

  const _ArticleCard({required this.angleInDegrees, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Transform.rotate(
      angle: angleInDegrees * math.pi / 180,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: isHighlighted ? 0.18 : 0.12),
              blurRadius: isHighlighted ? 30 : 24,
              offset: Offset(0, isHighlighted ? 14 : 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(palette),
            const SizedBox(height: 10),
            _buildTextLine(palette, isHighlighted ? 160 : 150),
            const SizedBox(height: 10),
            _buildTextLine(palette, isHighlighted ? 120 : 110),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(AppPalette palette) {
    return Container(
      width: double.infinity,
      height: 84,
      decoration: BoxDecoration(
        color: isHighlighted ? palette.primary : palette.primary.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isHighlighted ? Icon(Ionicons.newspaperOutline, size: 36, color: palette.onPrimary) : null,
    );
  }

  Widget _buildTextLine(AppPalette palette, double width) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
