import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../i18n/localizations.dart';
import '../core/animations/animations.dart';
import '../core/widgets/loading_states.dart';
import '../core/widgets/skeleton_screens.dart';
import '../core/error/enhanced_error_handler.dart';

/// TranslateResultScreen: 翻译结果页
/// 升级: Stage 19 添加动画效果
/// 升级: Stage 20 添加加载状态和错误处理
/// 源Card + 目标Card + 底部按钮
class TranslateResultScreen extends StatefulWidget {
  const TranslateResultScreen({super.key});

  @override
  State<TranslateResultScreen> createState() => _TranslateResultScreenState();
}

class _TranslateResultScreenState extends State<TranslateResultScreen>
    with TickerProviderStateMixin {
  bool _isFavorite = false;
  LoadingState _loadingState = LoadingState.loading;
  String _sourceText = '';
  String _targetText = '';
  String? _errorMessage;

  late AnimationController _resultController;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      vsync: this,
      duration: AppAnimationDuration.medium,
    );

    // 开始翻译
    _performTranslation();
  }

  Future<void> _performTranslation() async {
    setState(() {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
    });

    try {
      // 模拟加载翻译结果（实际应调用翻译服务）
      await Future.delayed(const Duration(milliseconds: 1200));

      // 模拟成功
      if (mounted) {
        setState(() {
          _loadingState = LoadingState.success;
          _sourceText = '示例源文本';
          _targetText = 'مىسال تېكىست';
        });
        _resultController.forward();
      }
    } catch (e) {
      if (mounted) {
        final appError = EnhancedAppError.fromException(e);
        setState(() {
          _loadingState = LoadingState.error;
          _errorMessage = appError.message;
        });
      }
    }
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(context, 'common.copied')),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // TODO: 分享功能
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: StatefulLoadingContainer(
                  state: _loadingState,
                  loadingWidget: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TranslationResultSkeleton(),
                  ),
                  errorWidget: InlineErrorWidget(
                    message: _errorMessage ?? '翻译失败',
                    onRetry: _performTranslation,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Source Card with Animation
                        TranslationResultAnimation(
                          show: _loadingState == LoadingState.success,
                          type: TranslationAnimationType.fadeSlide,
                          delay: const Duration(milliseconds: 100),
                          child: GlassCard(
                            blurSigma: 15,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      t(context, 'result.source.title'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.volume_up,
                                          size: 20, color: Colors.white70),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: t(context, 'result.action.read'),
                                    ),
                                    const SizedBox(width: 16),
                                    AnimatedCopyButton(
                                      onCopy: () =>
                                          _copyToClipboard(_sourceText),
                                      iconColor: Colors.white70,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 16),
                                    AnimatedFavoriteButton(
                                      isFavorite: _isFavorite,
                                      onChanged: (value) =>
                                          setState(() => _isFavorite = value),
                                      activeColor: Colors.amber,
                                      inactiveColor: Colors.white70,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AnimatedText(
                                  text: _sourceText.isEmpty
                                      ? 'TODO: Source Text'
                                      : _sourceText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Target Card with Animation
                        TranslationResultAnimation(
                          show: _loadingState == LoadingState.success,
                          type: TranslationAnimationType.fadeSlide,
                          delay: const Duration(milliseconds: 300),
                          child: GlassCard(
                            blurSigma: 15,
                            padding: const EdgeInsets.all(16),
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      t(context, 'result.target.title'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.volume_up,
                                          size: 20, color: Colors.white70),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 16),
                                    AnimatedCopyButton(
                                      onCopy: () =>
                                          _copyToClipboard(_targetText),
                                      iconColor: Colors.white70,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.share,
                                          size: 20, color: Colors.white70),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                AnimatedText(
                                  text: _targetText.isEmpty
                                      ? 'TODO: Target Text'
                                      : _targetText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                        text: t(context, 'result.button.new'),
                        icon: Icons.add,
                        onPressed: () => Navigator.pop(context),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'result.button.conversation'),
                        icon: Icons.chat,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/conversation'),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'result.button.dictionary'),
                        icon: Icons.book,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/dictionary'),
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
