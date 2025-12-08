import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/ocr_provider.dart';
import '../widgets/ocr_result_card.dart';

/// OCR 识别屏幕
class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({super.key});

  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  File? _selectedImage;
  bool _showHistory = false;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ocrResult = _selectedImage != null
        ? ref.watch(recognizeTextProvider(_selectedImage!))
        : null;

    final history = ref.watch(ocrHistoryProvider((userId: null, limit: 50)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('文字识别'),
        elevation: 0,
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
        ],
      ),
      body:
          _showHistory ? _buildHistoryView(history) : _buildOcrView(ocrResult),
    );
  }

  Widget _buildOcrView(AsyncValue<dynamic>? ocrResult) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 图片预览或占位符
            if (_selectedImage != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  ),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('选择'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // OCR 结果
            if (ocrResult != null)
              OcrResultCard(
                ocrResult: ocrResult,
                onCopy: (text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已复制到剪贴板')),
                  );
                },
                onTranslate: () {
                  // 导航到翻译屏幕，使用识别的文本
                },
                onEdit: () {
                  // 打开编辑对话框
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
            child: Text('还没有识别历史'),
          );
        }
        return ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.red,
                ),
                title: Text(item.recognizedText),
                subtitle: Text(item.detectedLanguage),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('编辑'),
                      onTap: () {
                        // 编辑识别的文本
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('删除'),
                      onTap: () {
                        // 删除历史记录
                      },
                    ),
                  ],
                ),
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
