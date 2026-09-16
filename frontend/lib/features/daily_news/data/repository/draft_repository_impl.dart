import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_draft_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/draft_repository.dart';

/// The draft is filed under the signed-in account, so it is still there when
/// that account comes back, and invisible to any other.
class DraftRepositoryImpl implements DraftRepository {
  final DraftLocalDataSource _local;
  final AuthRepository _auth;

  const DraftRepositoryImpl(this._local, this._auth);

  static const String guestScope = 'guest';

  String get _scope => _auth.currentUser?.id ?? guestScope;

  @override
  Future<SavedDraft?> loadDraft() async {
    final stored = _local.read(_scope);
    if (stored == null) return null;

    final image = stored.image;
    final draft = image != null && !_local.imageExists(image.path) ? stored.copyWith(clearImage: true) : stored.toEntity();
    if (draft.isEmpty) {
      await _local.delete(_scope);
      return null;
    }
    return draft;
  }

  @override
  Future<DataState<void>> saveDraft(SavedDraft draft) => runGuarded(
        () => _local.write(_scope, SavedDraftModel.fromEntity(draft)),
        onError: (_) => const Failure.unknown("Your draft couldn't be saved."),
      );

  @override
  Future<DataState<void>> clearDraft() => runGuarded(
        () => _local.delete(_scope),
        onError: (_) => const Failure.unknown("Your draft couldn't be cleared."),
      );
}
