import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ArticleEntity> _filteredArticles = [];
  bool _hasSearched = false;

  void _onSearchChanged(String query, List<ArticleEntity> allArticles) {
    setState(() {
      _hasSearched = query.isNotEmpty;
      _filteredArticles = allArticles.where((article) {
        final title = article.title?.toLowerCase() ?? '';
        final desc = article.description?.toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) || desc.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'BUSCAR EN LA RED SYMMETRY...',
            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
            border: InputBorder.none,
          ),
          onChanged: (query) {
            final state = context.read<RemoteArticlesBloc>().state;
            if (state is RemoteArticlesDone) {
              _onSearchChanged(query, state.articles ?? []);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // Scanline effect overlay
          _buildScanlines(),
          
          _hasSearched 
            ? _buildSearchResults()
            : _buildSearchPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredArticles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text('SIN COINCIDENCIAS EN LA BASE DE DATOS', style: TextStyle(color: Colors.white24, letterSpacing: 1)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredArticles.length,
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: _filteredArticles[index],
          onArticlePressed: (article) {
            Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
          },
        );
      },
    );
  }

  Widget _buildSearchPlaceholder() {
    return Center(
      child: Opacity(
        opacity: 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyanAccent, width: 1),
              ),
              child: const Icon(Icons.saved_search, color: Colors.cyanAccent, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'INGRESE CRITERIOS DE BÚSQUEDA',
              style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanlines() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: List.generate(
            100, 
            (index) => Container(
              height: 1, 
              color: Colors.white.withOpacity(0.005),
              margin: const EdgeInsets.only(bottom: 2),
            )
          ),
        ),
      ),
    );
  }
}
