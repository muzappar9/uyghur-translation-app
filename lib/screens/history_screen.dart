import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../i18n/localizations.dart';

/// HistoryScreen: 历史记录页
/// 搜索框 + ListView + RL反馈钩子
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _exportRLFeedback(BuildContext context) {
    // print('export RL feedback');
    // TODO: 实现RL反馈数据导出
    // 格式: { translationId, originalText, translatedText, userRating, correction, timestamp }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(context, 'history.rl.exported')),
        backgroundColor: const Color(0xFFFF7F50),
      ),
    );
  }

  void _submitCorrection(BuildContext context, String translationId, String correctedText) {
    // print('export RL feedback: correction for $translationId');
    // TODO: 发送校正数据到RL训练管道
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
                      t(context, 'history.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _exportRLFeedback(context),
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      tooltip: 'Export RL Feedback',
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 清空历史
                      },
                      child: Text(
                        t(context, 'history.action.clear_all'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  blurSigma: 15,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: 20,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: t(context, 'history.search.placeholder'),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // History ListView
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 0, // TODO: 历史数据
                  itemBuilder: (context, index) {
                    return _HistoryItem(
                      translationId: 'TODO_ID_$index',
                      original: 'TODO: Original Text',
                      translated: 'TODO: Translated Text',
                      onTap: () {},
                      onFavorite: () {},
                      onRead: () {},
                      onCopy: () {},
                      onCorrect: (corrected) => _submitCorrection(
                        context,
                        'TODO_ID_$index',
                        corrected,
                      ),
                    );
                  },
                ),
              ),

              // Empty State
              if (true) // TODO: 替换为实际判断
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t(context, 'history.empty'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
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
    );
  }
}

class _HistoryItem extends StatefulWidget {
  final String translationId;
  final String original;
  final String translated;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onRead;
  final VoidCallback? onCopy;
  final Function(String)? onCorrect; // RL校正回调

  const _HistoryItem({
    required this.translationId,
    required this.original,
    required this.translated,
    this.onTap,
    this.onFavorite,
    this.onRead,
    this.onCopy,
    this.onCorrect,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  bool _isEditing = false;
  late TextEditingController _correctionController;

  @override
  void initState() {
    super.initState();
    _correctionController = TextEditingController(text: widget.translated);
  }

  @override
  void dispose() {
    _correctionController.dispose();
    super.dispose();
  }

  void _submitCorrection() {
    if (_correctionController.text != widget.translated) {
      // print('export RL feedback: user corrected translation');
      widget.onCorrect?.call(_correctionController.text);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        blurSigma: 10,
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.original,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              _isEditing
                  ? TextField(
                      controller: _correctionController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      onSubmitted: (_) => _submitCorrection(),
                    )
                  : Text(
                      widget.translated,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_isEditing) {
                        _submitCorrection();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    icon: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      size: 20,
                      color: _isEditing ? const Color(0xFFFF7F50) : Colors.white60,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: _isEditing ? 'Submit Correction (RL)' : 'Correct Translation',
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onFavorite,
                    icon: const Icon(Icons.star_border, size: 20, color: Colors.white60),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onRead,
                    icon: const Icon(Icons.volume_up, size: 20, color: Colors.white60),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onCopy,
                    icon: const Icon(Icons.copy, size: 20, color: Colors.white60),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
