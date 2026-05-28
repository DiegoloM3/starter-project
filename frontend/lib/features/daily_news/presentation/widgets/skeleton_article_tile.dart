import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonArticleTile extends StatelessWidget {
  const SkeletonArticleTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
            start: 14, end: 14, bottom: 7, top: 7),
        height: screenWidth / 2.2,
        child: Row(
          children: [
            // Image placeholder
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: screenWidth / 3,
                  height: double.maxFinite,
                  color: Colors.white,
                ),
              ),
            ),
            // Text placeholders
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title line 1
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    // Title line 2
                    Container(
                      height: 16,
                      width: screenWidth * 0.45,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    // Description line 1
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 5),
                    // Description line 2
                    Container(
                      height: 12,
                      width: screenWidth * 0.35,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    // Date placeholder
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
