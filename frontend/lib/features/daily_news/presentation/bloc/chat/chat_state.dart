import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  final List<Map<String, String>> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [{'role': 'assistant', 'content': 'Hola, soy el Búho de Symmetry. ¿En qué puedo ayudarte hoy?'}],
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [messages, isLoading, error];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super();
}

class ChatLoading extends ChatState {
  const ChatLoading(List<Map<String, String>> messages) : super(messages: messages, isLoading: true);
}

class ChatSuccess extends ChatState {
  const ChatSuccess(List<Map<String, String>> messages) : super(messages: messages, isLoading: false);
}

class ChatError extends ChatState {
  const ChatError(List<Map<String, String>> messages, String error) 
    : super(messages: messages, isLoading: false, error: error);
}
