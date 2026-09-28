import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/comments/domain/entities/comment.entity.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/widgets/comment_composer.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/widgets/comment_tile.dart';

const tComment = CommentEntity(
  id: 'c1',
  articleId: 'article-1',
  authorId: 'user-1',
  authorDisplayName: 'Ada',
  content: 'Hello world',
  createdAt: '2026-09-27T00:00:00.000Z',
);

Future<void> _pumpTile(
  WidgetTester tester, {
  bool isOwn = false,
  VoidCallback? onDelete,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CommentTile(
          comment: tComment,
          isOwn: isOwn,
          onDelete: onDelete,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows author name and markdown content', (tester) async {
    await _pumpTile(tester);

    expect(find.text('Ada'), findsOneWidget);
    expect(
      find.textContaining('Hello world', findRichText: true),
      findsWidgets,
    );
    expect(find.byIcon(Ionicons.trashOutline), findsNothing);
  });

  testWidgets('shows delete action for own comments', (tester) async {
    var deleted = false;
    await _pumpTile(
      tester,
      isOwn: true,
      onDelete: () => deleted = true,
    );

    await tester.tap(find.byIcon(Ionicons.trashOutline));

    expect(deleted, isTrue);
  });

  testWidgets('composer posts the typed text', (tester) async {
    String? posted;
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommentComposer(
            controller: controller,
            onPost: (text) => posted = text,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'My comment');
    await tester.tap(find.text('Post'));

    expect(posted, 'My comment');
    controller.dispose();
  });

  testWidgets('composer disables input while posting', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommentComposer(
            controller: TextEditingController(),
            onPost: (_) {},
            isPosting: true,
          ),
        ),
      ),
    );

    final postButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(postButton.enabled, isFalse);
  });
}
