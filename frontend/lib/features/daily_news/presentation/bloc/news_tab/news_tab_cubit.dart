import 'package:flutter_bloc/flutter_bloc.dart';

class NewsTabCubit extends Cubit<int> {
  NewsTabCubit() : super(0);

  void selectTab(int index) => emit(index);
}
