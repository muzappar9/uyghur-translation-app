import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/conversation.dart';
import '../../data/repositories/conversation_repository.dart';

// 对话 Repository Provider
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl();
});

// 当前对话会话 (状态)
final currentConversationProvider =
    StateProvider<ConversationSession?>((ref) => null);

// 创建新对话会话
final createConversationProvider =
    FutureProvider.family<ConversationSession, (String, String)>(
        (ref, args) async {
  final (sourceLang, targetLang) = args;
  final repo = ref.watch(conversationRepositoryProvider);
  final session = await repo.createSession(sourceLang, targetLang);
  ref.read(currentConversationProvider.notifier).state = session;
  return session;
});

// 获取对话会话
final getConversationProvider =
    FutureProvider.family<ConversationSession?, String>(
  (ref, sessionId) async {
    final repo = ref.watch(conversationRepositoryProvider);
    final session = await repo.getSession(sessionId);
    if (session != null) {
      ref.read(currentConversationProvider.notifier).state = session;
    }
    return session;
  },
);

// 监听对话会话变化
final watchConversationProvider =
    StreamProvider.family<ConversationSession, String>(
  (ref, sessionId) {
    final repo = ref.watch(conversationRepositoryProvider);
    return repo.watchSession(sessionId);
  },
);

// 获取所有对话会话
final allConversationsProvider =
    FutureProvider<List<ConversationSession>>((ref) async {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.getAllSessions();
});

// 发送消息 (action)
final sendMessageProvider =
    FutureProvider.family<void, (String, ConversationMessage)>(
  (ref, args) async {
    final (sessionId, message) = args;
    final repo = ref.watch(conversationRepositoryProvider);
    await repo.addMessage(sessionId, message);

    // 刷新当前会话
    final session = await repo.getSession(sessionId);
    if (session != null) {
      ref.read(currentConversationProvider.notifier).state = session;
    }
  },
);

// 删除对话会话
final deleteConversationProvider = FutureProvider.family<void, String>(
  (ref, sessionId) async {
    final repo = ref.watch(conversationRepositoryProvider);
    await repo.deleteSession(sessionId);

    // 清空当前会话
    final current = ref.read(currentConversationProvider);
    if (current?.id == sessionId) {
      ref.read(currentConversationProvider.notifier).state = null;
    }
  },
);
