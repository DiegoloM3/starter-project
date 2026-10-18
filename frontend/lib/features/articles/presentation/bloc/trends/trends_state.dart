import 'package:equatable/equatable.dart';

import '../../../domain/entities/topic_trend.dart';

enum TrendsStatus { initial, loading, success, failure }

class TrendsState extends Equatable {
  final TrendsStatus status;

  /// Most popular topic first.
  final List<TopicTrend> trends;

  const TrendsState({this.status = TrendsStatus.initial, this.trends = const []});

  @override
  List<Object?> get props => [status, trends];
}
