import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCommentTile extends StatelessWidget {
  const SkeletonCommentTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author name + timestamp row
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 10,
                        width: 50,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Content line
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
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
