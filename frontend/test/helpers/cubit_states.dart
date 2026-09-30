import 'package:flutter_bloc/flutter_bloc.dart';

/// Records every state [cubit] emits while [action] runs.
///
/// A lightweight replacement for bloc_test's `blocTest`, which cannot be added to this
/// project (its dependencies conflict with retrofit_generator's analyzer version).
Future<List<State>> statesEmittedBy<State>(BlocBase<State> cubit, Future<void> Function() action) async {
  final states = <State>[];
  final subscription = cubit.stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await subscription.cancel();
  return states;
}
