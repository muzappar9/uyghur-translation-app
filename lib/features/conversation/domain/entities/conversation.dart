/// 对话消息数据模型
class ConversationMessage {
  final String id;
  final String originalText; // 原始语言文本
  final String translatedText; // 翻译后文本
  final String sourceLang; // 原始语言
  final String targetLang; // 目标语言
  final MessageType type; // 消息类型
  final DateTime timestamp;
  final bool isOwn; // 是否为用户发送

  const ConversationMessage({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.type,
    required this.timestamp,
    required this.isOwn,
  });

  ConversationMessage copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    MessageType? type,
    DateTime? timestamp,
    bool? isOwn,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isOwn: isOwn ?? this.isOwn,
    );
  }
}

enum MessageType {
  text, // 文本消息
  voice, // 语音消息
  image, // 图片消息
}

/// 对话会话
class ConversationSession {
  final String id;
  final String sourceLang; // 会话源语言
  final String targetLang; // 会话目标语言
  final List<ConversationMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationSession({
    required this.id,
    required this.sourceLang,
    required this.targetLang,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  ConversationSession copyWith({
    String? id,
    String? sourceLang,
    String? targetLang,
    List<ConversationMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get messageCount => messages.length;
}
