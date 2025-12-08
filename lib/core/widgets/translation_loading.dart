import 'package:flutter/material.dart';
import '../animations/animations.dart';

/// ============================================
/// Stage 20: 翻译专用加载组件
/// ============================================

/// 翻译加载阶段
enum TranslationLoadingPhase {
  preparing, // 准备中
  sending, // 发送请求
  translating, // 翻译中
  processing, // 处理结果
  complete, // 完成
}

/// 带阶段的翻译加载指示器
class TranslationLoadingIndicator extends StatefulWidget {
  final TranslationLoadingPhase phase;
  final String? customMessage;
  final Color? primaryColor;

  const TranslationLoadingIndicator({
    super.key,
    this.phase = TranslationLoadingPhase.translating,
    this.customMessage,
    this.primaryColor,
  });

  @override
  State<TranslationLoadingIndicator> createState() =>
      _TranslationLoadingIndicatorState();
}

class _TranslationLoadingIndicatorState
    extends State<TranslationLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _phaseMessage {
    if (widget.customMessage != null) return widget.customMessage!;

    switch (widget.phase) {
      case TranslationLoadingPhase.preparing:
        return '准备翻译...';
      case TranslationLoadingPhase.sending:
        return '连接翻译服务...';
      case TranslationLoadingPhase.translating:
        return '正在翻译...';
      case TranslationLoadingPhase.processing:
        return '处理结果...';
      case TranslationLoadingPhase.complete:
        return '完成!';
    }
  }

  IconData get _phaseIcon {
    switch (widget.phase) {
      case TranslationLoadingPhase.preparing:
        return Icons.edit_note;
      case TranslationLoadingPhase.sending:
        return Icons.cloud_upload_outlined;
      case TranslationLoadingPhase.translating:
        return Icons.translate;
      case TranslationLoadingPhase.processing:
        return Icons.auto_awesome;
      case TranslationLoadingPhase.complete:
        return Icons.check_circle;
    }
  }

  int get _phaseStep {
    return widget.phase.index + 1;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 动画图标
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _phaseIcon,
              size: 40,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 阶段文本
        Text(
          _phaseMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // 进度指示器
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: _phaseStep / 5,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),

        // 步骤指示
        Text(
          '步骤 $_phaseStep / 5',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

/// 打字机翻译显示效果
class TypewriterTranslationResult extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final VoidCallback? onComplete;

  const TypewriterTranslationResult({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 30),
    this.onComplete,
  });

  @override
  State<TypewriterTranslationResult> createState() =>
      _TypewriterTranslationResultState();
}

class _TypewriterTranslationResultState
    extends State<TypewriterTranslationResult> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterTranslationResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayedText = '';
      _currentIndex = 0;
      _startTyping();
    }
  }

  void _startTyping() {
    Future.delayed(widget.charDuration, () {
      if (!mounted) return;
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
        _startTyping();
      } else {
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: _displayedText),
          if (_currentIndex < widget.text.length)
            WidgetSpan(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 2,
                  height: (widget.style?.fontSize ?? 16) * 1.2,
                  margin: const EdgeInsets.only(left: 2),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      style: widget.style,
    );
  }
}

/// 翻译进行中的流式显示容器
class StreamingTranslationContainer extends StatelessWidget {
  final String? sourceText;
  final String? translatedText;
  final bool isTranslating;
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback? onCopy;
  final VoidCallback? onSpeak;

  const StreamingTranslationContainer({
    super.key,
    this.sourceText,
    this.translatedText,
    this.isTranslating = false,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.onCopy,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 原文区域
        if (sourceText != null && sourceText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getLanguageName(sourceLanguage),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),
                    const Spacer(),
                    if (onSpeak != null)
                      IconButton(
                        onPressed: onSpeak,
                        icon: const Icon(Icons.volume_up, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: colorScheme.outline,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sourceText!,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // 翻译结果区域
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getLanguageName(targetLanguage),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  if (!isTranslating && onCopy != null)
                    IconButton(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: colorScheme.outline,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (isTranslating)
                const TypingIndicator()
              else if (translatedText != null && translatedText!.isNotEmpty)
                TypewriterTranslationResult(
                  text: translatedText!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                )
              else
                Text(
                  '等待翻译...',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'zh':
        return '中文';
      case 'ug':
        return '维吾尔语';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }
}

/// 翻译历史加载条目
class TranslationHistoryLoadingItem extends StatelessWidget {
  const TranslationHistoryLoadingItem({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ShimmerBox(
                width: 60,
                height: 14,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              _ShimmerBox(
                width: 16,
                height: 14,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              _ShimmerBox(
                width: 60,
                height: 14,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              const Spacer(),
              _ShimmerBox(
                width: 80,
                height: 12,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ShimmerBox(
            width: double.infinity,
            height: 18,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          _ShimmerBox(
            width: 180,
            height: 16,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
