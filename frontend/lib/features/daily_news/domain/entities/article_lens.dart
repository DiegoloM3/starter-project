import 'package:equatable/equatable.dart';

/// Alternative ways to read an article. The original is never changed;
/// a lens is a view the reader switches on and off.
enum ArticleLens {
  /// Three bullets that let the reader skip the article.
  brief('Brief it'),

  /// The same facts in short sentences and everyday words.
  plain('Plain words');

  final String label;

  const ArticleLens(this.label);
}

/// The outcome of applying a lens: bullets for [ArticleLens.brief], a
/// rewritten text for [ArticleLens.plain].
class ArticleLensResult extends Equatable {
  final ArticleLens lens;
  final List<String> bullets;
  final String text;

  const ArticleLensResult({required this.lens, this.bullets = const [], this.text = ''});

  /// What "Listen" should read for this view.
  String get spokenText => bullets.isNotEmpty ? bullets.join('. ') : text;

  @override
  List<Object?> get props => [lens, bullets, text];
}
