import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ArticleSkeleton extends StatelessWidget {
  const ArticleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(width: 88, height: 88, color: baseColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 14, width: double.infinity, color: baseColor),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 180, color: baseColor),
                    const SizedBox(height: 12),
                    Container(height: 10, width: 120, color: baseColor),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 80, color: baseColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticleSkeletonList extends StatelessWidget {
  final int count;
  const ArticleSkeletonList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => const ArticleSkeleton(),
    );
  }
}
