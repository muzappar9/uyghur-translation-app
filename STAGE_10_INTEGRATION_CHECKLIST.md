# Stage 10 → Stage 11 集成清单

**用途**: 指导如何将 Stage 10 的提供者和路由集成到现有应用中  
**预计时间**: 4-6 小时  
**难度**: 中等  
**优先级**: 紧急 (必须完成后才能继续)

---

## ✅ 前置条件检查

在开始集成之前，请确保：

- [x] Stage 1-9 的所有代码都可以编译
- [x] Stage 10 的所有测试都通过 (90+)
- [x] 已阅读 STAGE_10_DEVELOPER_GUIDE.md
- [x] 已理解 Riverpod 和 GoRouter 的基本概念
- [x] 所有文件都已创建且编译通过

---

## 🔧 集成任务清单

### 第 1 部分: 主应用程序集成 (2-3 小时)

#### Task 1.1: 更新 main.dart
**文件**: `lib/main.dart`  
**操作**: 添加 Riverpod ProviderScope 和 GoRouter

```dart
// ❌ 当前
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

// ✅ 应该改为
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 初始化 Hive 提供者
    final hiveAsyncValue = ref.watch(hiveInitProvider);
    
    // 获取 GoRouter
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('zh', 'CN'),
        Locale('ug', 'CN'),
        Locale('en', 'US'),
      ],
    );
  }
}
```

**检查清单**:
- [ ] 导入 `package:flutter_riverpod/flutter_riverpod.dart`
- [ ] 导入 `package:uyghur_translator/shared/providers/hive_provider.dart`
- [ ] 导入 `package:uyghur_translator/shared/providers/router_provider.dart`
- [ ] 将 `MyApp` 改为 `ConsumerWidget`
- [ ] 添加 `ProviderScope` 包装
- [ ] 配置 `MaterialApp.router`
- [ ] 设置路由配置为 `goRouterProvider`
- [ ] 编译并验证无错误

---

#### Task 1.2: 更新应用主题配置
**文件**: `lib/app/theme/app_theme.dart` (如果存在) 或在 main.dart 中

**操作**: 添加深色模式支持和设置集成

```dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}

// 在 MyApp 中使用
@override
Widget build(BuildContext context, WidgetRef ref) {
  final settings = ref.watch(settingsProvider);
  final darkMode = ref.watch(darkModeProvider);
  
  return MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),
    themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
  );
}
```

**检查清单**:
- [ ] 导入设置提供者
- [ ] 读取 `darkModeProvider`
- [ ] 读取 `appThemeProvider`
- [ ] 配置 `themeMode`
- [ ] 测试深色/浅色切换

---

### 第 2 部分: UI 屏幕集成 (2-3 小时)

#### Task 2.1: 更新所有屏幕为 ConsumerWidget
**影响文件**: `lib/features/screens/*.dart` (所有屏幕)

**操作**: 将 `StatelessWidget` 改为 `ConsumerWidget`

```dart
// ❌ 当前
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}

// ✅ 应该改为
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 现在可以使用 ref 访问提供者
    final translationState = ref.watch(translationProvider);
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      // ...
    );
  }
}
```

**检查清单** (对每个屏幕):
- [ ] 导入 `package:flutter_riverpod/flutter_riverpod.dart`
- [ ] 改为继承 `ConsumerWidget`
- [ ] 更新 `build` 方法签名添加 `WidgetRef ref`
- [ ] 编译并验证

**需要更新的屏幕**:
1. [ ] `splash_screen.dart`
2. [ ] `onboarding_screen.dart`
3. [ ] `home_screen.dart`
4. [ ] `voice_input_screen.dart`
5. [ ] `camera_screen.dart`
6. [ ] `ocr_result_screen.dart`
7. [ ] `dictionary_screen.dart`
8. [ ] `translation_history_screen.dart`
9. [ ] `settings_screen.dart`
10. [ ] `language_switcher_screen.dart`
11. [ ] `translate_result_screen.dart`
12. [ ] `conversation_screen.dart`

---

#### Task 2.2: 在翻译屏幕中使用翻译提供者
**文件**: `lib/features/screens/home_screen.dart`

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('翻译')),
      body: Column(
        children: [
          // 源文本输入
          TextField(
            onChanged: (text) {
              // 不需要手动触发，可以使用 ref.read 处理
              ref.read(translationProvider.notifier).translate(text);
            },
            decoration: InputDecoration(
              hintText: '输入要翻译的文本',
              label: Text('${translationState.sourceLanguage.toUpperCase()}'),
            ),
          ),
          
          // 显示加载状态
          if (translationState.isLoading)
            CircularProgressIndicator()
          else if (translationState.error != null)
            ErrorWidget(error: translationState.error)
          else
            Text(translationState.targetText),
          
          // 语言切换按钮
          Row(
            children: [
              ElevatedButton(
                onPressed: () => ref.read(translationProvider.notifier)
                    .setSourceLanguage('en'),
                child: Text('English'),
              ),
              ElevatedButton(
                onPressed: () => ref.read(translationProvider.notifier)
                    .setTargetLanguage('ug'),
                child: Text('Uyghur'),
              ),
              ElevatedButton(
                onPressed: () => ref.read(translationProvider.notifier)
                    .swapLanguages(),
                child: Icon(Icons.swap_horiz),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**检查清单**:
- [ ] 导入翻译提供者
- [ ] 使用 `ref.watch(translationProvider)`
- [ ] 显示加载状态
- [ ] 显示错误消息
- [ ] 显示翻译结果
- [ ] 实现语言切换
- [ ] 实现交换语言
- [ ] 测试完整流程

---

#### Task 2.3: 在语音输入屏幕中使用语音提供者
**文件**: `lib/features/screens/voice_input_screen.dart`

```dart
class VoiceInputScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('语音输入')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 权限检查
          if (!voiceState.hasPermission)
            ElevatedButton(
              onPressed: () => ref.read(voiceProvider.notifier)
                  .requestPermission(),
              child: Text('请求麦克风权限'),
            )
          else
            // 开始/停止按钮
            ElevatedButton.icon(
              onPressed: () {
                if (voiceState.isListening) {
                  ref.read(voiceProvider.notifier).stopListening();
                } else {
                  ref.read(voiceProvider.notifier).startListening();
                }
              },
              icon: Icon(voiceState.isListening ? Icons.mic : Icons.mic_none),
              label: Text(voiceState.isListening ? '停止' : '开始'),
            ),
          
          // 显示识别结果
          SizedBox(height: 20),
          if (voiceState.isProcessing)
            CircularProgressIndicator()
          else if (voiceState.error != null)
            Text('错误: ${voiceState.error}')
          else
            Text(voiceState.recognizedText),
        ],
      ),
    );
  }
}
```

**检查清单**:
- [ ] 导入语音提供者
- [ ] 请求权限检查
- [ ] 实现开始/停止按钮
- [ ] 显示识别结果
- [ ] 显示错误消息
- [ ] 测试权限流程
- [ ] 测试识别功能

---

#### Task 2.4: 在设置屏幕中使用设置提供者
**文件**: `lib/features/screens/settings_screen.dart`

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          // 语言设置
          ListTile(
            title: Text('源语言'),
            subtitle: Text(settings.sourceLanguage),
            onTap: () {
              // 打开语言选择对话框
            },
          ),
          ListTile(
            title: Text('目标语言'),
            subtitle: Text(settings.targetLanguage),
            onTap: () {
              // 打开语言选择对话框
            },
          ),
          
          Divider(),
          
          // 功能切换
          SwitchListTile(
            title: Text('启用语音输入'),
            value: settings.enableVoiceInput,
            onChanged: (value) => ref.read(settingsProvider.notifier)
                .setVoiceInputEnabled(value),
          ),
          SwitchListTile(
            title: Text('启用 OCR'),
            value: settings.enableOcr,
            onChanged: (value) => ref.read(settingsProvider.notifier)
                .setOcrEnabled(value),
          ),
          SwitchListTile(
            title: Text('启用通知'),
            value: settings.enableNotifications,
            onChanged: (value) => ref.read(settingsProvider.notifier)
                .setNotificationsEnabled(value),
          ),
          SwitchListTile(
            title: Text('离线模式'),
            value: settings.enableOfflineMode,
            onChanged: (value) => ref.read(settingsProvider.notifier)
                .setOfflineModeEnabled(value),
          ),
          
          Divider(),
          
          // 主题设置
          SwitchListTile(
            title: Text('深色模式'),
            value: settings.darkMode,
            onChanged: (value) => ref.read(settingsProvider.notifier)
                .setDarkMode(value),
          ),
          
          Divider(),
          
          // 重置按钮
          ListTile(
            title: Text('重置为默认设置'),
            onTap: () => _showResetDialog(context, ref),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('重置设置'),
        content: Text('确定要重置所有设置为默认值吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
            },
            child: Text('重置'),
          ),
        ],
      ),
    );
  }
}
```

**检查清单**:
- [ ] 导入设置提供者
- [ ] 显示所有设置项
- [ ] 实现语言切换
- [ ] 实现功能切换
- [ ] 实现主题切换
- [ ] 实现重置功能
- [ ] 测试所有切换项

---

### 第 3 部分: 路由集成 (1-2 小时)

#### Task 3.1: 验证路由导航
**测试**: 验证所有路由导航按预期工作

```dart
// 在任何屏幕中都可以使用这些快捷方式
context.toTranslate();           // 导航到翻译
context.toDictionary();          // 导航到字典
context.toHistory();             // 导航到历史
context.toSettings();            // 导航到设置
context.toVoiceInput();          // 导航到语音输入
context.toCamera();              // 导航到摄像头
context.toOcrResult('path');     // 导航到 OCR 结果
context.toTranslateResult(...);  // 导航到翻译结果
context.toConversation();        // 导航到对话
context.toLanguageSwitcher();    // 导航到语言切换
context.safeGoBack();            // 安全返回
context.backToHome();            // 返回首页
```

**检查清单**:
- [ ] 测试所有路由导航
- [ ] 验证路由转换动画
- [ ] 检查导航历史记录
- [ ] 测试深层导航 (如 settings → language switcher)
- [ ] 测试返回按钮行为

---

#### Task 3.2: 验证路由守卫
**测试**: 确保路由守卫正常工作

```dart
// 权限检查守卫
- [ ] 导航到摄像头时检查权限
- [ ] 导航到语音输入时检查权限

// 初始化检查守卫
- [ ] 防止在未初始化时访问受保护的路由

// 数据验证守卫
- [ ] OCR 结果路由需要有效的图像路径
- [ ] 翻译结果路由需要有效的文本
```

**检查清单**:
- [ ] 权限拒绝时自动请求
- [ ] 无效数据时自动重定向
- [ ] 错误被正确记录
- [ ] 用户看到适当的错误消息

---

### 第 4 部分: 验证和测试 (1-2 小时)

#### Task 4.1: 编译验证
```powershell
cd "d:\princip计划\ai翻译\uyghur-translation-app1"
flutter pub get
flutter analyze
```

**检查清单**:
- [ ] 没有编译错误
- [ ] 没有 Lint 警告
- [ ] 所有导入都正确

---

#### Task 4.2: 运行所有测试
```powershell
flutter test
```

**检查清单**:
- [ ] 所有 90+ 个 Stage 10 测试通过
- [ ] Stage 1-9 的测试仍然通过
- [ ] 没有新的失败

---

#### Task 4.3: 功能测试
**手动测试清单**:

翻译功能:
- [ ] 输入文本自动翻译
- [ ] 显示加载指示器
- [ ] 显示错误消息
- [ ] 可以交换语言
- [ ] 可以改变源/目标语言

语音识别:
- [ ] 请求麦克风权限
- [ ] 开始/停止录音
- [ ] 显示识别结果
- [ ] 显示错误消息

OCR 识别:
- [ ] 可以拍照
- [ ] 显示识别结果
- [ ] 处理无权限情况

设置:
- [ ] 可以改变语言
- [ ] 可以启用/禁用功能
- [ ] 可以改变主题
- [ ] 可以深色模式
- [ ] 可以重置设置

路由:
- [ ] 所有导航按钮都工作
- [ ] 返回按钮正常工作
- [ ] 深层导航正常工作
- [ ] 路由转换动画流畅

---

#### Task 4.4: 性能验证
```dart
// 检查：
- [ ] 应用启动时间 <3 秒
- [ ] 路由转换时间 <200ms
- [ ] 状态更新立即显示
- [ ] 没有内存泄漏（运行一段时间后检查）
```

---

### 第 5 部分: 文档和交接 (30 分钟)

#### Task 5.1: 更新项目文档
**文件**: `README.md` 或 `docs/ARCHITECTURE.md`

添加以下部分:
```markdown
## 状态管理

本项目使用 Riverpod 进行状态管理。有 5 个主要提供者：
- `translationProvider` - 翻译状态
- `voiceProvider` - 语音识别状态
- `ocrProvider` - OCR 识别状态
- `settingsProvider` - 应用设置
- `hiveInitProvider` - 本地存储初始化

详见 `docs/STAGE_10_DEVELOPER_GUIDE.md`

## 路由

本项目使用 GoRouter 进行路由管理。有 14 个主要路由。

详见 `lib/routes/route_names.dart`
```

**检查清单**:
- [ ] 更新 README.md
- [ ] 更新架构文档
- [ ] 链接到 STAGE_10_DEVELOPER_GUIDE.md

---

#### Task 5.2: 创建迁移检查清单
**为下一个开发者**:

```markdown
## Stage 10 集成完成检查清单

- [x] main.dart 已更新为使用 ProviderScope 和 GoRouter
- [x] 所有屏幕已改为 ConsumerWidget
- [x] 翻译功能已集成
- [x] 语音识别已集成
- [x] OCR 功能已集成
- [x] 设置管理已集成
- [x] 所有路由导航已验证
- [x] 所有测试都通过
- [x] 无编译错误
- [x] 已进行功能测试
```

---

## 📊 进度跟踪

| 任务 | 预计时间 | 完成状态 | 备注 |
|------|---------|---------|------|
| 1.1 main.dart 集成 | 30 分钟 | [ ] | |
| 1.2 主题配置 | 20 分钟 | [ ] | |
| 2.1 屏幕转换 | 1 小时 | [ ] | 12 个屏幕 |
| 2.2 翻译集成 | 30 分钟 | [ ] | |
| 2.3 语音集成 | 30 分钟 | [ ] | |
| 2.4 设置集成 | 30 分钟 | [ ] | |
| 3.1 路由验证 | 30 分钟 | [ ] | |
| 3.2 守卫验证 | 30 分钟 | [ ] | |
| 4.1 编译验证 | 15 分钟 | [ ] | |
| 4.2 测试运行 | 30 分钟 | [ ] | |
| 4.3 功能测试 | 1 小时 | [ ] | |
| 4.4 性能验证 | 30 分钟 | [ ] | |
| 5.1 文档更新 | 20 分钟 | [ ] | |
| 5.2 迁移清单 | 10 分钟 | [ ] | |
| **总计** | **6-8 小时** | [ ] | |

---

## 🆘 常见问题

**Q: 集成时出现 "Undefined name" 错误**  
A: 检查导入语句，确保导入了正确的提供者文件

**Q: GoRouter 不能正确导航**  
A: 验证 main.dart 中的 `MaterialApp.router` 配置

**Q: 提供者返回过时数据**  
A: 使用 `ref.watch()` 而不是 `ref.read()`，并确保在正确的 ConsumerWidget 中

**Q: 路由守卫阻止了合法导航**  
A: 检查 route_guards.dart 中的逻辑，可能需要调整权限检查

**Q: 性能变差**  
A: 检查不必要的 `ref.watch()` 调用，使用衍生提供者而不是监听完整提供者

---

## ✨ 集成完成后

一旦集成完成，您可以：

1. 开始 Stage 11 - 实时数据同步与离线支持
2. 添加更多高级功能
3. 优化用户体验
4. 开展性能调优

---

**创建日期**: 2024年12月5日  
**用途**: 指导 Stage 10 集成  
**状态**: 就绪 🚀
