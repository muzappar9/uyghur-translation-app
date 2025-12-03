import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../i18n/localizations.dart';

/// OcrResultScreen: OCR结果页
/// 标题 + 图片占位 + 可编辑TextField + 编辑/翻译按钮
class OcrResultScreen extends StatefulWidget {
  const OcrResultScreen({super.key});

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      t(context, 'ocr_result.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Image Preview Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  blurSigma: 10,
                  padding: EdgeInsets.zero,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // OCR Text Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    blurSigma: 15,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      enabled: _isEditing,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: t(context, 'ocr_result.placeholder'),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black38,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'ocr_result.button.edit'),
                        icon: _isEditing ? Icons.check : Icons.edit,
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'ocr_result.button.translate'),
                        icon: Icons.translate,
                        onPressed: () {
                          Navigator.pushNamed(context, '/translate_result');
                        },
                        textColor: Colors.white,
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
