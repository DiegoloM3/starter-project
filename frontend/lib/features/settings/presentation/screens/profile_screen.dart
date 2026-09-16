import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_section.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// The signed-in account: square avatar, the name set large, the email, the
/// two counters as a ruled grid, the ink "Edit profile" block and the rows
/// that lead to writing and to Settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final myArticles = context.read<MyArticlesCubit>();
    if (myArticles.state.status == MyArticlesStatus.initial) myArticles.load();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final user = context.select((SessionCubit cubit) => cubit.state.user);
    final savedCount = context.select((SavedArticlesCubit cubit) => cubit.state.articles.length);
    final publishedCount = context.select((MyArticlesCubit cubit) => cubit.state.articles.length);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    if (user == null) return const SizedBox.shrink();

    final rule = BorderSide(color: palette.outlineStrong, width: AppRules.strong);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.xxl),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.lg),
              child: Row(
                children: [
                  UserAvatar(
                    name: user.preferredName,
                    photoUrl: user.photoUrl,
                    size: 68,
                    isCurrentUser: true,
                    ringed: true,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.preferredName.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.display.copyWith(color: palette.ink, fontSize: 30, height: 0.95),
                        ),
                        if (user.email case final email?) ...[
                          const SizedBox(height: 6),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(color: palette.inkSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border(top: rule, bottom: rule)),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Counter(value: publishedCount, label: 'Published', color: palette.ink, divided: true),
                    ),
                    Expanded(child: _Counter(value: savedCount, label: 'Saved', color: palette.primary)),
                  ],
                ),
              ),
            ),
            Material(
              color: palette.accent,
              child: InkWell(
                onTap: context.pushEditProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: AppSpacing.lg),
                  decoration: BoxDecoration(border: Border(bottom: rule)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Edit profile', style: AppTypography.button.copyWith(color: palette.onAccent, fontSize: 14)),
                      ),
                      Icon(Icons.edit_outlined, size: 18, color: palette.onAccent),
                    ],
                  ),
                ),
              ),
            ),
            SettingsSection(
              title: 'Your writing',
              children: [
                SettingsRow(
                  label: 'My articles',
                  value: '$publishedCount'.padLeft(2, '0'),
                  onTap: context.pushMyArticles,
                ),
                SettingsRow(
                  label: 'Write an article',
                  onTap: () => context.pushPublish(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SettingsSection(
              title: 'App',
              children: [
                SettingsRow(label: 'Settings', onTap: context.pushSettings),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final bool divided;

  const _Counter({required this.value, required this.label, required this.color, this.divided = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: divided ? Border(right: BorderSide(color: palette.outlineStrong, width: AppRules.strong)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value'.padLeft(2, '0'), style: AppTypography.numeral(34, weight: FontWeight.w900).copyWith(color: color, height: 0.9)),
          const SizedBox(height: AppSpacing.sm),
          Text(label.toUpperCase(), style: AppTypography.overline.copyWith(color: palette.inkSecondary)),
        ],
      ),
    );
  }
}
