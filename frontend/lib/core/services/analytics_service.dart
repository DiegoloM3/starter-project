import 'dart:developer' as developer;

enum AnalyticsEvent {
  onStartCreate,
  onSubmit,
  onSuccess,
  onError,
  onDraftSaved,
  onDraftRestored,
  onDraftDiscarded,
}

abstract class AnalyticsService {
  void trackEvent(AnalyticsEvent event, {Map<String, dynamic>? properties});
}

class ConsoleAnalyticsService implements AnalyticsService {
  @override
  void trackEvent(AnalyticsEvent event, {Map<String, dynamic>? properties}) {
    final timestamp = DateTime.now().toIso8601String();
    final props = properties != null ? ' $properties' : '';
    developer.log('[$timestamp] ${event.name}$props', name: 'Analytics');
  }
}
