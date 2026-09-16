import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_motion.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_scroll_physics.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/brief/brief_story_card.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';

/// Step 2 of 3: the vertical card stack on ink. Swipe up for the next
/// story; the last card's swipe ends the brief.
class BriefCardStackStep extends StatefulWidget {
  final List<ArticleEntity> articles;
  final int index;
  final Set<String> savedIds;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ArticleEntity> onRead;
  final ValueChanged<ArticleEntity> onSave;
  final ValueChanged<ArticleEntity> onListen;
  final String? listeningId;
  final VoidCallback onFinish;
  final VoidCallback onClose;

  const BriefCardStackStep({
    super.key,
    required this.articles,
    required this.index,
    required this.savedIds,
    required this.onPageChanged,
    required this.onRead,
    required this.onSave,
    required this.onListen,
    required this.listeningId,
    required this.onFinish,
    required this.onClose,
  });

  @override
  State<BriefCardStackStep> createState() => _BriefCardStackStepState();
}

class _BriefCardStackStepState extends State<BriefCardStackStep> {
  late final PageController _controller = PageController(
    viewportFraction: 0.86,
    initialPage: widget.index,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (widget.index >= widget.articles.length - 1) {
      widget.onFinish();
      return;
    }
    await _controller.nextPage(
      duration: AppMotion.durationFor(context, AppMotion.long),
      curve: AppMotion.standard,
    );
  }

  static const Color _ink = Color(0xFF151413);
  static const Color _paper = Color(0xFFF3F2F2);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: _ink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.screenMargin, 0),
              child: Row(
                children: [
                  LabeledIconButton.close(
                    onPressed: widget.onClose,
                    color: _paper,
                    backgroundColor: _paper.withValues(alpha: 0.08),
                  ),
                  const Spacer(),
                  for (var i = 0; i < widget.articles.length; i++)
                    AnimatedContainer(
                      duration: AppMotion.durationFor(context, AppMotion.short),
                      margin: const EdgeInsets.only(left: AppSpacing.xs),
                      width: i <= widget.index ? 22 : 7,
                      height: 5,
                      color: i <= widget.index ? palette.primary : _paper.withValues(alpha: 0.3),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const BriefScrollPhysics(),
                scrollDirection: Axis.vertical,
                onPageChanged: widget.onPageChanged,
                itemCount: widget.articles.length,
                itemBuilder: (context, i) {
                  final article = widget.articles[i];
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final page = _controller.hasClients && _controller.position.haveDimensions
                          ? _controller.page ?? widget.index.toDouble()
                          : widget.index.toDouble();
                      final delta = (page - i).clamp(-1.0, 1.0);
                      final distance = delta.abs();
                      return Transform.scale(
                        scale: 1 - 0.06 * distance,
                        child: Opacity(opacity: 1 - 0.4 * distance, child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: AppSpacing.sm),
                      child: BriefStoryCard(
                        article: article,
                        isSaved: widget.savedIds.contains(article.id),
                        parallax: _controller,
                        page: i,
                        onRead: () => widget.onRead(article),
                        onSave: () => widget.onSave(article),
                        isListening: widget.listeningId == article.id,
                        onListen: () => widget.onListen(article),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: TextButton.icon(
                onPressed: _next,
                style: TextButton.styleFrom(foregroundColor: _paper.withValues(alpha: 0.8)),
                icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                label: Text(
                  widget.index >= widget.articles.length - 1 ? 'Finish the brief' : 'Swipe up for the next story',
                  style: AppTypography.buttonSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
