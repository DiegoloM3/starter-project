import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/daily_news/domain/entities/article.dart';
import 'analytics_repository.dart';

class FirestoreAnalyticsImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreAnalyticsImpl(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<void> trackArticleView(ArticleEntity article) async {
    await _logInteraction('article_view', {
      'article_id': article.url, 
      'article_title': article.title,
      'article_author': article.author,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> trackChatInteraction({
    required String prompt,
    required String response,
    required int estimatedTokens,
  }) async {
    await _logInteraction('chat_interaction', {
      'prompt_length': prompt.length,
      'response_length': response.length,
      'estimated_tokens': estimatedTokens, // Key for Tokenomics
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> trackEvent(String eventName, Map<String, dynamic> properties) async {
    await _logInteraction(eventName, {
      ...properties,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> trackSessionStart() async {
    await _logInteraction('session_start', {
      'timestamp': FieldValue.serverTimestamp(),
      'platform': 'android', // Could be dynamic
    });
  }

  Future<void> _logInteraction(String collection, Map<String, dynamic> data) async {
    try {
      final finalData = {
        ...data,
        'user_id': _userId ?? 'anonymous',
        'app_version': '1.1.0',
      };
      
      // We use a hierarchical structure: interaction_logs -> {userId} -> {collection} -> {doc}
      // Or flat for global analysis: interaction_logs -> {doc}
      // For now, flat with user_id field for easier querying across all users (Data-driven decisions)
      await _firestore.collection('telemetry_$collection').add(finalData);
    } catch (e) {
      // Fail silently in production to not interrupt UX
      print('Analytics Error: $e');
    }
  }
}
