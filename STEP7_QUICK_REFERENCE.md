# Step 7 快速参考指南

## 🚀 快速开始

### 基本错误处理

```dart
// 导入
import 'package:uyghur_translator/core/error/error_handler.dart' as app_error_handler;
import 'package:uyghur_translator/core/exceptions/app_exceptions.dart';
import 'package:uyghur_translator/shared/widgets/error_dialog.dart';

// 同步操作 - 显示 SnackBar
try {
  someOperation();
} catch (e, stackTrace) {
  final msg = app_error_handler.ErrorHandler().handleException(e, stackTrace);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $msg')),
  );
}

// 异步操作 - 显示对话框 + 重试
try {
  await asyncOperation();
} catch (e, stackTrace) {
  final msg = app_error_handler.ErrorHandler().handleException(e, stackTrace);
  await ErrorDialog.show(
    context,
    title: 'Operation Failed',
    message: msg,
    onRetry: asyncOperation,
  );
}
```

## 📋 异常类型快查

| 异常 | 构造器 | 示例 |
|------|--------|------|
| `ValidationException` | `(field, message)` | `ValidationException('email', 'Invalid format')` |
| `AuthException` | `(message)` | `AuthException('Permission denied')` |
| `NetworkException` | `(message)` | `NetworkException('No internet')` |
| `ApiException` | `(statusCode, message)` | `ApiException(404, 'Not found')` |
| `TimeoutException` | `(message)` | `TimeoutException('Request timeout')` |
| `CacheException` | `(message)` | `CacheException('Cache miss')` |
| `DatabaseException` | `(message)` | `DatabaseException('Query failed')` |
| `FileSystemException` | `(message)` | `FileSystemException('File not found')` |
| `ResourceNotFoundException` | `(resource)` | `ResourceNotFoundException('User')` |

## 🎨 UI 组件速查

### ErrorDialog
```dart
await ErrorDialog.show(
  context,
  title: '错误',
  message: '操作失败',
  onRetry: () { /* 重试逻辑 */ },
);
```

### LoadingIndicator
```dart
// 基础版本
LoadingIndicator(message: '加载中...')

// 全屏版本
LoadingIndicator.fullScreen(message: '加载中...')

// 紧凑版本
LoadingIndicator.compact(size: 30)
```

### EmptyStateWidget
```dart
// 历史记录空状态
EmptyStateWidget.history()

// 搜索结果空状态
EmptyStateWidget.searchResults('query', onRetry: refresh)

// 收藏空状态
EmptyStateWidget.favorites()

// 自定义空状态
EmptyStateWidget.custom(
  title: '无数据',
  message: '暂无内容',
  onRetry: refresh,
)
```

### SkeletonLoader
```dart
// 文本骨架
SkeletonLoader.textLoader()

// 列表骨架
SkeletonLoader.listLoader(itemCount: 5)

// 卡片骨架
SkeletonLoader.cardLoader()
```

## ⚙️ 集成检查清单

✅ **导入** - 确保所有必要的导入都存在  
✅ **别名** - 如果使用了 `flutter_tts`，使用别名导入 `ErrorHandler`  
✅ **try-catch** - 关键操作用 try-catch 包装  
✅ **错误消息** - 使用 `ErrorHandler().handleException()` 转换异常  
✅ **UI 反馈** - 使用 `ErrorDialog.show()` 或 `SnackBar` 显示错误  
✅ **重试机制** - 异步操作支持重试回调  
✅ **编译检查** - `flutter analyze` 无错误  

## 📊 所有集成屏幕

| # | 屏幕 | 关键异常类型 | UI 处理 |
|----|------|-----------|--------|
| 1 | camera_screen.dart | AuthException, I/O | ErrorDialog + 重试 |
| 2 | translate_result_screen.dart | TTS Error | ErrorDialog + 重试 |
| 3 | voice_input_screen.dart | AuthException, Speech | ErrorDialog + 重试 |
| 4 | history_screen.dart | - | EmptyState + Loading |
| 5 | dictionary_home_screen.dart | - | EmptyState + Loading |
| 6 | ocr_result_screen.dart | Validation, File | ErrorDialog + SnackBar |
| 7 | dictionary_detail_screen.dart | TTS, Clipboard | SnackBar/Dialog |
| 8 | home_screen.dart | Validation, Navigation | SnackBar |
| 9 | conversation_screen.dart | Validation, Network | SnackBar |
| 10 | settings_screen.dart | Validation | SnackBar |
| 11 | language_switcher_page.dart | Validation | SnackBar |
| 12 | onboarding_screen.dart | Navigation | SnackBar |
| 13 | splash_screen.dart | Init, Navigation | ErrorDialog + 重试 |

## 🔍 常见问题

**Q: 为什么 ErrorHandler 需要别名？**  
A: `flutter_tts` 包也定义了 `ErrorHandler`，使用别名避免冲突。

**Q: 什么时候用 ErrorDialog vs SnackBar？**  
A: 重要操作（需要重试）→ ErrorDialog；简单通知 → SnackBar

**Q: 如何自定义错误消息？**  
A: ErrorHandler 会根据异常类型自动生成，如需自定义，直接传递消息给异常构造器。

**Q: 加载状态应该用什么？**  
A: 使用 `LoadingIndicator` 或在 Riverpod `when()` 中使用 `loading()` 分支。

**Q: 怎样处理列表为空的情况？**  
A: 使用 `EmptyStateWidget.searchResults()` 或其他预设，支持重试回调。

## 📚 文件引用

- **异常定义**: `lib/core/exceptions/app_exceptions.dart`
- **处理器**: `lib/core/error/error_handler.dart`
- **对话框**: `lib/shared/widgets/error_dialog.dart`
- **指示器**: `lib/shared/widgets/loading_indicator.dart`
- **空状态**: `lib/shared/widgets/empty_state.dart`
- **骨架**: `lib/shared/widgets/skeleton_loader.dart`

## ✨ 下一步

建议继续改进：
1. 添加分析（Sentry、Firebase Crashlytics）
2. 本地化错误消息（i18n）
3. 离线优雅降级
4. 单元测试覆盖
5. API 错误重试策略（指数退避）
