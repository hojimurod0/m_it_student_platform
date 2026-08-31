import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/error/failures.dart';
import 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';
import 'package:m_it_student_platform/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:m_it_student_platform/features/chat/domain/usecases/send_message_usecase.dart';

export 'package:m_it_student_platform/features/chat/domain/entities/chat_message.dart';

// ── Events ─────────────────────────────────────────────────────────────────

sealed class ChatEvent {
  const ChatEvent();
}

class LoadChatMessagesEvent extends ChatEvent {
  const LoadChatMessagesEvent({required this.groupId, this.myUserId});
  final String groupId;
  final String? myUserId;
}

class SendChatMessageEvent extends ChatEvent {
  const SendChatMessageEvent({
    required this.groupId,
    required this.text,
    this.attachmentUrl,
  });
  final String groupId;
  final String text;
  final String? attachmentUrl;
}

class RefreshChatEvent extends ChatEvent {
  const RefreshChatEvent({required this.groupId, this.myUserId});
  final String groupId;
  final String? myUserId;
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded(this.messages, {this.isSending = false});
  final List<ChatMessage> messages;
  final bool isSending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatLoaded && runtimeType == other.runtimeType && messages == other.messages && isSending == other.isSending;

  @override
  int get hashCode => Object.hash(messages, isSending);
}

class ChatError extends ChatState {
  const ChatError({required this.failure, required this.message});
  final Failure failure;
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatError && runtimeType == other.runtimeType && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

class ChatMessageSent extends ChatState {
  const ChatMessageSent(this.messages);
  final List<ChatMessage> messages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageSent && runtimeType == other.runtimeType && messages == other.messages;

  @override
  int get hashCode => messages.hashCode;
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        super(const ChatInitial()) {
    on<LoadChatMessagesEvent>(_onLoad);
    on<SendChatMessageEvent>(_onSend);
    on<RefreshChatEvent>(_onRefresh);
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;

  Future<void> _onLoad(LoadChatMessagesEvent event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    final result = await _getMessagesUseCase(event.groupId);
    result.when(
      success: (messages) => emit(ChatLoaded(messages)),
      failure: (failure) => emit(ChatError(failure: failure, message: failure.message)),
    );
  }

  Future<void> _onRefresh(RefreshChatEvent event, Emitter<ChatState> emit) async {
    final result = await _getMessagesUseCase(event.groupId);
    result.when(
      success: (messages) => emit(ChatLoaded(messages)),
      failure: (_) {},
    );
  }

  Future<void> _onSend(SendChatMessageEvent event, Emitter<ChatState> emit) async {
    final currentMessages = state is ChatLoaded ? (state as ChatLoaded).messages : <ChatMessage>[];
    emit(ChatLoaded(currentMessages, isSending: true));
    
    final result = await _sendMessageUseCase(
      event.groupId,
      event.text,
      attachmentUrl: event.attachmentUrl,
    );

    result.when(
      success: (sent) => emit(ChatMessageSent([...currentMessages, sent])),
      failure: (failure) => emit(ChatError(failure: failure, message: failure.message)),
    );
  }
}
