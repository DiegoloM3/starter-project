import 'package:equatable/equatable.dart';

enum ArticleBylineStatus { idle, working, done, failure }

/// Whether the journalist's back catalogue has caught up with the name on
/// their account.
class ArticleBylineState extends Equatable {
  final ArticleBylineStatus status;

  /// How many articles the last rename rewrote. Zero is an ordinary answer:
  /// somebody who has not written yet has no byline to move.
  final int renamedCount;

  final Object? error;

  const ArticleBylineState({
    this.status = ArticleBylineStatus.idle,
    this.renamedCount = 0,
    this.error,
  });

  bool get isWorking => status == ArticleBylineStatus.working;

  @override
  List<Object?> get props => [status, renamedCount, error];
}
