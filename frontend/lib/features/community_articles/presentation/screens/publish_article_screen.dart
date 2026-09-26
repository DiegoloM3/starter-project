import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article_image.dart';
import '../bloc/community_feed_cubit.dart';
import '../bloc/publish_article_cubit.dart';

class PublishArticleScreen extends StatefulWidget {
  const PublishArticleScreen({super.key});

  @override
  State<PublishArticleScreen> createState() => _PublishArticleScreenState();
}

class _PublishArticleScreenState extends State<PublishArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _validationAttempted = false;

  bool get _titleHasValidationError {
    final length = _titleController.text.trim().length;
    return length < 5 || length > 120;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the existing async discard confirmation until PopScope can support
    // the same route behavior without changing the publish flow.
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 482),
            child: SizedBox(
              width: double.infinity,
              child: SafeArea(
                child: BlocConsumer<PublishArticleCubit, PublishArticleState>(
                  listener: _onStateChanged,
                  builder: (context, state) {
                    final isSubmitting = state is PublishArticleSubmitting;
                    final image = context.read<PublishArticleCubit>().image;
                    return LayoutBuilder(
                      builder: (context, frameConstraints) {
                        final width = frameConstraints.maxWidth;
                        final scale = (width / 482).clamp(0.65, 1.0).toDouble();
                        final headerHeight = _scaled(80, scale, minimum: 56);
                        final footerHeight = _scaled(108, scale, minimum: 72);
                        final imageActionsHeight = image == null
                            ? _scaled(8 + 48, scale, minimum: 52)
                            : _scaled(
                                width < 450 ? 8 + 48 * 2 + 8 : 8 + 48,
                                scale,
                                minimum: width < 450 ? 96 : 52,
                              );
                        final titleErrorSpace =
                            _validationAttempted && _titleHasValidationError
                                ? _scaled(28, scale)
                                : 0.0;
                        return Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: headerHeight,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    tooltip: 'Back',
                                    onPressed: () async {
                                      if (await _confirmDiscard() &&
                                          context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                    ),
                                    padding: EdgeInsets.only(
                                      left: _scaled(30, scale, minimum: 16),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: _scaled(54, scale, minimum: 44),
                                      minHeight:
                                          _scaled(54, scale, minimum: 44),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, viewportConstraints) {
                                    final titleHeight = _scaled(133, scale);
                                    final imageHeight =
                                        image == null ? 0.0 : width / 1.82;
                                    final imageLeading = image == null
                                        ? _scaled(34, scale) +
                                            _scaled(56, scale, minimum: 44) +
                                            _scaled(42, scale)
                                        : _scaled(30, scale) +
                                            imageHeight +
                                            imageActionsHeight +
                                            _scaled(26, scale);
                                    final bodyHeight =
                                        (viewportConstraints.maxHeight -
                                                titleHeight -
                                                imageLeading)
                                            .clamp(_scaled(240, scale),
                                                double.infinity)
                                            .toDouble();

                                    return SingleChildScrollView(
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight:
                                              viewportConstraints.maxHeight,
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: _scaled(30, scale),
                                              ),
                                              child: SizedBox(
                                                height: titleHeight +
                                                    titleErrorSpace,
                                                child: TextFormField(
                                                  controller: _titleController,
                                                  enabled: !isSubmitting,
                                                  expands: true,
                                                  minLines: null,
                                                  maxLines: null,
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  textAlignVertical:
                                                      TextAlignVertical.top,
                                                  onChanged: (_) {
                                                    if (_validationAttempted) {
                                                      setState(() {});
                                                    }
                                                  },
                                                  style: TextStyle(
                                                    fontSize:
                                                        _scaled(28, scale),
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.2,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Write your title here...',
                                                    hintStyle: TextStyle(
                                                      color: const Color(
                                                          0xFF8E8E8E),
                                                      fontSize:
                                                          _scaled(28, scale),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    alignLabelWithHint: true,
                                                  ),
                                                  validator: (value) {
                                                    final length =
                                                        value?.trim().length ??
                                                            0;
                                                    return length < 5 ||
                                                            length > 120
                                                        ? 'Use 5–120 characters.'
                                                        : null;
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (image == null) ...[
                                              SizedBox(
                                                  height: _scaled(34, scale)),
                                              _imageAction(
                                                context,
                                                image,
                                                isSubmitting,
                                                scale,
                                              ),
                                              SizedBox(
                                                  height: _scaled(42, scale)),
                                            ] else ...[
                                              SizedBox(
                                                  height: _scaled(30, scale)),
                                              _imageAction(
                                                context,
                                                image,
                                                isSubmitting,
                                                scale,
                                              ),
                                              SizedBox(
                                                  height: _scaled(26, scale)),
                                            ],
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: _scaled(30, scale),
                                              ),
                                              child: SizedBox(
                                                height: bodyHeight,
                                                child: TextFormField(
                                                  controller:
                                                      _contentController,
                                                  enabled: !isSubmitting,
                                                  expands: true,
                                                  maxLines: null,
                                                  minLines: null,
                                                  textAlignVertical:
                                                      TextAlignVertical.top,
                                                  style: TextStyle(
                                                    fontSize:
                                                        _scaled(18, scale),
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.35,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Add article here, .....',
                                                    hintStyle: TextStyle(
                                                      color: const Color(
                                                          0xFF8E8E8E),
                                                      fontSize:
                                                          _scaled(18, scale),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    alignLabelWithHint: true,
                                                  ),
                                                  validator: (value) {
                                                    final length =
                                                        value?.trim().length ??
                                                            0;
                                                    return length < 20 ||
                                                            length > 10000
                                                        ? 'Use 20–10,000 characters.'
                                                        : null;
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              _publishFooter(isSubmitting, scale, footerHeight),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _scaled(double value, double scale, {double minimum = 0}) =>
      (value * scale).clamp(minimum, double.infinity).toDouble();

  Widget _imageAction(
    BuildContext context,
    ArticleImageEntity? image,
    bool isSubmitting,
    double scale,
  ) {
    if (image == null) {
      return Center(
        child: SizedBox(
          width: _scaled(210, scale),
          height: _scaled(56, scale, minimum: 44),
          child: ElevatedButton.icon(
            onPressed: isSubmitting
                ? null
                : () => context.read<PublishArticleCubit>().selectImage(),
            icon: Icon(Icons.add_a_photo_outlined, size: _scaled(25, scale)),
            label: Text(
              'Attach Image',
              style: TextStyle(
                fontSize: _scaled(20, scale),
                fontWeight: FontWeight.w400,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE1BEDE),
              foregroundColor: Colors.black,
              elevation: 3,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_scaled(8, scale)),
              ),
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      );
    }

    final bytes = Uint8List.fromList(image.bytes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          image: true,
          label: 'Selected article image. Confirmed crop ratio is 1.82 to 1.',
          child: SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 1.82,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Color(0xFFF7F3FA)),
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        SizedBox(height: _scaled(8, scale)),
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: _scaled(4, scale),
          runSpacing: _scaled(4, scale),
          children: [
            OutlinedButton.icon(
              key: const ValueKey('replace-image'),
              onPressed: isSubmitting
                  ? null
                  : () => context.read<PublishArticleCubit>().selectImage(),
              icon: Icon(Icons.swap_horiz, size: _scaled(20, scale)),
              label: const Text('Replace image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                minimumSize: Size(0, _scaled(48, scale, minimum: 44)),
                padding: EdgeInsets.symmetric(horizontal: _scaled(12, scale)),
                side: const BorderSide(color: Colors.black54),
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey('adjust-image-crop'),
              onPressed: isSubmitting
                  ? null
                  : context.read<PublishArticleCubit>().adjustImage,
              icon: Icon(Icons.crop, size: _scaled(20, scale)),
              label: const Text('Adjust crop'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                minimumSize: Size(0, _scaled(48, scale, minimum: 44)),
                padding: EdgeInsets.symmetric(horizontal: _scaled(12, scale)),
                side: const BorderSide(color: Colors.black54),
              ),
            ),
            TextButton.icon(
              key: const ValueKey('remove-image'),
              onPressed: isSubmitting
                  ? null
                  : context.read<PublishArticleCubit>().removeImage,
              icon: Icon(Icons.delete_outline, size: _scaled(20, scale)),
              label: const Text('Remove image'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                minimumSize: Size(0, _scaled(48, scale, minimum: 44)),
                padding: EdgeInsets.symmetric(horizontal: _scaled(12, scale)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _publishFooter(bool isSubmitting, double scale, double height) {
    final iconSize = _scaled(38, scale, minimum: 24);
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Material(
          color: const Color(0xFFE1BEDE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_scaled(8, scale)),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSubmitting ? null : _submit,
            child: Semantics(
              button: true,
              label: isSubmitting ? 'Publishing article' : 'Publish article',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final reservedWidth =
                      _scaled(38 + 18 + 32, scale, minimum: 84);
                  final maxTextWidth = (constraints.maxWidth - reservedWidth)
                      .clamp(0.0, double.infinity)
                      .toDouble();
                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isSubmitting
                            ? SizedBox.square(
                                dimension: _scaled(26, scale, minimum: 22),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              )
                            : Icon(Icons.login_rounded, size: iconSize),
                        SizedBox(width: _scaled(18, scale)),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxTextWidth),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isSubmitting
                                  ? 'Publishing...'
                                  : 'Publish Article',
                              style: TextStyle(
                                fontSize: _scaled(38, scale),
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    setState(() => _validationAttempted = true);
    if (!_formKey.currentState!.validate()) return;
    context.read<PublishArticleCubit>().submit(
          title: _titleController.text,
          content: _contentController.text,
        );
  }

  void _onStateChanged(BuildContext context, PublishArticleState state) {
    if (state is PublishArticleCropRequired) {
      unawaited(_openCropEditor(state.sourceImage, state.sessionId));
    } else if (state is PublishArticleFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is PublishArticleSuccess) {
      context.read<CommunityFeedCubit>().load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article published successfully.')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _openCropEditor(
    ArticleImageEntity sourceImage,
    int sessionId,
  ) async {
    final croppedImage = await showDialog<ArticleImageEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ArticleImageCropDialog(sourceImage: sourceImage),
    );
    if (!mounted) return;
    final cubit = context.read<PublishArticleCubit>();
    if (croppedImage == null) {
      cubit.cancelImageCrop(sessionId: sessionId);
    } else {
      cubit.confirmImageCrop(croppedImage, sessionId: sessionId);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (context.read<PublishArticleCubit>().isSubmitting) return false;
    final dirty = _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty ||
        context.read<PublishArticleCubit>().image != null;
    if (!dirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard article?'),
        content: const Text('Your unsaved edits will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }
}

/// Fixed-ratio crop editor used before an image becomes part of the publish
/// payload. The package performs the crop in bytes, so Firestore Storage
/// receives the exact region confirmed by the user rather than the original
/// uncropped file.
class ArticleImageCropDialog extends StatefulWidget {
  final ArticleImageEntity sourceImage;

  const ArticleImageCropDialog({super.key, required this.sourceImage});

  @override
  State<ArticleImageCropDialog> createState() => _ArticleImageCropDialogState();
}

class _ArticleImageCropDialogState extends State<ArticleImageCropDialog> {
  static const _aspectRatio = 1.82;

  final _controller = CropController();
  bool _isReady = false;
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxDialogHeight = (media.size.height - media.viewInsets.vertical - 32)
        .clamp(160.0, double.infinity)
        .toDouble();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: maxDialogHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cropHeight =
                  (constraints.maxHeight - 188).clamp(120.0, 420.0).toDouble();
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Adjust image crop',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Drag to position. Pinch or scroll to zoom. The published image is fixed to 1.82:1.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      key: const ValueKey('image-crop-viewport'),
                      height: cropHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Crop(
                          image: Uint8List.fromList(widget.sourceImage.bytes),
                          controller: _controller,
                          aspectRatio: _aspectRatio,
                          initialRectBuilder: InitialRectBuilder.withBuilder(
                            (viewportRect, imageRect) {
                              // Keep the crop frame wide and readable even
                              // when the source is an extreme portrait. The
                              // package then scales the image to cover this
                              // frame because interactive mode is enabled.
                              final width = math.min(
                                viewportRect.width,
                                viewportRect.height * _aspectRatio,
                              );
                              final height = width / _aspectRatio;
                              return Rect.fromCenter(
                                center: viewportRect.center,
                                width: width,
                                height: height,
                              );
                            },
                          ),
                          interactive: true,
                          fixCropRect: true,
                          baseColor: const Color(0xFF28242C),
                          maskColor: Colors.black.withAlpha(112),
                          radius: 10,
                          cornerDotBuilder: (_, __) => const SizedBox.shrink(),
                          onStatusChanged: (status) {
                            if (!mounted) return;
                            setState(() {
                              _isReady = status == CropStatus.ready;
                              if (status == CropStatus.cropping) {
                                _isCropping = true;
                              }
                            });
                          },
                          overlayBuilder: (context, rect) => CustomPaint(
                            key: const ValueKey('image-crop-frame'),
                            painter: _CropGridPainter(),
                            size: rect.size,
                          ),
                          onCropped: _onCropped,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isCropping
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            key: const ValueKey('confirm-image-crop'),
                            onPressed: !_isReady || _isCropping ? null : _crop,
                            icon: _isCropping
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.check),
                            label: const Text('Use this crop'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _crop() {
    setState(() => _isCropping = true);
    _controller.crop();
  }

  void _onCropped(CropResult result) {
    if (!mounted) return;
    switch (result) {
      case CropSuccess(:final croppedImage):
        final mimeType = _mimeForBytes(croppedImage);
        if (mimeType == null) {
          setState(() => _isCropping = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to prepare that crop.')),
          );
          return;
        }
        Navigator.pop(context, _croppedEntity(croppedImage, mimeType));
      case CropFailure(:final cause):
        setState(() => _isCropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to crop that image: $cause')),
        );
    }
  }

  ArticleImageEntity _croppedEntity(Uint8List bytes, String mimeType) {
    final extension = switch (mimeType) {
      'image/jpeg' => 'jpg',
      'image/webp' => 'webp',
      _ => 'png',
    };
    final originalName = widget.sourceImage.fileName.split('/').last;
    final dot = originalName.lastIndexOf('.');
    final stem = dot > 0 ? originalName.substring(0, dot) : originalName;
    return ArticleImageEntity(
      bytes: bytes,
      fileName: '$stem-cropped.$extension',
      mimeType: mimeType,
    );
  }

  String? _mimeForBytes(List<int> bytes) {
    final image = ArticleImageEntity(
      bytes: bytes,
      fileName: 'cropped',
      mimeType: 'image/png',
    );
    return image.detectedMimeType;
  }
}

class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..strokeWidth = 1;
    final borderPaint = Paint()
      ..color = Colors.white.withAlpha(215)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdWidth * i, 0),
        Offset(thirdWidth * i, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, thirdHeight * i),
        Offset(size.width, thirdHeight * i),
        gridPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(10),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
