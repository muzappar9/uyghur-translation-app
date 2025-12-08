# 🚀 Stage 12 快速启动指南 - 核心屏幕实现

**状态**: 📋 **待执行**  
**预计时间**: 2-4周 (68-80小时)  
**前置条件**: ✅ Stage 11完成  

---

## 📌 Stage 12 目标

实现应用的7个核心屏幕，使用Stage 11建立的基础设施：

```
┌─────────────────────────────────────────────────┐
│           Stage 12 核心屏幕地图                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ HomeScreen   │  │ VoiceInput   │            │
│  │ (主翻译屏幕)  │  │ (语音识别)   │            │
│  └──────────────┘  └──────────────┘            │
│         ↓                  ↓                    │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ TranslateRes │  │ CameraScreen │            │
│  │ (翻译结果)   │  │ (图片识别)   │            │
│  └──────────────┘  └──────────────┘            │
│         ↓                  ↓                    │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ HistoryScr.  │  │ DictionaryScr│            │
│  │ (翻译历史)   │  │ (词典搜索)   │            │
│  └──────────────┘  └──────────────┘            │
│         ↓                  ↓                    │
│  ┌──────────────┐  ┌──────────────┐            │
│  │ Conversation │  │  SettingsScr │            │
│  │ (对话模式)   │  │ (设置页面)   │            │
│  └──────────────┘  └──────────────┘            │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 📋 Stage 12 执行计划

### 第1周：基础屏幕 (3个屏幕)

#### 👨‍💻 任务1: HomeScreen (8小时)
```dart
// lib/features/translation/presentation/screens/home_screen.dart

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Providers:
    // - appStateProvider (获取/设置语言)
    // - currentTranslationProvider (执行翻译)
    // - translationHistoryProvider (显示历史)
    
    return Scaffold(
      appBar: AppBar(title: const Text('翻译')),
      body: Column(
        children: [
          // 1. 语言选择器
          // 2. 输入框
          // 3. 翻译按钮
          // 4. 结果显示
          // 5. 快速操作 (复制、分享、收藏)
        ],
      ),
    );
  }
}
```

**关键点**:
- TextField for input
- Language selector dropdown
- TranslationResultWidget
- Copy/Share/Favorite buttons

**集成 Providers:**
```dart
// 获取当前语言
final sourceLanguage = ref.watch(
  appStateProvider.select((state) => state.sourceLanguage),
);

// 执行翻译
ref.read(currentTranslationProvider.notifier)
    .translate(text, sourceLang, targetLang);

// 监听翻译结果
final translationResult = ref.watch(currentTranslationProvider);
```

---

#### 🎤 任务2: VoiceInputScreen (6小时)
```dart
// lib/features/voice_input/presentation/screens/voice_input_screen.dart

class VoiceInputScreen extends ConsumerWidget {
  const VoiceInputScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Providers:
    // - voiceToTextProvider (语音识别)
    // - currentTranslationProvider (自动翻译识别结果)
    // - appStateProvider (获取识别语言)
    
    return Scaffold(
      appBar: AppBar(title: const Text('语音识别')),
      body: Column(
        children: [
          // 1. 录音按钮
          // 2. 波形显示
          // 3. 识别中指示
          // 4. 识别结果
          // 5. 翻译结果
        ],
      ),
    );
  }
}
```

**关键点**:
- Microphone permission handling
- Audio recording with animation
- Real-time transcription display
- Automatic translation

**集成 Providers:**
```dart
// 开始语音识别
ref.read(voiceToTextProvider.notifier).startListening();

// 监听识别结果
final recognizedText = ref.watch(voiceToTextProvider);

// 自动翻译识别结果
ref.read(currentTranslationProvider.notifier)
    .translate(recognizedText, sourceLang, targetLang);
```

---

#### 📸 任务3: CameraScreen (10小时)
```dart
// lib/features/ocr/presentation/screens/camera_screen.dart

class CameraScreen extends ConsumerWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Providers:
    // - imageToTextProvider (OCR识别)
    // - currentTranslationProvider (自动翻译)
    // - appStateProvider (获取语言)
    
    return Scaffold(
      appBar: AppBar(title: const Text('拍照翻译')),
      body: Column(
        children: [
          // 1. CameraPreview
          // 2. 拍照按钮
          // 3. 识别中指示
          // 4. OCR 结果
          // 5. 编辑框
          // 6. 翻译结果
        ],
      ),
    );
  }
}
```

**关键点**:
- Camera permission handling
- CameraController management
- Image capture and preprocessing
- OCR text extraction
- Automatic translation

**集成 Providers:**
```dart
// 执行 OCR 识别
ref.read(imageToTextProvider.notifier)
    .recognizeFromImage(imagePath, language);

// 监听 OCR 结果
final ocrResult = ref.watch(imageToTextProvider);

// 自动翻译 OCR 结果
ref.read(currentTranslationProvider.notifier)
    .translate(ocrResult, sourceLang, targetLang);
```

---

### 第2周：历史和字典屏幕 (2个屏幕)

#### 📜 任务4: HistoryScreen (6小时)
```dart
// lib/features/history/presentation/screens/history_screen.dart

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Providers:
    // - translationHistoryProvider (获取历史)
    // - appStateProvider (获取语言过滤)
    
    return Scaffold(
      appBar: AppBar(title: const Text('翻译历史')),
      body: Column(
        children: [
          // 1. 过滤选项
          // 2. 搜索框
          // 3. 历史列表
          // 4. 清空按钮
        ],
      ),
    );
  }
}
```

**关键点**:
- ListView.builder for efficient list
- Search/filter functionality
- Delete individual/all history
- Favorite toggle
- Re-translate from history

---

#### 📚 任务5: DictionaryScreen (8小时)
```dart
// lib/features/dictionary/presentation/screens/dictionary_screen.dart

class DictionaryScreen extends ConsumerWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Providers:
    // - dictionarySearchProvider (搜索单词)
    // - appStateProvider (获取语言)
    
    return Scaffold(
      appBar: AppBar(title: const Text('词典')),
      body: Column(
        children: [
          // 1. 搜索框
          // 2. 历史单词
          // 3. 搜索结果列表
          // 4. 详细定义
        ],
      ),
    );
  }
}
```

---

### 第3周：对话和设置屏幕 (2个屏幕)

#### 💬 任务6: ConversationScreen (8小时)
#### ⚙️ 任务7: SettingsScreen (4小时)

---

### 第4周：测试和优化 (70%+ 覆盖率)

```
Widget Tests:       (15-20 files)
  - Screen layout
  - User interaction
  - Provider integration

Unit Tests:         (10-15 files)
  - Widget logic
  - Provider behavior
  - Error handling

Integration Tests:  (5-8 files)
  - Screen navigation
  - Data flow
  - Full user workflows
```

---

## 🎯 Stage 12 关键成功因素

### 1. 完全利用 Stage 11 的 Providers
```dart
// ✅ 正确做法
final language = ref.watch(appStateProvider.select((s) => s.sourceLanguage));

// ❌ 错误做法
// 不要创建新的 state，使用现有 Provider
```

### 2. 遵循现有的 UI 模式
```dart
// ✅ 使用共享的主题和样式
// ✅ 遵循现有的屏幕结构
// ✅ 使用现有的 Widget 组件
```

### 3. 集成错误处理
```dart
// ✅ 使用 AsyncValue.when() 处理 async providers
translationResult.when(
  data: (result) => Text(result),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => ErrorWidget(error: err),
)
```

### 4. 完整的测试覆盖
```dart
// ✅ Widget 测试每个屏幕
// ✅ Unit 测试 Provider 逻辑
// ✅ 集成测试完整的用户流程
```

---

## 📊 Stage 12 工时估算

| 任务 | 时间 | 优先级 |
|------|------|--------|
| HomeScreen | 8h | 🔴 P1 |
| VoiceInputScreen | 6h | 🔴 P1 |
| CameraScreen + OCR | 10h | 🔴 P1 |
| HistoryScreen | 6h | 🟡 P2 |
| DictionaryScreen | 8h | 🟡 P2 |
| ConversationScreen | 8h | 🟡 P3 |
| SettingsScreen | 4h | 🟡 P3 |
| 单元测试 | 12h | 🟢 P4 |
| 集成测试 | 8h | 🟢 P4 |
| **总计** | **70h** | - |

---

## ✅ Stage 12 完成标准

- [x] 所有7个屏幕实现完成
- [x] 所有屏幕正确集成 Providers
- [x] 70%+ 单元测试覆盖率
- [x] Widget 测试覆盖所有主要屏幕
- [x] 集成测试覆盖主要用户流程
- [x] 0个编译错误
- [x] 生产级代码质量
- [x] 完整的错误处理
- [x] 国际化准备

---

## 🚀 立即开始 Stage 12！

**第一步**: 创建 HomeScreen 架构  
**第二步**: 集成 Providers  
**第三步**: 实现 UI  
**第四步**: 编写单元测试  
**第五步**: 重复上述步骤至其他屏幕  

---

**准备好了吗？让我们开始Stage 12! 🎯**
