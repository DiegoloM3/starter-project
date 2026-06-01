import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/features/articles/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:tortutip/features/articles/presentation/screens/create_article_screen.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';

import 'app_routes.dart';
import 'tortutip_tab_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/explore')) return 2;
    return -1;
  }

  Future<void> _onTabTap(BuildContext context, int index) async {
    switch (index) {
      case 0:
        context.go(AppRoutes.feed);
      case 1:
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && authState.user.role == 'writer') {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: AppColors.dark.withValues(alpha: 0.5),
            builder: (_) => BlocProvider(
              create: (_) => GetIt.instance<CreateArticleCubit>(),
              child: const _CreateArticleModal(),
            ),
          );
        }
      case 2:
        context.go(AppRoutes.explore);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isWriter = authState is AuthAuthenticated && authState.user.role == 'writer';
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: TortuTipTabBar(
        currentIndex: _currentIndex(context),
        onTabTap: (i) => _onTabTap(context, i),
        isWriter: isWriter,
      ),
    );
  }
}

class _CreateArticleModal extends StatelessWidget {
  const _CreateArticleModal();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.9],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                const _ModalDragHandle(),
                const Expanded(child: CreateArticleScreen()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModalDragHandle extends StatelessWidget {
  const _ModalDragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: AppSpacing.dragHandleWidth,
                height: AppSpacing.xs,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              size: AppSpacing.iconMd,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
