import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/search/article_search_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/search_field_widget.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/utils/format_date_util.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_item_widget.dart';

class ArticleSearchScreen extends StatefulWidget {
  final List<ArticleEntity> articles;
  const ArticleSearchScreen({super.key, required this.articles});

  @override
  State<ArticleSearchScreen> createState() => _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends State<ArticleSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ArticleSearchBloc>(param1: widget.articles)..add(const LoadSearchHistory()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(),
        ),
      ),
    );
  }



  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: 72,
      titleSpacing: 12,
      leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back, color: colorScheme.primary)),
      title: _buildSearchField(context),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: GlobalTheme.kRule),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return  SearchFieldWidget(
        controller: _controller,
        hintText: 'Buscar en artículos cargados...',
        onChanged: (value) => context.read<ArticleSearchBloc>().add(SearchQueryChanged(value)),
        onSubmitted: (value) => context.read<ArticleSearchBloc>().add(SearchSubmitted(value)),
);
  }

 

  Widget _buildBody() {
    return BlocBuilder<ArticleSearchBloc, ArticleSearchState>(
      builder: (context, state) {
        if (state is ArticleSearchShowingHistory) return _buildHistory(context, state.history);
        if (state is ArticleSearchShowingResults) return _buildResults(context, state.results);
        return const SizedBox();
      },
    );
  }



  Widget _buildHistory(BuildContext context, List<String> history) {
    if (history.isEmpty) return _buildEmptyMessage(context, 'Sin búsquedas recientes');
    return Column(
      children: [
        _buildHistoryHeader(context),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: history.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: GlobalTheme.kRule, indent: 16, endIndent: 16),
            itemBuilder: (context, index) => _buildHistoryItem(context, history[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'RECIENTES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String term) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _selectHistoryTerm(context, term),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.history, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 14),
            Expanded(child: Text(term, style: Theme.of(context).textTheme.bodyMedium)),
            InkWell(
              onTap: () => context.read<ArticleSearchBloc>().add(RemoveSearchHistoryItem(term)),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectHistoryTerm(BuildContext context, String term) {
    _controller.text = term;
    context.read<ArticleSearchBloc>().add(SearchSubmitted(term));
  }



  Widget _buildResults(BuildContext context, List<ArticleEntity> results) {
    if (results.isEmpty) return _buildEmptyMessage(context, 'Sin resultados');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) => _buildResultItem(context, results[index]),
    );
  }

  Widget _buildResultItem(BuildContext context, ArticleEntity article) {
    return ArticleItemWidget(
      title: article.title ?? '',
      imageUrl: article.urlToImage ?? '',
      description: article.description ?? '',
      dateText: formatDateUtil(article.publishedAt),
      onTap: () => context.push(AppRouter.dailyNewsArticleDetail, extra: article),
    );
  }

  // ---------- Estado vacío compartido ----------

  Widget _buildEmptyMessage(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(message, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
    );
  }
}