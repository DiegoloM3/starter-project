import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickedThumbnail {
  final Uint8List bytes;
  final String fileName;
  const PickedThumbnail(this.bytes, this.fileName);
}

class ThumbnailPicker extends StatefulWidget {
  final ValueChanged<PickedThumbnail?> onChanged;
  final String? initialImageUrl;
  const ThumbnailPicker({
    super.key,
    required this.onChanged,
    this.initialImageUrl,
  });

  @override
  State<ThumbnailPicker> createState() => _ThumbnailPickerState();
}

class _ThumbnailPickerState extends State<ThumbnailPicker> {
  final _picker = ImagePicker();
  PickedThumbnail? _current;
  bool _cleared = false;

  Future<void> _pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final picked = PickedThumbnail(bytes, file.name);
    setState(() {
      _current = picked;
      _cleared = false;
    });
    widget.onChanged(picked);
  }

  bool get _hasAnyImage =>
      _current != null ||
      (!_cleared && (widget.initialImageUrl ?? '').isNotEmpty);

  Widget _imageLayer() {
    if (_current != null) {
      return Image(
        image: MemoryImage(_current!.bytes),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (!_cleared && (widget.initialImageUrl ?? '').isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.initialImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pick,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _imageLayer()),
              if (!_hasAnyImage)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 40),
                      SizedBox(height: 8),
                      Text('Tap to pick a thumbnail'),
                    ],
                  ),
                ),
              if (_hasAnyImage)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _current = null;
                            _cleared = true;
                          });
                          widget.onChanged(null);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
