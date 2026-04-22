import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/chat_service.dart';
import 'package:news_app_clean_architecture/core/analytics/analytics_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/chat/chat_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/chat/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService _chatService;
  final AnalyticsRepository _analyticsRepository;

  ChatBloc(this._chatService, this._analyticsRepository) : super(const ChatInitial()) {
    on<ChatMessageSent>(_onMessageSent);
    on<ChatHistoryCleared>(_onHistoryCleared);
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (event.message.isEmpty) return;

    final updatedMessages = List<Map<String, String>>.from(state.messages)
      ..add({'role': 'user', 'content': event.message});

    emit(ChatLoading(updatedMessages));

    try {
      final response = await _chatService.getChatResponse(event.message);
      
      final finalMessages = List<Map<String, String>>.from(updatedMessages)
        ..add({'role': 'assistant', 'content': response});

      // Track interaction for Data-Driven Decisions & Tokenomics (mocked tokens for now)
      _analyticsRepository.trackChatInteraction(
        prompt: event.message,
        response: response,
        estimatedTokens: (event.message.length + response.length) ~/ 4, // Rough estimation
      );

      emit(ChatSuccess(finalMessages));
    } catch (e) {
      emit(ChatError(updatedMessages, "Error al conectar con la inteligencia de Symmetry."));
    }
  }

  void _onHistoryCleared(ChatHistoryCleared event, Emitter<ChatState> emit) {
    emit(const ChatInitial());
  }
}
