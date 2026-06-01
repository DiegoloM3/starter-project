import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/routes/app_routes.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tortutip/features/articles/presentation/widgets/feed_card_detail.dart';
import 'package:tortutip/shared/widgets/tortutip_chip.dart';
import 'package:tortutip/shared/widgets/tortutip_skeleton.dart';

class FeedCard extends StatefulWidget {
  final ArticleEntity article;
  final String categoryName;
  final bool isSaved;
  final VoidCallback onSwipe;
  final void Function(String articleId) onBookmark;

  const FeedCard({
    super.key,
    required this.article,
    required this.categoryName,
    required this.isSaved,
    required this.onSwipe,
    required this.onBookmark,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> with TickerProviderStateMixin {
  static const double _dragAngleDivisor = 1000;
  static const double _swipeThreshold = 100;
  static const double _swipeVelocityThreshold = 800;
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _imageScale;
  late Animation<double> _overlayOpacity;
  late AnimationController _swipeController;
  double _dragOffset = 0.0;
  double _dragAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    final curve = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _imageScale = Tween<double>(begin: 1.0, end: 1.08).animate(curve);
    _overlayOpacity = Tween<double>(begin: 0.0, end: 0.45).animate(curve);
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragAngle = _dragOffset / _dragAngleDivisor;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final isSwipeRight = _dragOffset > 0;
    final isSwipeCompleted = _dragOffset.abs() > _swipeThreshold || velocity.abs() > _swipeVelocityThreshold;

    if (isSwipeCompleted) {
      if (isSwipeRight) {
        setState(() {
          _dragOffset = 0.0;
          _dragAngle = 0.0;
        });
        context.push(AppRoutes.articleDetailPath(widget.article.id));
      } else {
        widget.onSwipe();
        setState(() {
          _dragOffset = 0.0;
          _dragAngle = 0.0;
        });
      }
    } else {
      _animateSpringBack();
    }
  }

  void _animateSpringBack() {
    final startOffset = _dragOffset;
    final startAngle = _dragAngle;
    _swipeController.reset();
    _swipeController.addListener(() {
      setState(() {
        _dragOffset = startOffset * (1 - _swipeController.value);
        _dragAngle = startAngle * (1 - _swipeController.value);
      });
    });
    _swipeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_dragOffset.abs() / _swipeThreshold))
        .clamp(0.3, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform(
      transform: Matrix4.identity()
        ..rotateZ(_dragAngle)
        ..translateByDouble(_dragOffset, 0.0, 0.0, 1.0),
      alignment: Alignment.center,
      child: GestureDetector(
        onHorizontalDragUpdate: _onPanUpdate,
        onHorizontalDragEnd: _onPanEnd,
        onTap: _toggleExpand,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(),
              if (_isExpanded) _buildExpandedOverlay(),
              _buildSwipeColorOverlay(),
              _buildCategoryChip(),
              _buildBookmarkButton(),
              if (!_isExpanded) _buildTitleOverlay(),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildBackground() {
    final imageWidget = widget.article.coverVerticalUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: widget.article.coverVerticalUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => const TortuSkeletonImage(),
            errorWidget: (_, _, _) => _buildPlaceholderImage(),
          )
        : _buildPlaceholderImage();

    return AnimatedBuilder(
      animation: _expandController,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: _imageScale.value,
              child: child,
            ),
            // Overlay oscuro que aparece al expandir
            Opacity(
              opacity: _overlayOpacity.value,
              child: const ColoredBox(color: AppColors.dark),
            ),
          ],
        );
      },
      child: imageWidget,
    );
  }

  Widget _buildSwipeColorOverlay() {
    if (_dragOffset == 0) return const SizedBox.shrink();
    final progress = (_dragOffset.abs() / _swipeThreshold).clamp(0.0, 1.0);
    final color = _dragOffset > 0
        ? Colors.green.withValues(alpha: progress * 0.35)
        : Colors.red.withValues(alpha: progress * 0.35);
    return ColoredBox(color: color);
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: AppSpacing.iconLg,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildExpandedOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: FeedCardDetail(article: widget.article),
    );
  }

  Widget _buildCategoryChip() {
    if (widget.categoryName.isEmpty) return const SizedBox.shrink();
    return Positioned(
      top: AppSpacing.lg,
      left: AppSpacing.lg,
      child: TortuCategoryChip.fromName(widget.categoryName),
    );
  }

  Widget _buildBookmarkButton() {
    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.lg,
      child: GestureDetector(
        onTap: () => widget.onBookmark(widget.article.id),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: AppSpacing.avatarSizeSm + AppSpacing.sm,
          height: AppSpacing.avatarSizeSm + AppSpacing.sm,
          decoration: BoxDecoration(
            color: AppColors.dark.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: widget.isSaved ? AppColors.white : AppColors.white,
            size: AppSpacing.iconMd,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.transparent,
              AppColors.dark.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Text(
          widget.article.title,
          style: AppTypography.h3.copyWith(color: AppColors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
