import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme.dart';
import 'package:news_app_clean_architecture/config/theme/theme_mode_mapper.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/brief/brief_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/listen/listen_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';

/// Root widget: provides the app-wide cubits, applies the user's theme and
/// text size, and hands navigation to the router.
class DailyNewsApp extends StatefulWidget {
  final SessionCubit sessionCubit;
  final SettingsCubit settingsCubit;
  final SavedArticlesCubit savedArticlesCubit;
  final FeedCubit feedCubit;
  final MyArticlesCubit myArticlesCubit;
  final BriefCubit briefCubit;
  final ListenCubit listenCubit;

  const DailyNewsApp({
    super.key,
    required this.sessionCubit,
    required this.settingsCubit,
    required this.savedArticlesCubit,
    required this.feedCubit,
    required this.myArticlesCubit,
    required this.briefCubit,
    required this.listenCubit,
  });

  @override
  State<DailyNewsApp> createState() => _DailyNewsAppState();
}

class _DailyNewsAppState extends State<DailyNewsApp> {
  late final GoRouter _router = AppRouter.build(widget.sessionCubit);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.sessionCubit),
        BlocProvider.value(value: widget.settingsCubit),
        BlocProvider.value(value: widget.savedArticlesCubit),
        BlocProvider.value(value: widget.feedCubit),
        BlocProvider.value(value: widget.myArticlesCubit),
        BlocProvider.value(value: widget.briefCubit),
        BlocProvider.value(value: widget.listenCubit),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        // Whatever the previous account had loaded must not show to the next
        // one; the device data itself is wiped by the sign-out use case.
        listenWhen: (previous, current) =>
            previous is SessionAuthenticated && current is SessionUnauthenticated,
        listener: (context, _) {
          context.read<SavedArticlesCubit>().reset();
          context.read<MyArticlesCubit>().reset();
          context.read<BriefCubit>().reset();
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'Headline News',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: state.settings.themeMode.material,
              routerConfig: _router,
              builder: (context, child) => _TextSizeScope(
                factor: state.settings.textSize.factor,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Multiplies the platform text scale by the user's reading-size choice.
class _TextSizeScope extends StatelessWidget {
  final double factor;
  final Widget child;

  const _TextSizeScope({required this.factor, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final platformScale = media.textScaler.scale(1);
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(platformScale * factor)),
      child: child,
    );
  }
}
