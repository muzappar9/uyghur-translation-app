import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translation_provider.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_input.dart';
import '../widgets/translation_result.dart';

/// 翻译屏幕
class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  late TextEditingController _inputController;
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'ug';
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationResult = ref.watch(
      translateProvider(
        (
          text: _inputController.text,
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
        ),
      ),
    );

    final history = ref.watch(
      translationHistoryProvider(
        (
          userId: null,
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
          limit: 50
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('翻译'),
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 打开菜单
            },
          ),
        ],
      ),
      body: _showHistory
          ? _buildHistoryView(history)
          : _buildTranslationView(translationResult),
    );
  }

  Widget _buildTranslationView(AsyncValue<dynamic> translationResult) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 语言选择器
            LanguageSelector(
              sourceLanguage: _sourceLanguage,
              targetLanguage: _targetLanguage,
              onSourceLanguageChanged: (language) {
                setState(() {
                  _sourceLanguage = language;
                });
              },
              onTargetLanguageChanged: (language) {
                setState(() {
                  _targetLanguage = language;
                });
              },
            ),
            const SizedBox(height: 24),

            // 输入框
            TranslationInput(
              controller: _inputController,
              onChanged: (text) {
                setState(() {});
              },
              onClear: () {
                _inputController.clear();
                setState(() {});
              },
            ),
            const SizedBox(height: 24),

            // 翻译结果
            TranslationResult(
              translationResult: translationResult,
              onCopy: (text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryView(AsyncValue<dynamic> history) {
    return history.when(
      data: (historyList) {
        if (historyList.isEmpty) {
          return const Center(
            child: Text('还没有翻译历史'),
          );
        }
        return ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            return ListTile(
              title: Text(item.sourceText),
              subtitle: Text(item.translatedText),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // 删除历史记录
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('加载失败: $error'),
      ),
    );
  }
}
