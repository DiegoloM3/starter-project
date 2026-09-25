import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Deliberately NOT wrapped in a use_case/repository, unlike every Cubit in
/// user_articles/account: this is pure in-memory UI state with no I/O to
/// abstract -- the domain/data split exists to isolate real I/O and
/// business rules from the UI, and there's neither here. If persisting the
/// choice across app restarts is ever wanted, THAT'S the point to add a
/// ThemeRepository backed by a real data source (shared_preferences),
/// mirroring exactly how user_articles/account wrap Firebase -- not before.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setMode(ThemeMode mode) => emit(mode);
}
