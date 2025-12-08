/// 数据导入页面
///
/// 提供数据导入界面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/import/import.dart';
import '../widgets/glass_card.dart';

/// 数据导入页面
class ImportDataScreen extends ConsumerStatefulWidget {
  const ImportDataScreen({super.key});

  @override
  ConsumerState<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends ConsumerState<ImportDataScreen> {
  final TextEditingController _contentController = TextEditingController();
  ImportType _selectedType = ImportType.translations;
  bool _overwriteExisting = false;
  bool _skipDuplicates = true;
  String? _defaultSourceLang;
  String? _defaultTargetLang;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _selectFile() async {
    // 在实际应用中，这里会使用 file_picker 包选择文件
    // 现在使用一个模拟对话框
    final content = await showDialog<String>(
      context: context,
      builder: (context) => _FileInputDialog(),
    );

    if (content != null && content.isNotEmpty) {
      _contentController.text = content;
      await ref.read(importStateProvider.notifier).setFileContent(
            'imported_data.json',
            content,
          );
    }
  }

  void _startImport() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择或粘贴要导入的数据')),
      );
      return;
    }

    final notifier = ref.read(importStateProvider.notifier);

    // 设置选项
    notifier.setOptions(ImportOptions(
      overwriteExisting: _overwriteExisting,
      skipDuplicates: _skipDuplicates,
      defaultSourceLang: _defaultSourceLang,
      defaultTargetLang: _defaultTargetLang,
    ));

    // 开始导入
    await notifier.startImport(type: _selectedType);
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importStateProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF11998E),
              Color(0xFF38EF7D),
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
                    const Text(
                      '导入数据',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (importState.status != ImportStatus.idle)
                      TextButton(
                        onPressed: () {
                          ref.read(importStateProvider.notifier).reset();
                          _contentController.clear();
                        },
                        child: const Text(
                          '重置',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 导入类型选择
                      const _SectionTitle(title: '导入类型'),
                      GlassCard(
                        blurSigma: 10,
                        child: RadioGroup<ImportType>(
                          groupValue: _selectedType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                          child: Column(
                            children: ImportType.values.map((type) {
                              return ListTile(
                                leading: Radio<ImportType>(value: type),
                                title: Text(
                                  _getTypeName(type),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () => setState(() => _selectedType = type),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 文件选择
                      const _SectionTitle(title: '选择文件'),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.file_upload,
                                  color: Colors.white),
                              title: const Text(
                                '选择文件',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                importState.filename ?? '支持 JSON, CSV, TXT 格式',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              trailing: ElevatedButton(
                                onPressed: _selectFile,
                                child: const Text('选择'),
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: _contentController,
                                maxLines: 5,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  hintText: '或直接粘贴数据内容...',
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white24),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                ),
                                onChanged: (value) async {
                                  if (value.isNotEmpty) {
                                    await ref
                                        .read(importStateProvider.notifier)
                                        .setFileContent(
                                          'pasted_data.json',
                                          value,
                                        );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 预览
                      if (importState.preview != null) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle(title: '预览'),
                        GlassCard(
                          blurSigma: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.preview,
                                        color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text(
                                      '共 ${importState.preview!.totalCount} 条记录',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        importState.format?.displayName ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 1),
                              ...importState.preview!.previewEntries
                                  .take(3)
                                  .map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.sourceText,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '→ ${entry.targetText}',
                                        style: const TextStyle(
                                            color: Colors.white60),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (importState.preview!.totalCount > 3)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    '还有 ${importState.preview!.totalCount - 3} 条...',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // 导入选项
                      const _SectionTitle(title: '导入选项'),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text(
                                '覆盖已存在的记录',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                '如果记录已存在，将其更新',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                              value: _overwriteExisting,
                              activeTrackColor: Colors.white.withAlpha(179),
                              onChanged: (value) {
                                setState(() => _overwriteExisting = value);
                              },
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            SwitchListTile(
                              title: const Text(
                                '跳过重复项',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                '自动跳过重复的记录',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                              value: _skipDuplicates,
                              activeTrackColor: Colors.white.withAlpha(179),
                              onChanged: (value) {
                                setState(() => _skipDuplicates = value);
                              },
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            ListTile(
                              title: const Text(
                                '默认源语言',
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: DropdownButton<String?>(
                                value: _defaultSourceLang,
                                hint: const Text(
                                  '自动',
                                  style: TextStyle(color: Colors.white60),
                                ),
                                dropdownColor: Colors.black87,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                      value: null,
                                      child: Text('自动',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'zh',
                                      child: Text('中文',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'ug',
                                      child: Text('维吾尔文',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'en',
                                      child: Text('英文',
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                                onChanged: (value) {
                                  setState(() => _defaultSourceLang = value);
                                },
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            ListTile(
                              title: const Text(
                                '默认目标语言',
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: DropdownButton<String?>(
                                value: _defaultTargetLang,
                                hint: const Text(
                                  '自动',
                                  style: TextStyle(color: Colors.white60),
                                ),
                                dropdownColor: Colors.black87,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                      value: null,
                                      child: Text('自动',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'zh',
                                      child: Text('中文',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'ug',
                                      child: Text('维吾尔文',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  DropdownMenuItem(
                                      value: 'en',
                                      child: Text('英文',
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                                onChanged: (value) {
                                  setState(() => _defaultTargetLang = value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 导入进度
                      if (importState.status == ImportStatus.importing) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle(title: '导入进度'),
                        GlassCard(
                          blurSigma: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: importState.progressPercent,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  importState.progressMessage ?? '正在导入...',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  '${importState.progress} / ${importState.total}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // 导入结果
                      if (importState.result != null) ...[
                        const SizedBox(height: 24),
                        const _SectionTitle(title: '导入结果'),
                        GlassCard(
                          blurSigma: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      importState.result!.success
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: importState.result!.success
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      importState.result!.success
                                          ? '导入成功'
                                          : '导入失败',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _ResultRow('总计',
                                    '${importState.result!.totalCount} 条'),
                                _ResultRow('成功',
                                    '${importState.result!.importedCount} 条'),
                                if (importState.result!.skippedCount > 0)
                                  _ResultRow('跳过',
                                      '${importState.result!.skippedCount} 条'),
                                if (importState.result!.errorCount > 0)
                                  _ResultRow('错误',
                                      '${importState.result!.errorCount} 条'),
                                _ResultRow('耗时',
                                    '${importState.result!.duration.inMilliseconds}ms'),
                                if (importState.result!.errors.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    '错误详情:',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  ...importState.result!.errors
                                      .take(3)
                                      .map((e) {
                                    return Text(
                                      '• $e',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      // 错误提示
                      if (importState.hasError) ...[
                        const SizedBox(height: 24),
                        GlassCard(
                          blurSigma: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.error,
                                    color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    importState.error!,
                                    style: const TextStyle(
                                        color: Colors.redAccent),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white60),
                                  onPressed: () {
                                    ref
                                        .read(importStateProvider.notifier)
                                        .clearError();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // 导入按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              importState.isLoading ? null : _startImport,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF11998E),
                          ),
                          child: importState.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  '开始导入',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),
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

  String _getTypeName(ImportType type) {
    switch (type) {
      case ImportType.translations:
        return '翻译历史';
      case ImportType.dictionary:
        return '词典数据';
      case ImportType.favorites:
        return '收藏记录';
      case ImportType.settings:
        return '设置数据';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _FileInputDialog extends StatefulWidget {
  @override
  State<_FileInputDialog> createState() => _FileInputDialogState();
}

class _FileInputDialogState extends State<_FileInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('粘贴数据'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: '粘贴 JSON 或其他格式的数据...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
