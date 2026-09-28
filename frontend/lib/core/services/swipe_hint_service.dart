
import 'package:shared_preferences/shared_preferences.dart';

class SwipeHintService {
  factory SwipeHintService() => _instance;
  static final SwipeHintService _instance = SwipeHintService._internal();
  SwipeHintService._internal();

  static const _key = 'has_seen_swipe_hint';

  Future<void> resetHint() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    }


  Future<bool> hasSeenHint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markHintAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}