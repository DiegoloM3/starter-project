import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/get_reading_history.dart';

/// Recently viewed articles of the signed in user. The state is the list itself: the profile
/// simply hides the section while it is empty.
class ReadingHistoryCubit extends Cubit<List<ArticleEntity>> {
  final GetReadingHistoryUseCase _getReadingHistoryUseCase;

  ReadingHistoryCubit(this._getReadingHistoryUseCase) : super(const []);

  Future<void> load() async {
    final result = await _getReadingHistoryUseCase(const NoParams());
    if (result is DataSuccess) emit(result.data!);
  }
}
