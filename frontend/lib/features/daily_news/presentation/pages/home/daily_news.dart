import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../../community_articles/domain/entities/community_article.dart';
import '../../../../community_articles/presentation/screens/community_articles_screen.dart';
import '../../../../../core/constants/constants.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_state.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({super.key});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews>
    with SingleTickerProviderStateMixin {
  late final TabController _sourceController;

  @override
  void initState() {
    super.initState();
    _sourceController = TabController(
      length: 2,
      vsync: this,
      initialIndex: newsAPIKey.trim().isEmpty ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure &&
            (ModalRoute.of(context)?.isCurrent ?? true)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, authState) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 482),
            child: SizedBox(
              width: double.infinity,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Daily News'),
                  actions: [
                    IconButton(
                      tooltip: 'Saved articles',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/SavedArticles'),
                      icon: const Icon(Icons.bookmark, color: Colors.black),
                    ),
                    _buildAccountAction(authState),
                  ],
                ),
                body: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: TabBar(
                        controller: _sourceController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: const Color(0xFFE1BEDE),
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: 'Latest news'),
                          Tab(text: 'Community'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _sourceController,
                        builder: (context, _) {
                          if (_sourceController.index == 1) {
                            return CommunityArticlesScreen(
                              onArticlePressed: (article) =>
                                  _openCommunityArticle(context, article),
                            );
                          }
                          return _DailyNewsFeed(
                            onSwitchToCommunity: () =>
                                _sourceController.animateTo(1),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                floatingActionButton: SizedBox(
                  width: 70,
                  height: 70,
                  child: FloatingActionButton(
                    tooltip: 'Publish article',
                    backgroundColor: const Color(0xFFE1BEDE),
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: _openPublishFlow,
                    child: const Icon(Icons.add, size: 34),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountAction(AuthState state) {
    if (state is AuthLoading && state.user == null) {
      return const SizedBox(
        width: 72,
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (state.user != null) {
      return Semantics(
        button: true,
        label: 'Account',
        child: TextButton(
          onPressed: _openAccountMenu,
          child: const Text('Account'),
        ),
      );
    }
    return Semantics(
      button: true,
      label: 'Sign in',
      child: TextButton(
        onPressed: _openStandaloneAuth,
        child: const Text('Sign in'),
      ),
    );
  }

  Future<void> _openStandaloneAuth() async {
    await Navigator.pushNamed(context, '/Auth');
  }

  Future<void> _openAccountMenu() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        final displayName = user.displayName.trim();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text(
                    displayName.isEmpty ? 'Journalist account' : displayName),
                subtitle: Text(user.email),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<AuthCubit>().signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCommunityArticle(
      BuildContext context, CommunityArticleEntity article) {
    Navigator.pushNamed(context, '/CommunityArticleDetails',
        arguments: article);
  }

  Future<void> _openPublishFlow() async {
    final authState = context.read<AuthCubit>().state;
    if (authState.user != null) {
      final published = await Navigator.pushNamed(context, '/PublishArticle');
      if (published == true && mounted) {
        _sourceController.animateTo(1);
      }
      return;
    }
    final signedIn = await Navigator.pushNamed(context, '/Auth');
    if (signedIn == true && mounted) {
      final published = await Navigator.pushNamed(context, '/PublishArticle');
      if (published == true && mounted) {
        _sourceController.animateTo(1);
      }
    }
  }
}

class _DailyNewsFeed extends StatelessWidget {
  final VoidCallback onSwitchToCommunity;

  const _DailyNewsFeed({required this.onSwitchToCommunity});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 482),
        child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) {
            if (state is RemoteArticlesLoading) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (state is RemoteArticlesError) {
              final failureMessage = state.error?.message;
              final message = failureMessage == null ||
                      failureMessage == 'Unable to load daily news.'
                  ? 'Latest news is currently unavailable from the external provider.'
                  : failureMessage;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Latest news is temporarily unavailable.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: onSwitchToCommunity,
                        icon: const Icon(Icons.people_outline),
                        label: const Text('View Community articles'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is RemoteArticlesDone) {
              final articles = state.articles ?? const <ArticleEntity>[];
              if (articles.isEmpty) {
                return const Center(child: Text('No daily news available.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: articles.length,
                itemBuilder: (context, index) => ArticleWidget(
                  article: articles[index],
                  onArticlePressed: (article) => Navigator.pushNamed(
                    context,
                    '/ArticleDetails',
                    arguments: article,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
