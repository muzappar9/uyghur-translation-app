import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/chat_bubble.dart';
import '../i18n/localizations.dart';

/// ConversationScreen: 对话翻译页
/// AppBar + ListView气泡 + 底部双麦克风按钮
class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF8E53),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t(context, 'conversation.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Chat ListView
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // TODO: 空ListView占位
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          t(context, 'conversation.empty'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // 示例气泡（可删除）
                    const ChatBubble(
                      originalText: '', // TODO
                      translatedText: '', // TODO
                      isLeft: true,
                    ),
                    const SizedBox(height: 12),
                    const ChatBubble(
                      originalText: '', // TODO
                      translatedText: '', // TODO
                      isLeft: false,
                    ),
                  ],
                ),
              ),

              // Bottom Dual Mic Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'conversation.mic.left'),
                        icon: Icons.mic,
                        onPressed: () {
                          // TODO: 左侧语言录音
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'conversation.mic.right'),
                        icon: Icons.mic,
                        onPressed: () {
                          // TODO: 右侧语言录音
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
