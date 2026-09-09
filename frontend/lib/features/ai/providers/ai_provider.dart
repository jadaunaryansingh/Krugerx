import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/storage.dart';
import '../../../core/api_client.dart';
import '../models/ai_models.dart';

class AiState {
  final List<LocalChatSession> sessions;
  final LocalChatSession? activeSession;
  final List<LocalChatMessage> activeMessages;
  final bool isStreaming;
  final String? streamingText;

  const AiState({
    this.sessions = const [],
    this.activeSession,
    this.activeMessages = const [],
    this.isStreaming = false,
    this.streamingText,
  });

  AiState copyWith({
    List<LocalChatSession>? sessions,
    LocalChatSession? activeSession,
    List<LocalChatMessage>? activeMessages,
    bool? isStreaming,
    String? streamingText,
  }) {
    return AiState(
      sessions: sessions ?? this.sessions,
      activeSession: activeSession ?? this.activeSession,
      activeMessages: activeMessages ?? this.activeMessages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
    );
  }
}

class AiNotifier extends Notifier<AiState> {
  @override
  AiState build() {
    _loadSessions();
    return const AiState();
  }

  Future<void> _loadSessions() async {
    final sessions = await Storage.db.localChatSessions.where().sortByUpdatedAtDesc().findAll();
    state = state.copyWith(sessions: sessions);
  }

  Future<void> createSession(String provider, String model) async {
    final session = LocalChatSession()
      ..title = 'New Chat'
      ..provider = provider
      ..model = model
      ..updatedAt = DateTime.now();

    await Storage.db.writeTxn(() async {
      await Storage.db.localChatSessions.put(session);
    });

    state = state.copyWith(activeSession: session, activeMessages: []);
    await _loadSessions();
  }

  Future<void> loadSession(int sessionId) async {
    final session = await Storage.db.localChatSessions.get(sessionId);
    if (session == null) return;
    final msgs = await Storage.db.localChatMessages
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByCreatedAt()
        .findAll();
    state = state.copyWith(activeSession: session, activeMessages: msgs);
  }

  Future<void> sendMessage(String text) async {
    if (state.activeSession == null) return;

    final userMsg = LocalChatMessage()
      ..sessionId = state.activeSession!.id
      ..role = 'user'
      ..content = text
      ..createdAt = DateTime.now();

    await Storage.db.writeTxn(() async {
      await Storage.db.localChatMessages.put(userMsg);
    });

    final currentMessages = [...state.activeMessages, userMsg];
    state = state.copyWith(activeMessages: currentMessages, isStreaming: true, streamingText: '');

    try {
      final response = await ApiClient.client.post(
        '/ai/chat',
        data: {
          'message': text,
          'provider': state.activeSession!.provider,
          'model': state.activeSession!.model,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String accumulated = '';

      await for (final chunk in stream) {
        for (final line in utf8.decode(chunk).split('\n')) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6);
            if (dataStr == '[DONE]') break;
            try {
              final json = jsonDecode(dataStr);
              if (json['content'] != null) {
                accumulated += json['content'] as String;
                state = state.copyWith(streamingText: accumulated);
              }
            } catch (e) {
              debugPrint('[AiNotifier] SSE parsing error: $e');
            }
          }
        }
      }

      if (accumulated.isNotEmpty) {
        final aiMsg = LocalChatMessage()
          ..sessionId = state.activeSession!.id
          ..role = 'assistant'
          ..content = accumulated
          ..createdAt = DateTime.now();
        await Storage.db.writeTxn(() async {
          await Storage.db.localChatMessages.put(aiMsg);
        });
        state = state.copyWith(
          activeMessages: [...currentMessages, aiMsg],
          isStreaming: false,
          streamingText: null,
        );
      } else {
        state = state.copyWith(isStreaming: false, streamingText: null);
      }
    } catch (e) {
      state = state.copyWith(isStreaming: false, streamingText: 'Error connecting to AI service.');
    }
  }
}

final aiProvider = NotifierProvider<AiNotifier, AiState>(AiNotifier.new);
