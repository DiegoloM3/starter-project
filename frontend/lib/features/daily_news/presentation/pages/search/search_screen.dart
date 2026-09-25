import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import '../../../domain/entities/search_history_entity.dart';
import '../../bloc/search/search_cubit.dart';
import '../../bloc/search/search_state.dart';
import '../../widgets/story_tiles.dart';

/// Searches every source NewsAPI covers, in the app's language, with the
/// same story rows as the front page.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      unawaited(context.read<SearchCubit>().loadMore());
    }
  }

  void _search() {
    FocusScope.of(context).unfocus();
    unawaited(context.read<SearchCubit>().search(
          _textController.text,
          languageCode: Localizations.localeOf(context).languageCode,
        ));
  }

  void _clear() {
    _textController.clear();
    unawaited(context.read<SearchCubit>().showHistory());
  }

  void _searchAgain(String text) {
    _textController.text = text;
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _textController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: _textController,
            builder: (context, _) => _textController.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: context.l10n.clearSearch,
                    icon: const Icon(Icons.close),
                    onPressed: _clear,
                  ),
          ),
          IconButton(
            tooltip: context.l10n.searchAction,
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) => switch (state) {
          SearchIdle(history: final history) when history.isEmpty =>
            _SearchMessage(
              icon: Icons.travel_explore,
              title: context.l10n.searchPromptTitle,
              detail: context.l10n.searchPromptDetail,
            ),
          SearchIdle(history: final history) => _buildHistory(history),
          SearchLoading() => const Center(child: CupertinoActivityIndicator()),
          SearchError() => _SearchMessage(
              icon: Icons.cloud_off_outlined,
              title: context.l10n.searchFailed,
              action: FilledButton.tonal(
                onPressed: _search,
                child: Text(context.l10n.tryAgain),
              ),
            ),
          SearchResults(articles: final articles) when articles.isEmpty =>
            _SearchMessage(
              icon: Icons.search_off,
              title: context.l10n.noResultsFor(state.text),
              detail: context.l10n.noResultsDetail,
            ),
          SearchResults() => _buildResults(state),
        },
      ),
    );
  }

  Widget _buildHistory(List<SearchHistoryEntity> history) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            context.l10n.recentSearches.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.2),
          ),
        ),
        for (final entry in history)
          ListTile(
            leading: const Icon(Icons.history),
            title:
                Text(entry.text, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => _searchAgain(entry.text),
            trailing: IconButton(
              tooltip: context.l10n.removeFromHistory,
              icon: const Icon(Icons.close),
              onPressed: () => unawaited(
                  context.read<SearchCubit>().removeFromHistory(entry.text)),
            ),
          ),
      ],
    );
  }

  Widget _buildResults(SearchResults state) {
    final articles = state.articles;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: articles.length + 1,
      separatorBuilder: (_, __) => const Divider(indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return state.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CupertinoActivityIndicator()),
                )
              : const SizedBox.shrink();
        }
        final article = articles[index];
        return StoryRow(
          article: article,
          onTap: () => Navigator.pushNamed(context, '/ArticleDetails',
              arguments: article),
        );
      },
    );
  }
}

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? detail;
  final Widget? action;

  const _SearchMessage({
    required this.icon,
    required this.title,
    this.detail,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium),
            if (detail != null) ...[
              const SizedBox(height: 6),
              Text(detail!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
