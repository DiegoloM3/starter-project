import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/core/constants/app_colors.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';

import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reward/reward_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/reward/reward_state.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startTime = useRef(DateTime.now());
    
    useEffect(() {
      // Basic validation: user must stay 10 seconds to get the reward
      final timer = Timer(const Duration(seconds: 10), () {
        final duration = DateTime.now().difference(startTime.value).inSeconds.toDouble();
        _claimReward(context, duration);
      });
      return () => timer.cancel();
    }, []);

    return BlocListener<RewardCubit, RewardState>(
      listener: (context, state) {
        if (state is RewardClaimSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              content: Row(
                children: [
                  const Icon(Ionicons.flash, color: Colors.black, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '¡+${state.amount.toInt()} SYM tokens acumulados!',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: BlocProvider(
        create: (_) => sl<LocalArticleBloc>(),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  void _claimReward(BuildContext context, double duration) {
    context.read<RewardCubit>().claimReward(kAlphaTesterId, article?.url ?? '', duration);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Ionicons.chevron_back, color: AppColors.primary),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Ionicons.share_social_outline),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRewardStatus(),
          _buildArticleTitleAndDate(),
          _buildArticleImage(),
          _buildArticleContent(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article?.title ?? 'Sin Título',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeadline,
                height: 1.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Ionicons.person_circle_outline, size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                article?.author ?? 'Periodista Symmetry',
                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(Ionicons.time_outline, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                article?.publishedAt?.split('T')[0] ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return Container(
      width: double.maxFinite,
      height: 250,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: -10,
          )
        ]
      ),
      child: Image.network(
        article?.urlToImage ?? '', 
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.surface,
          child: const Center(child: Icon(Ionicons.image_outline, color: AppColors.textMuted, size: 40)),
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    final String description = article?.description ?? '';
    final String content = article?.content ?? '';
    
    // Construct content robustly
    final StringBuffer buffer = StringBuffer();
    if (description.isNotEmpty) {
      buffer.writeln('## Resumen');
      buffer.writeln(description);
      buffer.writeln('\n--- \n');
    }
    buffer.writeln(content);
    buffer.writeln('\n\n> *Nota del Editor: Este contenido ha sido verificado mediante el protocolo de consenso Symmetry.*');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: MarkdownBody(
        data: buffer.toString(),
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 17, color: AppColors.textBody, height: 1.6),
          h1: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold),
          h3: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w600),
          strong: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
          listBullet: const TextStyle(color: AppColors.primary, fontSize: 18),
          blockquoteDecoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
            borderRadius: BorderRadius.circular(4)
          ),
          blockquotePadding: const EdgeInsets.all(16),
          blockquote: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1))
          ),
          code: const TextStyle(
            backgroundColor: Colors.black26,
            color: AppColors.success,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton.extended(
        onPressed: () => _onFloatingActionButtonPressed(context),
        icon: const Icon(Ionicons.bookmark, color: Colors.black),
        label: const Text('Guardar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRewardStatus() {
    return BlocBuilder<RewardCubit, RewardState>(
      builder: (context, state) {
        if (state is RewardClaimSuccess) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
            color: AppColors.success.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Ionicons.checkmark_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                const Text('Recompensa obtenida por esta lectura', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }
        
        if (state is RewardClaiming) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 2,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.surface,
        content: Text('Artículo guardado en la red local.', style: TextStyle(color: AppColors.primary)),
      ),
    );
  }
}
