import 'package:equatable/equatable.dart';

import '../../../domain/entities/journalist_stats.dart';

enum JournalistStatsStatus { initial, loading, ready, failure }

/// The summary on the account screen, and whether it is there yet.
class JournalistStatsState extends Equatable {
  final JournalistStatsStatus status;

  /// The numbers themselves. Counting them is the domain's job; this state
  /// only carries the answer to the screen.
  final JournalistStatsEntity stats;

  const JournalistStatsState({
    this.status = JournalistStatsStatus.initial,
    this.stats = const JournalistStatsEntity(),
  });

  bool get isReady => status == JournalistStatsStatus.ready;

  int get articleCount => stats.articleCount;

  int get totalViews => stats.totalViews;

  bool get hasArticles => stats.hasArticles;

  @override
  List<Object?> get props => [status, stats];
}
