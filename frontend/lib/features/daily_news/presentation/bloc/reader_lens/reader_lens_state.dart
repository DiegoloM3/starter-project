part of 'reader_lens_cubit.dart';

class ReaderLensState extends Equatable {
  /// `null` means the original text is shown.
  final ArticleLens? active;

  /// The lens whose answer is being fetched, if any.
  final ArticleLens? loading;
  final Map<ArticleLens, ArticleLensResult> results;
  final Failure? failure;

  const ReaderLensState({
    this.active,
    this.loading,
    this.results = const {},
    this.failure,
  });

  bool get isLoading => loading != null;

  /// The answer to show, when the active lens has one.
  ArticleLensResult? get current => active == null ? null : results[active];

  ReaderLensState copyWith({
    ArticleLens? active,
    bool clearActive = false,
    ArticleLens? loading,
    bool clearLoading = false,
    Map<ArticleLens, ArticleLensResult>? results,
    Failure? failure,
  }) {
    return ReaderLensState(
      active: clearActive ? null : (active ?? this.active),
      loading: clearLoading ? null : (loading ?? this.loading),
      results: results ?? this.results,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [active, loading, results, failure];
}
