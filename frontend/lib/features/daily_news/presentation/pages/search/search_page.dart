import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/search/search_articles_bloc.dart';
import '../../bloc/article/search/search_articles_event.dart';
import '../../bloc/article/search/search_articles_state.dart';
import '../../widgets/article_tile.dart';
import '../../widgets/skeleton_article_tile.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchArticlesBloc>(
      create: (_) => sl<SearchArticlesBloc>(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: const Column(
          children: [
            _SearchField(),
            Expanded(child: _SearchResults()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, color: Colors.black),
        ),
      ),
      title: Text(AppLocalizations.of(context)!.searchTitle,
          style: const TextStyle(color: Colors.black)),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchHint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFCE93D8)),
          ),
        ),
        onChanged: (query) {
          context.read<SearchArticlesBloc>().add(SearchQueryChanged(query));
        },
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchArticlesBloc, SearchArticlesState>(
      builder: (context, state) {
        if (state is SearchArticlesInitial) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.typeToSearch,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          );
        }
        if (state is SearchArticlesLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const SkeletonArticleTile(),
          );
        }
        if (state is SearchArticlesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  state.error?.message ??
                      AppLocalizations.of(context)!.searchFailed,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        if (state is SearchArticlesDone) {
          final articles = state.articles ?? [];
          if (articles.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noArticlesFound,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleWidget(
                article: articles[index],
                onArticlePressed: (article) => _onArticlePressed(
                    context, article),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}
