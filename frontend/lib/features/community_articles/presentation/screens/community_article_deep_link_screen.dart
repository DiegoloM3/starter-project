import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/community_article_lookup_cubit.dart';
import '../bloc/social_interactions_cubit.dart';
import 'community_article_detail_screen.dart';

class CommunityArticleDeepLinkScreen extends StatelessWidget {
  const CommunityArticleDeepLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityArticleLookupCubit,
        CommunityArticleLookupState>(
      builder: (context, state) {
        if (state is CommunityArticleLookupLoaded) {
          // The detail screen owns the loaded route surface and its AppBar.
          // Keeping the outer Scaffold here would render two back buttons.
          final article = state.article;
          return BlocProvider(
            create: (_) => sl<SocialInteractionsCubit>(param1: article.id),
            child: CommunityArticleDetailScreen(article: article),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          body: _buildLookupState(context, state),
        );
      },
    );
  }

  Widget _buildLookupState(
    BuildContext context,
    CommunityArticleLookupState state,
  ) {
    if (state is CommunityArticleLookupLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CommunityArticleLookupFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    context.read<CommunityArticleLookupCubit>().load(),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
