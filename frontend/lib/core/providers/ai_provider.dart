import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai.dart';
import 'auth_provider.dart';

final aiProvider = NotifierProvider<AiNotifier, List<AiMessageModel>>(AiNotifier.new);

class AiNotifier extends Notifier<List<AiMessageModel>> {
  @override
  List<AiMessageModel> build() => const [];

  Future<void> sendMessage(String text) async {
    // Optimistic UI
    final userMsg = AiMessageModel(
      id: DateTime.now().toString(),
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    state = [...state, userMsg];

    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.post('/ai/chat', data: {
        'message': text,
        'stream': false,
      });

      if (res.data['success'] == true) {
        final replyData = res.data['data']['response'];
        final aiMsg = AiMessageModel.fromJson(replyData);
        state = [...state, aiMsg];
      }
    } catch (_) {
      final errorMsg = AiMessageModel(
        id: DateTime.now().toString(),
        role: 'system',
        content: 'Failed to get response.',
        createdAt: DateTime.now(),
      );
      state = [...state, errorMsg];
    }
  }

  void clearChat() {
    state = const [];
  }
}
