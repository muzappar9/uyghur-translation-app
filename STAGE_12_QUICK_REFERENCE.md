# ⚡ Stage 12 快速参考指南

**更新日期**: 2025年12月5日  
**版本**: 1.0  
**项目进度**: 30%

---

## 🎯 核心功能速查

### HomeScreen ✅

```dart
// 文本字符计数
Text('${_textController.text.length} characters')

// 清空按钮
if (_textController.text.isNotEmpty)
  GestureDetector(onTap: () => setState(() => _textController.clear()))

// 加载对话框
showDialog(builder: (_) => Dialog(child: CircularProgressIndicator()))

// 按钮禁用
Opacity(
  opacity: _textController.text.trim().isEmpty ? 0.5 : 1.0,
  child: GlassButton(
    onPressed: _textController.text.trim().isEmpty ? null : _onTranslate,
  ),
)

// 异步翻译
ref.read(currentTranslationProvider.notifier)
  .translate(text, source, target)
  .then((_) { /* 导航 */ })
  .catchError((e) { /* 错误 */ });
```

### VoiceInputScreen ✅

```dart
// 权限检查
if (!_hasPermission) {
  await _checkPermission();
  if (!_hasPermission) return;
}

// 字符计数
Text('${_recognizedText.length} characters')

// 动画控制
_scaleController.repeat(reverse: true);

// 语言选择
void _switchLanguage(String lang) {
  setState(() => _selectedLanguage = lang);
}

// 同步翻译提交
// 与 HomeScreen 完全相同的模式
```

### CameraScreen ✅

```dart
// 相机初始化
_cameras = await availableCameras();
_cameraController = CameraController(_cameras[index], ResolutionPreset.high);

// OCR识别
final recognizedText = await _textRecognizer.processImage(inputImage);

// 图片处理
Future<void> _processImage(String imagePath) async {
  // 识别 → 保存 → 导航
}

// 文字预览
Text('${_extractedText.length} characters')

// 条件显示翻译按钮
if (_extractedText.isNotEmpty)
  GlassButton(onPressed: _submitTranslation)
```

### HistoryScreen ✅

```dart
// 搜索过滤
final filteredHistory = _searchQuery.isEmpty
    ? history
    : history.where((t) {
        final q = _searchQuery.toLowerCase();
        return t.sourceText.toLowerCase().contains(q) ||
               t.targetText.toLowerCase().contains(q);
      }).toList();

// 搜索清空
suffixIcon: _searchQuery.isNotEmpty
    ? GestureDetector(
        onTap: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
        child: const Icon(Icons.clear),
      )
    : null,

// 编辑历史项
_isEditing
    ? TextField(controller: _correctionController)
    : Text(widget.translated)

// 复制到剪贴板
onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Copied to clipboard')),
  );
}

// 删除操作
showDialog(builder: (_) => AlertDialog(...))
```

---

## 🔧 常用代码片段

### 加载对话框

```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        const SizedBox(height: 16),
        Text('Translating...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        )),
      ],
    ),
  ),
);
```

### 异步翻译模式

```dart
ref.read(currentTranslationProvider.notifier)
  .translate(text, sourceLanguage, targetLanguage)
  .then((_) {
    // 关闭加载
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // 导航
    if (mounted) {
      context.push('/translate_result').then((_) {
        // 成功反馈
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Translation saved to history'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  })
  .catchError((error) {
    // 关闭加载
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // 错误反馈
    if (mounted) {
      final errorMessage = app_error_handler.ErrorHandler()
        .handleException(error, StackTrace.current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  });
```

### 按钮禁用管理

```dart
Opacity(
  opacity: _textController.text.trim().isEmpty ? 0.5 : 1.0,
  child: GlassButton(
    text: 'Translate',
    icon: Icons.translate,
    onPressed: _textController.text.trim().isEmpty ? null : _onTranslate,
    textColor: Colors.white,
  ),
)
```

### 搜索过滤

```dart
String _searchQuery = '';

// 在 TextField 中
onChanged: (value) {
  setState(() {
    _searchQuery = value;
  });
}

// 在列表构建中
final filtered = _searchQuery.isEmpty
    ? items
    : items.where((item) {
        final q = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
               item.description.toLowerCase().contains(q);
      }).toList();
```

### 删除确认对话框

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Delete'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          // 执行删除
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deleted'),
              backgroundColor: Colors.red,
            ),
          );
        },
        child: const Text('Delete'),
      ),
    ],
  ),
);
```

---

## 📱 屏幕导航流

```
HomeScreen
  ├─ TextField → 输入文本
  ├─ [Mic] → VoiceInputScreen
  ├─ [Camera] → CameraScreen
  ├─ [History] → HistoryScreen
  └─ [Translate] → TranslateResultScreen

VoiceInputScreen
  ├─ [Mic Button] → 开始/停止录音
  ├─ [Language] → 选择语言
  ├─ [Cancel] → 返回 HomeScreen
  └─ [Translate] → TranslateResultScreen

CameraScreen
  ├─ [Gallery] → 选择图片
  ├─ [Camera Button] → 拍照
  ├─ [Flip] → 切换摄像头
  └─ [Translate] → TranslateResultScreen

HistoryScreen
  ├─ [Search] → 搜索历史
  ├─ [History Item] → 编辑/复制/删除
  ├─ [Sync] → 同步待同步项目
  ├─ [Export] → 导出反馈
  └─ [Clear All] → 清空全部历史
```

---

## 🎯 Riverpod Providers 速查

```dart
// 应用状态
ref.watch(appStateProvider)  // 监听
ref.read(appStateProvider)   // 读取
ref.read(appStateProvider.notifier).setLanguage(lang)  // 修改

// 翻译历史
ref.watch(translationHistoryProvider)
ref.read(translationHistoryProvider)

// 当前翻译
ref.read(currentTranslationProvider.notifier).translate(...)

// 待同步翻译
ref.watch(pendingTranslationListProvider)
ref.read(translationServiceProvider).processPendingTranslations()
```

---

## 🎨 UI组件速查

### GlassCard

```dart
GlassCard(
  blurSigma: 15,
  padding: const EdgeInsets.all(16),
  borderRadius: 24,
  child: Container(...),
)
```

### GlassButton

```dart
GlassButton(
  text: 'Translate',
  icon: Icons.translate,
  onPressed: _onTranslate,
  textColor: Colors.white,
)
```

### 梯度背景

```dart
Container(
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
)
```

### SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 3),
  ),
)
```

---

## ⚙️ 常见调试方法

### 编译检查

```bash
# 完整分析
flutter analyze

# 编译检查
flutter pub get

# 运行检查
flutter run -v
```

### 错误处理

```dart
// 打印错误
print('Error: $e');
print('StackTrace: $stackTrace');

// 错误翻译
final msg = app_error_handler.ErrorHandler()
  .handleException(e, stackTrace);
```

### 状态调试

```dart
// 打印状态
print('Current state: $_searchQuery');

// 监听状态变化
ref.listen(provider, (prev, next) {
  print('State changed: $prev → $next');
});
```

---

## 📊 性能优化建议

### 搜索性能

```dart
// ❌ 不好: 每次构建都重新过滤
ListView.builder(
  itemCount: items.where(...).toList().length,  // 重复过滤!
  ...
)

// ✅ 好: 只在状态改变时重新过滤
final filtered = _applyFilter();
ListView.builder(itemCount: filtered.length, ...)
```

### 列表性能

```dart
// ✅ 使用 ListView.builder (不是 ListView with children)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(...),
)
```

### 动画性能

```dart
// ✅ 检查 mounted 状态
if (mounted && _isListening) {
  _rippleController2.repeat();
}
```

---

## 🐛 常见问题速解

### 问题1: "The method 'push' isn't defined"

**原因**: 缺少 go_router 导入  
**解决**:
```dart
import 'package:go_router/go_router.dart';
// 然后使用
context.push('/route_name');
```

### 问题2: "Unused import"

**原因**: 导入但未使用  
**解决**:
```dart
// 删除未使用的导入
// import 'package:unused/unused.dart';  // ❌
```

### 问题3: "The value of the field isn't used"

**原因**: 声明变量但未使用  
**解决**:
```dart
// ❌ 声明但未使用
String _unused = '';

// ✅ 使用该变量
print(_unused);
```

### 问题4: "null is not of type bool"

**原因**: 空指针访问  
**解决**:
```dart
// ✅ 检查 null
if (value != null && value) {
  // ...
}

// ✅ 使用 ?? 操作符
bool flag = value ?? false;
```

---

## 📚 文件位置参考

```
项目根目录/
├── lib/
│   ├── screens/
│   │   ├── home_screen.dart ✅
│   │   ├── voice_input_screen.dart ✅
│   │   ├── camera_screen.dart ✅
│   │   ├── history_screen.dart ✅
│   │   ├── dictionary_screen.dart ⏳
│   │   ├── conversation_screen.dart ⏳
│   │   └── settings_screen.dart ⏳
│   ├── widgets/
│   │   ├── glass_card.dart
│   │   └── glass_button.dart
│   ├── shared/
│   │   ├── providers/
│   │   │   └── app_providers.dart
│   │   └── services/
│   │       └── translation_service.dart
│   └── main.dart
└── test/
    └── integration/
        └── stage_12_screens_test.dart
```

---

## 💡 最佳实践检查清单

### 开发时检查

- [ ] 使用 try-catch 包装所有异步操作
- [ ] 检查 mounted 状态后才访问 context
- [ ] 关闭所有 dialog 和 snackbar
- [ ] 提供清晰的加载和错误状态
- [ ] 使用 setState 更新本地状态
- [ ] 使用 ref.read/watch 管理全局状态
- [ ] 添加 null 检查
- [ ] 清理资源 (controller, animation)

### 测试前检查

- [ ] 0 编译错误
- [ ] 0 编译警告
- [ ] 所有导入正确
- [ ] 所有函数都被使用
- [ ] 所有变量都被初始化
- [ ] 所有资源都被清理
- [ ] 代码符合项目风格

### 提交前检查

- [ ] 编译通过 ✅
- [ ] 所有测试通过 ✅
- [ ] 代码审查通过 ✅
- [ ] 文档更新 ✅
- [ ] 功能验证 ✅

---

## 🎓 学习资源

### Flutter 官方文档
- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)

### 项目文档
- STAGE_12_EXECUTION_COMPLETE.md
- STAGE_12_VOICE_CAMERA_COMPLETE.md
- STAGE_12_HISTORY_SCREEN_COMPLETE.md
- STAGE_12_DAY1_SUMMARY.md

---

## 📞 快速帮助

### 如何添加新功能?

1. 在对应屏幕文件中添加方法
2. 使用 ref 访问 Providers
3. 使用 setState 更新本地状态
4. 在 UI 中调用方法
5. 使用 ScaffoldMessenger 显示反馈
6. 使用 try-catch 处理异常

### 如何修复编译错误?

1. 查看错误消息
2. 检查相关文件
3. 验证导入
4. 检查拼写
5. 检查类型
6. 运行 `flutter pub get`
7. 再次编译

### 如何优化性能?

1. 使用 ListView.builder
2. 使用 const 构造函数
3. 避免重复计算
4. 缓存结果
5. 延迟加载数据
6. 使用 shouldRebuild 优化

---

**快速参考指南 v1.0**  
**最后更新**: 2025年12月5日  
**维护者**: AI Assistant  
**反馈**: 在 STAGE_12_* 文件中报告

**保存此文档以便快速查阅！** 📌
