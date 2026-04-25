import 'package:flutter/material.dart';

import '../../../../../../config/theme/ui_parameters.dart';

class ImagePickerSection extends StatelessWidget {
  final bool isGenerating;
  final ImageProvider? preview;
  final VoidCallback onTap;

  const ImagePickerSection({
    Key? key,
    required this.isGenerating,
    this.preview,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGenerating ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: UIParameters.imagePickerHeight,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: UIParameters.borderCard,
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              image: preview != null
                  ? DecorationImage(
                      image: preview!,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                preview == null ? _buildPlaceholder() : const SizedBox.shrink(),
          ),
          if (isGenerating) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: UIParameters.iconSizeXL,
          color: Colors.grey[400],
        ),
        UIParameters.sBoxVS,
        const Text("Tap to select or generate image"),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      height: UIParameters.imagePickerHeight,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: UIParameters.borderCard,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
