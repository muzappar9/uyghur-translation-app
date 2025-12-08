# Stage 10 - 开发者快速参考指南

## 🎯 快速导航

### 1. 使用状态提供者

#### 翻译管理
```dart
// 在 ConsumerWidget 或 ConsumerStatefulWidget 中
final translationState = ref.watch(translationProvider);

// 执行翻译
ref.read(translationProvider.notifier).translate('Hello world');

// 交换语言
ref.read(translationProvider.notifier).swapLanguages();

// 检查加载状态
if (translationState.isLoading) {
  return const CircularProgressIndicator();
}

// 显示结果
Text(translationState.targetText);
```

#### 语音识别
```dart
// 监听语音状态
final voiceState = ref.watch(voiceProvider);

// 开始识别
await ref.read(voiceProvider.notifier).startListening();

// 检查权限
if (!voiceState.hasPermission) {
  await ref.read(voiceProvider.notifier).requestPermission();
}

// 获取识别结果
String recognized = voiceState.recognizedText;
```

#### OCR 识别
```dart
// 识别图像
await ref.read(ocrProvider.notifier).recognizeFromFile('image.jpg');

// 从字节识别
await ref.read(ocrProvider.notifier).recognizeFromBytes(imageBytes);

// 获取结果
final ocrState = ref.watch(ocrProvider);
if (!ocrState.isProcessing) {
  print(ocrState.recognizedText);
}
```

#### 应用设置
```dart
// 获取当前设置
final settings = ref.watch(settingsProvider);

// 修改设置
await ref.read(settingsProvider.notifier).setDarkMode(true);
await ref.read(settingsProvider.notifier).setSourceLanguage('zh');

// 使用衍生提供者（更高效）
final darkMode = ref.watch(darkModeProvider);
final sourceLanguage = ref.watch(sourceLanguageProvider);

// 重置为默认
await ref.read(settingsProvider.notifier).resetToDefaults();
```

#### Hive 存储
```dart
// 获取存储 Box
final prefs = await ref.read(userPreferencesBoxProvider.future);
final config = await ref.read(appConfigBoxProvider.future);
final cache = await ref.read(cacheBoxProvider.future);

// 存储数据
await prefs.put('key', 'value');

// 读取数据
final value = prefs.get('key', defaultValue: 'default');

// 删除数据
await prefs.delete('key');
```

---

### 2. 路由导航

#### 基本导航
```dart
// 使用 BuildContext 扩展（推荐）
context.toTranslate();
context.toDictionary();
context.toHistory();
context.toSettings();

// 导航到子页面
context.toVoiceInput();
context.toCamera();
context.toConversation();

// 带数据的导航
context.toOcrResult('image_path.jpg');
context.toTranslateResult('source text', 'target text');

// 安全返回
context.safeGoBack();
context.backToHome();
```

#### 使用 GoRouter
```dart
// 使用 GoRouter 实例
final router = ref.read(goRouterProvider);
router.goToTranslate();
router.goToVoiceInput();

// 编程式导航
context.goNamed(RouteNames.home);
context.pushNamed(RouteNames.voiceInput);

// 获取当前路由
final currentRoute = ref.watch(currentRouteProvider);
```

#### 路由守卫
```dart
// 路由会自动经过守卫检查：
// 1. PermissionGuard - 检查权限
// 2. InitializationGuard - 检查初始化
// 3. DataValidationGuard - 验证数据

// 如果守卫拒绝，自动重定向
// 错误会被记录和处理
```

---

### 3. 错误处理模式

#### 提供者错误处理
```dart
final state = ref.watch(translationProvider);

// 检查是否有错误
if (state.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.error!)),
  );
  
  // 清除错误（如果支持）
  ref.read(translationProvider.notifier).clearError?.call();
}

// 或在 ConsumerStatefulWidget 中使用 ref.listen
ref.listen<TranslationState>(
  translationProvider,
  (previous, next) {
    if (next.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error!)),
      );
    }
  },
);
```

#### 异步操作处理
```dart
try {
  await ref.read(translationProvider.notifier).translate('text');
} catch (e) {
  // 错误会自动捕获并存储在状态中
  final errorMsg = ref.read(translationProvider).error;
  print('翻译失败: $errorMsg');
}
```

---

### 4. 高级用法

#### 组合多个提供者
```dart
class TranslationScreenViewModel extends Notifier<TranslationScreenState> {
  @override
  TranslationScreenState build() {
    // 监听多个提供者
    final translation = ref.watch(translationProvider);
    final settings = ref.watch(settingsProvider);
    final voice = ref.watch(voiceProvider);
    
    return TranslationScreenState(
      translation: translation,
      settings: settings,
      voice: voice,
    );
  }
}

// 使用
final viewModel = ref.watch(translationScreenViewModelProvider);
```

#### 条件提供者
```dart
// 根据离线模式返回不同的服务
final translationServiceProvider = Provider((ref) {
  final settings = ref.watch(settingsProvider);
  
  if (settings.enableOfflineMode) {
    return OfflineTranslationService();
  } else {
    return OnlineTranslationService();
  }
});
```

#### 缓存和重新计算
```dart
// Riverpod 自动缓存提供者值
// 当依赖项改变时自动重新计算

final translationProvider = StateNotifierProvider<...>((ref) {
  // 当 settingsProvider 改变时，这个提供者会自动重新初始化
  ref.watch(settingsProvider);
  return TranslationNotifier(...);
});
```

---

### 5. 常见模式

#### 加载状态 UI
```dart
final state = ref.watch(translationProvider);

if (state.isLoading) {
  return const LoadingWidget();
} else if (state.error != null) {
  return ErrorWidget(error: state.error);
} else if (state.targetText.isNotEmpty) {
  return ResultWidget(text: state.targetText);
} else {
  return const EmptyWidget();
}
```

#### 权限检查
```dart
Future<void> startVoiceInput() async {
  final voiceNotifier = ref.read(voiceProvider.notifier);
  
  // 检查权限
  await voiceNotifier.checkPermission();
  final hasPermission = ref.read(voiceProvider).hasPermission;
  
  if (!hasPermission) {
    // 请求权限
    await voiceNotifier.requestPermission();
  }
  
  // 开始识别
  await voiceNotifier.startListening();
}
```

#### 设置持久化
```dart
// 在应用启动时加载设置
Future<void> initApp() async {
  final container = ProviderContainer();
  
  // 初始化 Hive
  await container.read(hiveInitProvider.future);
  
  // 从存储加载设置（如果实现了）
  // 设置会自动从 PreferenceService 加载
}
```

#### 深度链接处理
```dart
// 应用启动时处理深度链接
Future<void> handleDeepLink(Uri uri) async {
  final route = DeepLinkHandler.handleDeepLink(uri);
  if (route != null) {
    GoRouter.of(context).go(route);
  }
}
```

---

### 6. 调试和日志

#### 启用路由日志
```dart
// 在 GoRouter 配置中已启用
debugLogDiagnostics: true

// 手动记录
RouteLogger.logNavigationStart(routeName);
RouteLogger.logNavigationComplete(routeName);
RouteLogger.logNavigationError(routeName, error);
```

#### 获取分析数据
```dart
// 获取导航统计
final analytics = RouteAnalytics.getAnalytics();
print('Navigation count: ${analytics['navigationCount']}');
print('Last navigation: ${analytics['lastNavigationTime']}');

// 重置统计
RouteAnalytics.reset();
```

#### 观察状态变化
```dart
// 在 ConsumerStatefulWidget 中
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // 监听特定状态
  ref.listen<TranslationState>(
    translationProvider,
    (previous, next) {
      print('Translation state changed');
      print('Loading: ${next.isLoading}');
      print('Error: ${next.error}');
    },
  );
}
```

---

### 7. 最佳实践

#### ✅ 推荐做法
```dart
// 1. 使用 ConsumerWidget 或 ConsumerStatefulWidget
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 直接访问 ref
  }
}

// 2. 在 Notifier 中处理所有逻辑
class TranslationNotifier extends StateNotifier<TranslationState> {
  // 所有业务逻辑都在这里
  Future<void> translate(String text) async {
    // 更新 UI 状态
    state = state.copyWith(isLoading: true);
    try {
      final result = await _service.translate(text);
      state = state.copyWith(targetText: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// 3. 使用快捷方法简化导航
context.toTranslate();

// 4. 处理权限检查
if (!state.hasPermission) {
  await requestPermission();
}
```

#### ❌ 避免做法
```dart
// 1. 直接修改状态（而不是通过 Notifier）
// ❌ BAD:
translationState.sourceText = 'text'; 

// ✅ GOOD:
ref.read(translationProvider.notifier).translate('text');

// 2. 在 Widget 中处理复杂逻辑
// ❌ BAD:
if (condition) {
  // 复杂的业务逻辑
}

// ✅ GOOD:
// 逻辑在 StateNotifier 中

// 3. 忘记处理错误
// ❌ BAD:
final result = await translate();

// ✅ GOOD:
try {
  final result = await translate();
} catch (e) {
  state = state.copyWith(error: e.toString());
}

// 4. 在不需要时重新构建
// ❌ BAD:
final state = ref.watch(translationProvider); // 任何改变都重建

// ✅ GOOD:
final sourceLanguage = ref.watch(sourceLanguageProvider); // 只关注需要的
```

---

### 8. 测试提供者

```dart
test('翻译提供者测试', () async {
  final container = ProviderContainer();
  
  // 执行操作
  await container.read(translationProvider.notifier).translate('test');
  
  // 验证结果
  final state = container.read(translationProvider);
  expect(state.targetText, isNotEmpty);
  expect(state.error, isNull);
});
```

---

### 9. 常见问题

**Q: 如何在提供者之间共享数据？**  
A: 使用衍生提供者或在 Notifier 中调用其他提供者。

**Q: 如何使状态持久化？**  
A: 使用 Hive 提供者存储，应用启动时加载。

**Q: 如何处理异步操作？**  
A: 在 StateNotifier 方法中使用 async/await，状态管理异步流。

**Q: 如何测试包含异步操作的提供者？**  
A: 使用 `await container.read(provider.future)` 等待 Future 完成。

---

## 📚 相关文件

| 文件 | 说明 |
|-----|------|
| `lib/shared/providers/hive_provider.dart` | Hive 初始化和 Box 管理 |
| `lib/shared/providers/translation_provider.dart` | 翻译状态管理 |
| `lib/shared/providers/voice_provider.dart` | 语音识别状态管理 |
| `lib/shared/providers/ocr_provider.dart` | OCR 识别状态管理 |
| `lib/shared/providers/settings_provider.dart` | 应用设置管理 |
| `lib/shared/providers/router_provider.dart` | GoRouter 配置 |
| `lib/routes/route_names.dart` | 路由常量定义 |
| `lib/routes/route_guards.dart` | 路由守卫实现 |
| `lib/routes/app_router.dart` | 路由配置和工具 |

---

## 🔗 快速链接

- [Riverpod 官方文档](https://riverpod.dev)
- [GoRouter 官方文档](https://pub.dev/packages/go_router)
- [Freezed 官方文档](https://pub.dev/packages/freezed)
- [Hive 官方文档](https://docs.hivedb.dev)

---

**最后更新**: 2024年12月5日  
**维护者**: GitHub Copilot
