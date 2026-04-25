import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/core/constants/dimensions.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/shared/widgets/app_cached_image.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authState.user;
          final userArticles = _getUserArticles(context, user.uid);
          final savedCount = _getSavedCount(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(
                  name: user.displayName ?? 'Unknown',
                  email: user.email ?? '',
                ),
                const SizedBox(height: 24),
                _buildStatsCard(
                  savedCount: savedCount,
                  publicationsCount: userArticles.length,
                ),
                const SizedBox(height: 28),
                _buildPublicationsSection(context, userArticles),
                const SizedBox(height: 28),
                _buildMenuItem(
                  icon: Ionicons.bookmark_outline,
                  label: 'My Bookmarks',
                  badge: savedCount > 0 ? '$savedCount' : null,
                  onTap: () => Navigator.pushNamed(context, '/SavedArticles'),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Ionicons.log_out_outline,
                  label: 'Logout',
                  onTap: () => _onSignOutTapped(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ArticleEntity> _getUserArticles(BuildContext context, String uid) {
    final state = context.watch<FirebaseArticlesCubit>().state;
    if (state is FirebaseArticlesDone) {
      return state.articles
          .where((article) => article.authorId == uid)
          .toList();
    }
    return [];
  }

  int _getSavedCount(BuildContext context) {
    final state = context.watch<LocalArticleBloc>().state;
    if (state is LocalArticlesDone) {
      return state.articles?.length ?? 0;
    }
    return 0;
  }

  void _onSignOutTapped(BuildContext context) {
    Navigator.pop(context);
    context.read<AuthCubit>().signOut();
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Ionicons.arrow_back,
          color: AppColors.textPrimary,
        ),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String email,
  }) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.captionText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required int savedCount,
    required int publicationsCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                count: '$savedCount',
                label: 'Saved Articles',
              ),
            ),
            VerticalDivider(
              color: AppColors.divider,
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: _buildStatItem(
                count: '$publicationsCount',
                label: 'My Publications',
              ),
            ),
            VerticalDivider(
              color: AppColors.divider,
              thickness: 1,
              width: 1,
            ),
            const Expanded(
              child: _StatItem(count: '250', label: 'Reading History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String count, required String label}) {
    return _StatItem(count: count, label: label);
  }

  Widget _buildPublicationsSection(
    BuildContext context,
    List<ArticleEntity> publications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Publications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        if (publications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Ionicons.document_text_outline,
                  size: 32,
                  color: AppColors.captionText,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No publications yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.captionText,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: publications.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final article = publications[index];
                return _buildPublicationCard(
                  article: article,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/ArticleDetails',
                    arguments: article,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPublicationCard({
    required ArticleEntity article,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCachedImage(
              imageUrl: article.urlToImage ?? '',
              width: 130,
              height: 100,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 8),
            Text(
              article.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormatter.format(article.publishedAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.captionText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.captionText,
          ),
        ),
      ],
    );
  }
}
