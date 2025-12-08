import 'package:flutter/material.dart';

/// 语言选择器组件
class LanguageSelector extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final Function(String) onSourceLanguageChanged;
  final Function(String) onTargetLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSourceLanguageChanged,
    required this.onTargetLanguageChanged,
  });

  static const Map<String, String> _languages = {
    'auto': '自动检测',
    'zh': '中文',
    'ug': '维吾尔语',
    'en': '英语',
    'ar': '阿拉伯语',
    'ru': '俄语',
    'tr': '土耳其语',
    'fr': '法语',
    'de': '德语',
    'ja': '日语',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '源语言',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: sourceLanguage,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: _languages.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(entry.value),
                              ),
                            );
                          }).toList(),
                          onChanged: (language) {
                            if (language != null) {
                              onSourceLanguageChanged(language);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 交换按钮
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.swap_horiz,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      onSourceLanguageChanged(targetLanguage);
                      onTargetLanguageChanged(sourceLanguage);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '目标语言',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: targetLanguage,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: _languages.entries
                              .where((entry) => entry.key != 'auto')
                              .map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(entry.value),
                              ),
                            );
                          }).toList(),
                          onChanged: (language) {
                            if (language != null) {
                              onTargetLanguageChanged(language);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
