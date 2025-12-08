import '../../domain/entities/conversation.dart';

abstract class ConversationRepository {
  Future<ConversationSession> createSession(
      String sourceLang, String targetLang);
  Future<ConversationSession?> getSession(String sessionId);
  Future<List<ConversationSession>> getAllSessions();
  Future<void> addMessage(String sessionId, ConversationMessage message);
  Future<void> deleteSession(String sessionId);
  Future<void> clearAllSessions();
  Stream<ConversationSession> watchSession(String sessionId);
}

class ConversationRepositoryImpl implements ConversationRepository {
  // Mock 数据库
  final Map<String, ConversationSession> _sessions = {};
  int _sessionCounter = 0;
  int _messageCounter = 0; // 用于追踪消息总数

  /// 获取消息总数
  int get messageCount => _messageCounter;

  @override
  Future<ConversationSession> createSession(
      String sourceLang, String targetLang) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final sessionId = 'session_${++_sessionCounter}';
    final session = ConversationSession(
      id: sessionId,
      sourceLang: sourceLang,
      targetLang: targetLang,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _sessions[sessionId] = session;
    return session;
  }

  @override
  Future<ConversationSession?> getSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions[sessionId];
  }

  @override
  Future<List<ConversationSession>> getAllSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sessions.values.toList();
  }

  @override
  Future<void> addMessage(String sessionId, ConversationMessage message) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final session = _sessions[sessionId];
    if (session != null) {
      final updatedMessages = [...session.messages, message];
      _messageCounter = updatedMessages.length; // 追踪总消息数
      _sessions[sessionId] = session.copyWith(
        messages: updatedMessages,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessions.remove(sessionId);
  }

  @override
  Future<void> clearAllSessions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessions.clear();
  }

  @override
  Stream<ConversationSession> watchSession(String sessionId) {
    // Mock Stream implementation - 监听会话变化
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      return _sessions[sessionId];
    }).where((session) => session != null).cast<ConversationSession>();
  }
}
