import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../extensions/build_context_extensions.dart';
import '../previews/app_preview.dart';

/// Red "BREAKING" banner with rotating headline text.
class BreakingBanner extends HookWidget {
  const BreakingBanner({required this.headlines, super.key})
    : assert(
        headlines.length >= 1 && headlines.length <= 3,
        'BreakingBanner requires between 1 and 3 headlines.',
      );

  final List<String> headlines;

  static const _headlineDuration = Duration(seconds: 4);
  static const _headlineTransitionDuration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);

    useEffect(() {
      currentIndex.value = 0;
      return null;
    }, [headlines]);

    useEffect(() {
      if (headlines.length < 2) {
        return null;
      }

      final rotationTimer = Timer.periodic(_headlineDuration, (_) {
        currentIndex.value = (currentIndex.value + 1) % headlines.length;
      });

      return rotationTimer.cancel;
    }, [headlines.length]);

    final safeIndex = currentIndex.value % headlines.length;
    final headline = headlines[safeIndex];

    return Container(
      color: context.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        spacing: 10,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.onPrimary,
                width: 1,
              ),
            ),
            child: Text(
              'BREAKING',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: _headlineTransitionDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: Text(
                headline,
                key: ValueKey(headline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview of breaking news banner.
@AppPreview(name: 'Breaking Banner')
Widget previewBreakingBanner() {
  return Material(
    child: BreakingBanner(
      headlines: [
        'Major News Story: New Developments Emerge in Breaking News',
        'Markets react as lawmakers approve the new infrastructure package',
        'Weather alert expands as coastal storms continue to intensify',
      ],
    ),
  );
}
