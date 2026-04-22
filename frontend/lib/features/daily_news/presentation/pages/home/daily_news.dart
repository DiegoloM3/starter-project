import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Elegant Imports (Barrels)
import 'package:news_app_clean_architecture/core/core.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/daily_news_domain.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/daily_news_presentation.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/reward_api_service.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  late ScrollController _scrollController;
  bool _isOwlVisible = true;
  Timer? _visibilityTimer;
  String _assistantMessage = 'Hola, soy tu asistente Owl. Toca aquí para analizar noticias.';
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchBalance();
  }

  void _fetchBalance() async {
    try {
      final result = await sl<RewardApiService>().getBalance(kAlphaTesterId);

      if (mounted) {
        setState(() {
          _balance = (result['balance'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching balance: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _visibilityTimer?.cancel();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      if (_isOwlVisible) {
        setState(() {
          _isOwlVisible = false;
        });
      }
      _visibilityTimer?.cancel();
    } else if (notification is ScrollEndNotification) {
      _visibilityTimer?.cancel();
      _visibilityTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isOwlVisible = true;
            // Update message based on visible content (simplified)
            _assistantMessage = AssistantBrain.getRandomMessage();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScrollNotification(notification);
          return false;
        },
        child: _buildBody(context),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: const Text('🦉', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
              children: [
                TextSpan(text: 'Symmetry'),
                TextSpan(text: ' News', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildBalanceWidget(),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/Search'),
          icon: const Icon(Icons.search, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBalanceWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flash_on, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            '${_balance.toInt()} SYM',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (_, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator(color: AppColors.primary));
        }
        if (state is RemoteArticlesError) {
          return Center(
            child: IconButton(
              onPressed: () => _onRefresh(context),
              icon: const Icon(Icons.refresh, color: AppColors.primary),
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                color: AppColors.primary,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: (state.articles?.length ?? 0) + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const CtaBanner();
                    }
                    final article = state.articles![index - 1];
                    return ArticleWidget(
                      article: article,
                      onArticlePressed: (article) => _onArticlePressed(context, article),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                right: 0,
                child: OwlAssistant(
                  text: _assistantMessage,
                  isVisible: _isOwlVisible,
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 1)),
      ),
      child: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) context.read<RemoteArticlesBloc>().add(const GetArticles());
          if (index == 1) _onTopicsPressed(context);
          if (index == 2) _onPublishPressed(context);
          if (index == 3) _onShowSavedArticlesViewTapped(context);
          if (index == 4) _onProfilePressed(context);
        },

        currentIndex: 0,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Tópicos'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: Colors.black),
            ),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Guardado'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    sl<AnalyticsRepository>().trackArticleView(article);
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }

  void _onPublishPressed(BuildContext context) {
    Navigator.pushNamed(context, '/PublishArticle');
  }

  void _onProfilePressed(BuildContext context) {
    Navigator.pushNamed(context, '/Profile');
  }

  void _onTopicsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/Topics');
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<RemoteArticlesBloc>().add(const GetArticles());
  }
}
