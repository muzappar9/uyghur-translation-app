"""
Step 7 错误处理集成指南

本文档说明如何在各个屏幕中正确集成 Step 7 的错误处理系统。

================================================================================
1. 导入必要的模块
================================================================================

import 'package:uyghur_translator/core/error/error_handler.dart';
import 'package:uyghur_translator/core/exceptions/app_exceptions.dart';
import 'package:uyghur_translator/shared/widgets/error_dialog.dart';
import 'package:uyghur_translator/shared/widgets/loading_indicator.dart';
import 'package:uyghur_translator/shared/widgets/empty_state.dart';

================================================================================
2. 错误处理模式
================================================================================

【旧模式 - 不推荐】
```dart
try {
  final result = await someOperation();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```

【新模式 - 推荐】
```dart
try {
  final result = await someOperation();
} catch (e, stackTrace) {
  if (!mounted) return;
  final errorMessage = ErrorHandler().handleException(e, stackTrace);
  await ErrorDialog.show(
    context,
    title: '操作失败',
    message: errorMessage,
    onRetry: () => _retryOperation(), // 可选重试回调
  );
}
```

================================================================================
3. 不同类型异常的处理
================================================================================

【网络异常】
```dart
try {
  final result = await apiClient.translate(...);
} catch (e) {
  if (e is NetworkException) {
    // 显示网络错误对话框
    ErrorDialog.show(context, 
      title: '网络连接失败',
      message: e.message,
    );
  }
}
```

【验证异常】
```dart
try {
  if (inputText.isEmpty) {
    throw ValidationException('input', '文本不能为空');
  }
} catch (e) {
  if (e is ValidationException) {
    ErrorDialog.show(context,
      title: '输入错误',
      message: '${e.field}: ${e.message}',
    );
  }
}
```

【权限异常】
```dart
try {
  final permission = await Permission.camera.request();
  if (!permission.isGranted) {
    throw AuthException('相机权限被拒绝');
  }
} catch (e) {
  if (e is AuthException) {
    ErrorDialog.show(context,
      title: '权限错误',
      message: e.message,
    );
  }
}
```

================================================================================
4. 加载状态处理
================================================================================

【显示加载中】
```dart
// 全屏加载
LoadingIndicator.fullScreen(message: '正在翻译...')

// 普通加载
LoadingIndicator(message: '处理中...')

// 简洁加载（仅图标）
LoadingIndicator.compact()
```

【集成到屏幕】
```dart
@override
Widget build(BuildContext context) {
  return Center(
    child: _isLoading 
      ? LoadingIndicator(message: '加载中...')
      : _buildContent(),
  );
}
```

================================================================================
5. 空状态处理
================================================================================

【显示空状态】
```dart
if (items.isEmpty) {
  return EmptyStateWidget.history(
    onAction: () => _navigateToNewTranslation(),
  );
}
```

【不同场景的预设】
```dart
// 历史记录为空
EmptyStateWidget.history(onAction: onAction)

// 搜索结果为空
EmptyStateWidget.searchResults(query: 'keyword', onRetry: onRetry)

// 收藏列表为空
EmptyStateWidget.favorites(onAction: onAction)

// 自定义
EmptyStateWidget.custom(
  title: '自定义标题',
  subtitle: '自定义描述',
)
```

================================================================================
6. 实际集成例子 - TranslateResultScreen
================================================================================

【修改前】
```dart
Future<void> _speak(String text, String language) async {
  try {
    await _flutterTts.speak(text);
  } catch (e) {
    _showErrorSnackBar(context, 'TTS 错误: ${e.toString()}');
  }
}
```

【修改后】
```dart
Future<void> _speak(String text, String language) async {
  try {
    await _flutterTts.speak(text);
  } catch (e, stackTrace) {
    if (!mounted) return;
    final errorMessage = ErrorHandler().handleException(e, stackTrace);
    await ErrorDialog.show(
      context,
      title: '朗读失败',
      message: errorMessage,
      onRetry: () => _speak(text, language),
    );
  }
}
```

================================================================================
7. 屏幕集成清单
================================================================================

[ ] home_screen.dart - 翻译输入和基本逻辑
[ ] translate_result_screen.dart - 结果展示
[ ] voice_input_screen.dart - 语音输入
[ ] camera_screen.dart - 相机和 OCR
[ ] ocr_result_screen.dart - OCR 结果
[ ] history_screen.dart - 历史列表（含空状态）
[ ] dictionary_home_screen.dart - 字典列表（含空状态）
[ ] dictionary_detail_screen.dart - 字典详情
[ ] conversation_screen.dart - 对话界面
[ ] settings_screen.dart - 设置页面

================================================================================
8. 测试用例
================================================================================

【测试网络错误】
- 关闭网络连接，尝试翻译
- 应该显示错误对话框，包含重试按钮

【测试权限拒绝】
- 拒绝相机权限，进入 CameraScreen
- 应该显示权限错误对话框

【测试空状态】
- 首次使用，查看历史记录
- 应该显示"暂无翻译历史"提示

【测试加载状态】
- 执行长耗时操作
- 应该显示加载指示器

================================================================================
9. 关键检查点
================================================================================

✓ 所有 try-catch 都使用 ErrorHandler 处理异常
✓ 所有异常消息都通过 ErrorDialog 或 showSnackBar 显示
✓ 列表页面都有空状态处理
✓ 长耗时操作都有加载指示器
✓ 所有按钮都有禁用状态（加载时）
✓ 使用自定义异常类而不是通用 Exception
✓ 所有异常都包含 stackTrace 用于日志记录

================================================================================
10. 性能注意事项
================================================================================

【避免过度错误处理】
- 不是每个小操作都需要错误对话框
- 简单操作可以用 SnackBar
- 关键操作（翻译、上传）才需要对话框

【避免错误处理嵌套过深】
- 尽量在最上层捕获异常
- 不要在每个方法都 try-catch
- 让异常自然传播到 UI 层

【日志记录】
- 所有异常都被记录（ErrorHandler 负责）
- 不要在 catch 块中重复记录
- 使用 stackTrace 进行调试

================================================================================
最后确认：
- 这个 Step 7 的目标是：提供统一的、用户友好的、可恢复的错误处理
- 不是：创建最复杂的系统
- 关键是：在所有屏幕中 ACTUALLY USE 这些工具
================================================================================
"""
