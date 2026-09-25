import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'brand_mark.dart';

/// A network photo, or the app's own mark on white when it has none, it's
/// still loading, or it fails -- shared by every feature that shows one
/// (NewsAPI stories, a reader's own published articles): many NewsAPI
/// stories come without an image, and any photo can fail to load.
class AppImage extends StatelessWidget {
  final String? url;

  /// True for the copy of the News feed kept on the phone, shown because
  /// there's no connection. Most of its photos were never displayed before
  /// (a feed's lower rows aren't built until scrolled into view), so
  /// they're not already cached on disk -- without this flag, every one of
  /// them would attempt and fail a network fetch as the reader scrolls,
  /// often several at once, which is what caused the stutter this was
  /// added to fix. Skips the attempt outright instead, straight to the
  /// placeholder.
  final bool isOffline;

  const AppImage({super.key, required this.url, this.isOffline = false});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url ?? '';
    if (imageUrl.isEmpty || isOffline) return const _Placeholder();
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => const _Loading(),
      errorWidget: (_, __, ___) => const _Placeholder(),
    );
  }
}

/// No photo to show at all (none, offline, or it failed): the mark, fully
/// drawn and still, labelled underneath so it reads as "there's genuinely
/// no photo here" rather than a stuck loading state.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(),
            const SizedBox(height: 4),
            Text(
              context.l10n.noPhoto,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

/// A photo is on its way over the network: the same mark, drawing itself
/// on a loop, so waiting reads as the app doing something.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.white,
      child: Center(child: AnimatedBrandMark()),
    );
  }
}
