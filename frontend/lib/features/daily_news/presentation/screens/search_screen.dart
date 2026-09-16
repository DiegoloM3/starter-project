import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/search_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_item.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/feed/feed_skeleton.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/search/search_idle_view.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/empty_state.dart';

/// Search tab: one framed field, recent queries and the section grid while
/// idle, results in the feed row format once there is a query.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<SearchCubit>(), child: const SearchView());
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _run(String query) {
    _controller.text = query;
    context.read<SearchCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<SearchCubit>();
    final userId = context.select((SessionCubit c) => c.state.user?.id);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.lg),
                  child: Text('SEARCH', style: AppTypography.tabTitle.copyWith(color: palette.ink)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, 0, AppSpacing.screenMargin, AppSpacing.lg),
                  child: TextField(
                    controller: _controller,
                    onChanged: cubit.queryChanged,
                    onSubmitted: cubit.search,
                    textInputAction: TextInputAction.search,
                    style: AppTypography.valueLine.copyWith(color: palette.ink),
                    decoration: InputDecoration(
                      hintText: 'Topic, author, outlet',
                      prefixIcon: Icon(Icons.search_rounded, color: palette.ink, size: 20),
                      enabledBorder: _frame(palette.ink),
                      focusedBorder: _frame(palette.primary),
                      suffixIcon: state.query.isEmpty
                          ? null
                          : TextButton.icon(
                              onPressed: () {
                                _controller.clear();
                                cubit.clear();
                              },
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text('Clear'),
                            ),
                    ),
                  ),
                ),
                Expanded(child: _body(context, state, userId, bottomInset)),
              ],
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder _frame(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: color, width: AppRules.strong),
      );

  Widget _body(BuildContext context, SearchState state, String? userId, double bottomInset) {
    final palette = context.palette;
    final rule = BorderSide(color: palette.outlineStrong, width: AppRules.strong);
    return switch (state.status) {
      SearchStatus.idle => SearchIdleView(
          recent: state.recent,
          onRecentTap: _run,
          onClearRecent: context.read<SearchCubit>().clearRecent,
          onTopicTap: (topic) => _run(topic.label),
        ),
      SearchStatus.loading => const SingleChildScrollView(child: FeedSkeleton(rows: 3)),
      SearchStatus.failure => EmptyState(
          glyph: '!',
          title: "Couldn't search right now",
          message: FailureMessageFormatter.of(state.failure!),
        ),
      SearchStatus.results when state.results.isEmpty => EmptyState(
          glyph: '?',
          title: 'No stories about "${state.query.trim()}"',
          message: 'Check the spelling, or try a shorter word.',
        ),
      SearchStatus.results => ListView(
          padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.xxl),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin, vertical: 12),
              decoration: BoxDecoration(border: Border(top: rule, bottom: rule)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${state.results.length} ${state.results.length == 1 ? 'result' : 'results'}'.toUpperCase(),
                      style: AppTypography.sectionOverline.copyWith(color: palette.ink),
                    ),
                  ),
                  Text('NEWEST FIRST', style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary)),
                ],
              ),
            ),
            for (final (index, article) in state.results.indexed) ...[
              FeedItem(
                article: article,
                number: index + 1,
                isOwn: article.isOwnedBy(userId),
                highlight: state.query,
                onTap: () => context.pushReader(article),
              ),
              const Divider(),
            ],
          ],
        ),
    };
  }
}
