# 第 2 阶段快速开始指南 - 核心屏幕实现

**状态**：准备开始第 2 阶段
**预计工时**：30-40 小时
**预计周期**：1-2 周

---

## 🎯 第 2 阶段目标

实现 8 个核心屏幕，连接所有 UI 组件到 Riverpod 状态管理系统。

**完成后的预期完成度**：70-75%

---

## 📋 第 2 阶段任务分解

### 优先级分类

| 优先级 | 屏幕 | 依赖 | 预计时间 | 复杂度 |
|--------|------|------|---------|--------|
| P0 | HomeScreen | currentTranslationProvider | 4h | 高 |
| P0 | TranslateResultScreen | currentTranslationProvider | 2h | 中 |
| P1 | HistoryScreen | translationHistoryProvider | 3h | 中 |
| P1 | VoiceInputScreen | speech_to_text 集成 | 4h | 高 |
| P1 | CameraScreen | camera + ML Kit 集成 | 5h | 高 |
| P2 | SettingsScreen | appStateProvider | 2h | 低 |
| P2 | DictionaryScreen | 新 feature 框架 | 3h | 中 |
| P2 | ConversationScreen | 新 feature 框架 | 4h | 中 |

**合计**：27 小时（含测试）

---

## 🛠️ 待集成的包

### 需要新增的依赖

```yaml
# pubspec.yaml 补充

dependencies:
  # 语音
  speech_to_text: ^6.4.0
  
  # 相机
  camera: ^0.10.0
  google_mlkit_text_recognition: ^0.10.0
  
  # 文本转语音
  flutter_tts: ^0.16.0
  
  # 分享
  share_plus: ^7.0.0
  
  # 图像处理
  image_picker: ^1.0.0

dev_dependencies:
  integration_test:
    sdk: flutter
```

**执行**：
```bash
flutter pub add speech_to_text camera google_mlkit_text_recognition flutter_tts share_plus image_picker
```

---

## 📝 实现步骤

### 步骤 1：实现 HomeScreen（P0，4小时）

**文件**：`lib/features/translation/presentation/pages/home_screen.dart`

**功能需求**：
1. 输入框（sourceText）
2. 翻译按钮 - 调用 `ref.read(currentTranslationProvider.notifier).translate()`
3. 结果显示 - 监听 `currentTranslationProvider`
4. 模式切换按钮（文本/语音/相机/对话）
5. 语言选择器
6. 收藏按钮

**集成点**：
```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen();
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }
  
  void _handleTranslate() {
    final text = _controller.text;
    ref.read(currentTranslationProvider.notifier)
        .translate(text, 'zh', 'ug');
  }
  
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(currentTranslationProvider);
    
    return Scaffold(
      // TODO: 实现 UI
    );
  }
}
```

---

### 步骤 2：实现 TranslateResultScreen（P0，2小时）

**文件**：`lib/features/translation/presentation/pages/translate_result_screen.dart`

**功能需求**：
1. 显示源文本和翻译结果
2. 复制按钮（Clipboard）
3. 朗读按钮（flutter_tts）
4. 收藏按钮 - 调用 `translationHistoryProvider.notifier`
5. 分享按钮（share_plus）

**集成点**：
```dart
void _handleFavorite() async {
  final translation = Translation(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    sourceText: widget.sourceText,
    targetText: result,
    sourceLang: 'zh',
    targetLang: 'ug',
    timestamp: DateTime.now(),
  );
  
  await ref.read(translationHistoryProvider.notifier)
      .addTranslation(translation);
}
```

---

### 步骤 3：实现 HistoryScreen（P1，3小时）

**文件**：`lib/features/translation/presentation/pages/history_screen.dart`

**功能需求**：
1. 列表显示历史记录 - 使用 `translationHistoryProvider`
2. 删除功能
3. 收藏切换
4. 搜索过滤
5. 项目点击 - 导航到 TranslateResultScreen

**集成点**：
```dart
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(translationHistoryProvider);
    
    return historyAsync.when(
      data: (history) => ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(history[index].sourceText),
          subtitle: Text(history[index].targetText),
          // TODO: 实现删除和收藏
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

---

### 步骤 4：实现 VoiceInputScreen（P1，4小时）

**文件**：`lib/features/translation/presentation/pages/voice_input_screen.dart`

**需要新增依赖**：
```yaml
speech_to_text: ^6.4.0
permission_handler: ^11.0.0
```

**功能需求**：
1. 权限请求（麦克风）
2. 录音波形动画
3. 语音识别 - speech_to_text
4. 识别结果显示
5. 翻译按钮

**实现框架**：
```dart
class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen();
  
  @override
  ConsumerState<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen> {
  late SpeechToText _speechToText;
  String _recognizedText = '';
  
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }
  
  Future<void> _initSpeech() async {
    await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) => print('Status: $status'),
    );
  }
  
  void _startListening() async {
    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords);
        },
      );
    }
  }
}
```

---

### 步骤 5：实现 CameraScreen（P1，5小时）

**需要新增依赖**：
```yaml
camera: ^0.10.0
google_mlkit_text_recognition: ^0.10.0
image_picker: ^1.0.0
```

**功能需求**：
1. 相机预览
2. 拍照功能
3. OCR 识别（Google ML Kit）
4. 识别结果显示
5. 翻译按钮

**实现框架**：
```dart
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen();
  
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  late CameraController _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  String _recognizedText = '';
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _takePicture() async {
    final image = await _cameraController.takePicture();
    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    setState(() => _recognizedText = recognizedText.text);
  }
}
```

---

### 步骤 6-8：实现其他屏幕（P2，9小时）

#### SettingsScreen（2小时）
```dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // 语言选择
          ListTile(
            title: const Text('Language'),
            subtitle: Text(appState.currentLanguage),
            onTap: () => _showLanguageDialog(context, notifier),
          ),
          // 深色模式切换
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: appState.isDarkMode,
            onChanged: (value) => notifier.setDarkMode(value),
          ),
        ],
      ),
    );
  }
}
```

#### DictionaryScreen（3.5小时）
需要创建新的 Provider 和数据模型

#### ConversationScreen（3.5小时）
需要创建新的 feature 框架

---

## 🔗 Riverpod 使用规范

### 消费状态（只读）
```dart
final state = ref.watch(appStateProvider);
final currentLanguage = state.currentLanguage;
```

### 修改状态（写入）
```dart
ref.read(appStateProvider.notifier).setLanguage('ug');
```

### 异步操作
```dart
final result = ref.watch(currentTranslationProvider);
result.when(
  data: (translation) => Text(translation),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### 监听变化
```dart
ref.listen(translationHistoryProvider, (previous, next) {
  // 历史记录变化时执行
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('历史已更新')),
  );
});
```

---

## 📦 分层架构指导

```
screens/
├── home_screen.dart           # Presentation 层，使用 Riverpod
├── history_screen.dart
├── voice_input_screen.dart
├── camera_screen.dart
└── ...

providers/
├── translation_provider.dart   # 状态管理
├── voice_provider.dart
└── camera_provider.dart

repositories/                   # Data 层（已有）
├── translation_repository.dart

datasources/                    # Remote/Local（已有）
├── translation_mock_datasource.dart
└── api_client.dart
```

---

## ✅ 验证清单

完成每个屏幕后，检查：

- [ ] 屏幕可以正确导航到
- [ ] ConsumerWidget/ConsumerStatefulWidget 正确集成
- [ ] 所有 Provider 调用正确（watch/read）
- [ ] 异步操作正确处理（AsyncValue.when）
- [ ] UI 正确响应状态变化
- [ ] 没有编译错误
- [ ] 没有 lint 警告

---

## 🚀 立即开始的命令

```bash
# 1. 拉取最新代码
git pull origin main

# 2. 获取依赖
flutter pub get

# 3. 开始实现 HomeScreen
# 替换 lib/routes/app_router.dart 中的 HomeScreenPlaceholder

# 4. 运行应用测试
flutter run
```

---

## 📞 常见问题

### Q: 如何调试 Riverpod 状态？
A: 使用 flutter_riverpod 的 DevTools：
```bash
flutter pub global activate riverpod_cli
```

### Q: 如何处理异步错误？
A: 使用 AsyncValue.guard：
```dart
state = await AsyncValue.guard(() async {
  return await someAsyncOperation();
});
```

### Q: 如何刷新状态？
A: 使用 `.invalidate()` 或 `.refresh()`：
```dart
ref.refresh(translationHistoryProvider);
```

---

## 📊 预计完成度目标

| 阶段 | 当前 | 第 2 阶段后 | 差异 |
|------|------|----------|------|
| 功能完成度 | 45% | 75% | +30% |
| 屏幕实现 | 0% | 100% | +100% |
| 测试覆盖 | 0% | 30% | +30% |

---

**准备开始第 2 阶段吗？让我们继续！** 🚀
