// coverage:ignore-file
// Thin wrapper over the Cloud Functions SDK.
// Covered by the repository tests above it, with the SDK mocked at this seam.
import 'package:cloud_functions/cloud_functions.dart';

/// Calls the `assistArticle` Cloud Function. The only place that knows the
/// function's name, region and wire format. Errors propagate as
/// [FirebaseFunctionsException]s.
class AssistantFunctionsService {
  final FirebaseFunctions _functions;

  AssistantFunctionsService(this._functions);

  static const String functionName = 'assistArticle';
  static const String region = 'us-central1';

  static AssistantFunctionsService forRegion() =>
      AssistantFunctionsService(FirebaseFunctions.instanceFor(region: region));

  /// [task] is one of `suggest`, `brief`, `plain`.
  Future<Map<String, dynamic>> call({
    required String task,
    required String title,
    required String content,
  }) async {
    final callable = _functions.httpsCallable(
      functionName,
      options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
    );
    final result = await callable.call<Map<Object?, Object?>>({
      'task': task,
      'title': title,
      'content': content,
    });
    return Map<String, dynamic>.from(result.data);
  }
}
