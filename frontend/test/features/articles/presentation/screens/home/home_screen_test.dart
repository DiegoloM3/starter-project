import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles/articles_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles/articles_state.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/saved_articles/saved_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/saved_articles/saved_articles_state.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/screens/home/home_screen.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_state.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockArticlesCubit extends MockCubit<ArticlesState> implements ArticlesCubit {}

class MockSavedArticlesCubit extends MockCubit<SavedArticlesState> implements SavedArticlesCubit {}

UserEntity buildUser(UserRole role) {
  return UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: role);
}

void main() {
  Future<void> pumpHomeScreen(WidgetTester tester, UserEntity user) {
    final authCubit = MockAuthCubit();
    final articlesCubit = MockArticlesCubit();
    final savedArticlesCubit = MockSavedArticlesCubit();
    whenListen(authCubit, const Stream<AuthState>.empty(), initialState: AuthAuthenticated(user));
    whenListen(
      articlesCubit,
      const Stream<ArticlesState>.empty(),
      initialState: const ArticlesState(status: ArticlesStatus.success),
    );
    whenListen(
      savedArticlesCubit,
      const Stream<SavedArticlesState>.empty(),
      initialState: const SavedArticlesState(status: SavedArticlesStatus.success),
    );

    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<ArticlesCubit>.value(value: articlesCubit),
          BlocProvider<SavedArticlesCubit>.value(value: savedArticlesCubit),
        ],
        child: MaterialApp(home: HomeScreen(user: user)),
      ),
    );
  }

  testWidgets('shows the publish tab to journalists', (tester) async {
    await pumpHomeScreen(tester, buildUser(UserRole.journalist));

    expect(find.text('Publicar'), findsOneWidget);
  });

  testWidgets('hides the publish tab from readers', (tester) async {
    await pumpHomeScreen(tester, buildUser(UserRole.reader));

    expect(find.text('Publicar'), findsNothing);
    expect(find.text('Noticias'), findsOneWidget);
  });

  testWidgets('switches to the tapped tab', (tester) async {
    await pumpHomeScreen(tester, buildUser(UserRole.reader));

    await tester.tap(find.text('Perfil'));
    await tester.pump();

    expect(find.text('Jane Doe'), findsOneWidget);
  });
}
