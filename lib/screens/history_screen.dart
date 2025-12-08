import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../i18n/localizations.dart';
import '../core/widgets/loading_states.dart';
import '../core/widgets/skeleton_screens.dart';
import '../core/animations/animations.dart';
import '../widgets/responsive_layout.dart';

/// 历史记录数据模型
class HistoryItem {
  final String id;
  final String original;
  final String translated;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  bool isFavorite;

  HistoryItem({
    required this.id,
    required this.original,
    required this.translated,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isFavorite = false,
  });
}

/// HistoryScreen: 历史记录页
/// 升级: Stage 20 添加加载状态和骨架屏
/// 搜索框 + ListView + RL反馈钩子
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 加载状态
  LoadingState _loadingState = LoadingState.loading;
  String? _errorMessage;

  // 示例历史数据
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      original: '你好',
      translated: 'سالام',
      sourceLanguage: 'zh',
      targetLanguage: 'ug',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isFavorite: true,
    ),
    HistoryItem(
      id: '2',
      original: '谢谢',
      translated: 'رەھمەت',
      sourceLanguage: 'zh',
      targetLanguage: 'ug',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isFavorite: false,
    ),
    HistoryItem(
      id: '3',
      original: '早上好',
      translated: 'خەيرلىك تاڭ',
      sourceLanguage: 'zh',
      targetLanguage: 'ug',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isFavorite: true,
    ),
    HistoryItem(
      id: '4',
      original: '再见',
      translated: 'خەير خوش',
      sourceLanguage: 'zh',
      targetLanguage: 'ug',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isFavorite: false,
    ),
    HistoryItem(
      id: '5',
      original: '我爱你',
      translated: 'مەن سىزنى ياخشى كۆرىمەن',
      sourceLanguage: 'zh',
      targetLanguage: 'ug',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isFavorite: true,
    ),
  ];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loadingState = LoadingState.loading;
      _errorMessage = null;
    });

    try {
      // 模拟加载延迟
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _loadingState = LoadingState.success;
      });
    } catch (e) {
      setState(() {
        _loadingState = LoadingState.error;
        _errorMessage = '加载历史记录失败';
      });
    }
  }

  List<HistoryItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _historyItems;
    final query = _searchQuery.toLowerCase();
    return _historyItems
        .where((item) =>
            item.original.toLowerCase().contains(query) ||
            item.translated.toLowerCase().contains(query))
        .toList();
  }

  void _exportRLFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(context, 'history.rl.exported')),
        backgroundColor: const Color(0xFFFF7F50),
      ),
    );
  }

  void _submitCorrection(
      BuildContext context, String translationId, String correctedText) {
    // RL反馈校正数据
    debugPrint('RL Correction for $translationId: $correctedText');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('校正已提交'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要清空所有历史记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _historyItems.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
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
                      onPressed: _clearHistory,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // History ListView with Loading State
              Expanded(
                child: ResponsiveContainer(
                  child: StatefulLoadingContainer(
                    state: _loadingState,
                    loadingWidget: const HistoryListSkeleton(itemCount: 5),
                    errorWidget: InlineErrorWidget(
                      message: _errorMessage ?? '加载失败',
                      onRetry: _loadHistory,
                    ),
                    child: _filteredItems.isEmpty
                        ? EmptyStateWidget.noHistory(
                            onStartTranslation: () => Navigator.pop(context),
                          )
                        : ResponsiveBuilder(
                            builder: (context, deviceType, orientation) {
                              // 平板/桌面使用网格，手机使用列表
                              if (deviceType != DeviceType.mobile) {
                                return ResponsiveGrid(
                                  columns: deviceType == DeviceType.tablet ? 2 : 3,
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: _filteredItems.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return StaggeredListItem(
                                      index: index,
                                      child: _HistoryItem(
                                        translationId: item.id,
                                        original: item.original,
                                        translated: item.translated,
                                        onTap: () {},
                                        onFavorite: () {
                                          setState(() {
                                            item.isFavorite = !item.isFavorite;
                                          });
                                        },
                                        onRead: () {},
                                        onCopy: () {},
                                        onCorrect: (corrected) => _submitCorrection(
                                          context,
                                          item.id,
                                          corrected,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                              // 手机使用列表
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.getPadding(context),
                                ),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index];
                                  return StaggeredListItem(
                                    index: index,
                                    child: _HistoryItem(
                                      translationId: item.id,
                                      original: item.original,
                                      translated: item.translated,
                                      onTap: () {},
                                      onFavorite: () {
                                        setState(() {
                                          item.isFavorite = !item.isFavorite;
                                        });
                                      },
                                      onRead: () {},
                                      onCopy: () {},
                                      onCorrect: (corrected) => _submitCorrection(
                                        context,
                                        item.id,
                                        corrected,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
                      color:
                          _isEditing ? const Color(0xFFFF7F50) : Colors.white60,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: _isEditing
                        ? 'Submit Correction (RL)'
                        : 'Correct Translation',
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onFavorite,
                    icon: const Icon(Icons.star_border,
                        size: 20, color: Colors.white60),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onRead,
                    icon: const Icon(Icons.volume_up,
                        size: 20, color: Colors.white60),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: widget.onCopy,
                    icon:
                        const Icon(Icons.copy, size: 20, color: Colors.white60),
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
