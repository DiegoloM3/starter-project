import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(const UserProfileState());

  void updateProfile({String? name, String? email}) {
    emit(UserProfileState(
      name: (name != null && name.isNotEmpty) ? name : state.name,
      email: (email != null && email.isNotEmpty) ? email : state.email,
    ));
  }
}
