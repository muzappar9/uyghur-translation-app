# Stage 12 屏幕功能快速参考

**更新日期**: 2025-12-05  
**完成屏幕**: 6 / 8  
**编译状态**: ✅ 0 错误, 0 警告

---

## 📱 屏幕快速导览

### 1️⃣ HomeScreen (文本翻译)
**文件**: `lib/screens/home_screen.dart`  
**状态**: ✅ 100% 完成  

**功能列表**:
- [x] 文本输入框
- [x] **字符计数显示** (新增)
- [x] **清除按钮** (新增)
- [x] 源/目标语言选择
- [x] **异步翻译 API** (改进)
- [x] **加载对话框** (新增)
- [x] **按钮禁用管理** (新增)
- [x] **成功反馈** SnackBar (新增)

**快捷用法**:
```dart
// 输入文字 → 显示字符数 → 点击翻译 → 加载对话框 → 结果显示 → 成功提示
```

**关键代码**:
```dart
// 字符计数
'${_textController.text.length} characters'

// 按钮禁用
Opacity(
  opacity: _textController.text.trim().isEmpty ? 0.5 : 1.0,
  child: GlassButton(
    onPressed: _textController.text.trim().isEmpty ? null : _onTranslate,
  ),
)
```

---

### 2️⃣ VoiceInputScreen (语音输入翻译)
**文件**: `lib/screens/voice_input_screen.dart`  
**状态**: ✅ 100% 完成  

**功能列表**:
- [x] 语音识别
- [x] **字符计数显示** (新增)
- [x] **异步翻译 API** (改进)
- [x] **加载对话框** (新增)
- [x] **导航集成** (GoRouter) (新增)
- [x] 权限管理
- [x] **权限重新验证** (改进)
- [x] 语言切换

**快捷用法**:
```dart
// 点击麦克风 → 权限检查 → 语音识别 → 显示文字 → 显示字符数 → 翻译 → 导航
```

**关键代码**:
```dart
// 导航到结果屏幕
context.push('/translate_result')

// 权限重新验证
final status = await Permission.microphone.request();
```

---

### 3️⃣ CameraScreen (OCR 翻译)
**文件**: `lib/screens/camera_screen.dart`  
**状态**: ✅ 100% 完成  

**功能列表**:
- [x] 相机预览
- [x] 文字识别 (OCR)
- [x] 文字预览
- [x] **字符计数** (新增)
- [x] **异步翻译 API** (改进)
- [x] **加载对话框** (新增)
- [x] **动态按钮显示** (新增)
- [x] **错误处理** (改进)

**快捷用法**:
```dart
// 打开相机 → 拍照 → OCR 识别 → 显示文字+字符数 → 翻译 → 导航
```

**关键代码**:
```dart
// 条件显示翻译按钮
if (_extractedText.isNotEmpty)
  GlassButton(
    text: 'Translate',
    onPressed: _submitTranslation,
  )
```

---

### 4️⃣ HistoryScreen (翻译历史)
**文件**: `lib/screens/history_screen.dart`  
**状态**: ✅ 100% 完成  

**功能列表**:
- [x] 历史记录列表
- [x] **实时搜索** (新增)
- [x] **双向过滤** (新增) - 原文 + 译文
- [x] **搜索清除** (新增)
- [x] **编辑操作** (新增)
- [x] **复制操作** (新增)
- [x] **删除操作** (新增)
- [x] **确认对话** (新增)

**快捷用法**:
```dart
// 搜索文字 → 实时过滤 → 显示清除按钮 → 编辑/复制/删除 → 确认 → 反馈
```

**关键代码**:
```dart
// 搜索过滤
final filtered = _searchQuery.isEmpty
  ? items
  : items.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.sourceText.toLowerCase().contains(q) ||
             item.targetText.toLowerCase().contains(q);
    }).toList();

// 复制到剪贴板
Clipboard.setData(ClipboardData(text: item.targetText));
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Copied to clipboard')),
);
```

---

### 5️⃣ ConversationScreen (双语对话)
**文件**: `lib/screens/conversation_screen.dart`  
**状态**: ✅ 100% 完成  

**功能列表**:
- [x] 消息列表
- [x] **字符计数** (新增)
- [x] **消息输入清除** (新增)
- [x] **异步翻译 API** (改进)
- [x] **加载对话框** (新增)
- [x] **发送按钮禁用** (新增)
- [x] **增强消息气泡** (新增)
- [x] **清除消息菜单** (新增)
- [x] **语言交换菜单** (新增)
- [x] **导出菜单** (新增)

**快捷用法**:
```dart
// 输入消息 → 显示字符数 → 翻译 → 显示加载 → 更新消息 → Mock 回复 → 自动滚动
```

**关键代码**:
```dart
// 消息气泡样式
Container(
  decoration: BoxDecoration(
    color: message.isOwn ? Colors.blue.withOpacity(0.3) : Colors.cyan.withOpacity(0.2),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    children: [
      Text(message.originalText),
      Text('${message.originalText.length} characters'),
      Divider(),
      Text(message.translatedText, style: TextStyle(fontStyle: FontStyle.italic)),
    ],
  ),
)

// 清除消息
session.copyWith(messages: [], updatedAt: DateTime.now())
```

---

### 6️⃣ SettingsScreen (应用设置)
**文件**: `lib/screens/settings_screen.dart`  
**状态**: ✅ 100% 完成  

**功能列表**:
- [x] **语言选择** (改进) - 3 种语言
- [x] **深色模式** (改进) - 即时反馈
- [x] **通知设置** (新增) - 启用/禁用
- [x] **缓存管理** (新增) - 显示大小 + 清除
- [x] **About 页面** (增强) - 版本 + 构建号
- [x] **隐私政策** (新增) - 链接
- [x] **服务条款** (新增) - 链接
- [x] **联系方式** (新增) - 显示 email

**快捷用法**:
```dart
// 选择语言 → 成功反馈 → 或
// 切换深色模式 → 成功反馈 → 或
// 清除缓存 → 确认对话 → 清除完成 → 反馈
```

**关键代码**:
```dart
// 语言选择并处理
_handleLanguageChange(appStateNotifier, 'ug', 'Uyghur')
  → appStateNotifier.setLanguage('ug')
  → SnackBar('Language changed to Uyghur')

// 清除缓存
session.copyWith(
  messages: [],
  updatedAt: DateTime.now(),
)
```

---

### 7️⃣ DictionaryHomeScreen (字典搜索)
**文件**: `lib/screens/dictionary_home_screen.dart`  
**状态**: ⏳ 60% 完成  

**已完成功能**:
- [x] **搜索功能** (新增)
- [x] **搜索结果计数** (新增)
- [x] **清除搜索** (新增)
- [x] **收藏夹切换** (新增)

**待完成功能**:
- [ ] 详细的单词信息
- [ ] 例句显示
- [ ] 发音播放

**快捷用法**:
```dart
// 搜索单词 → 实时过滤 → 显示计数 → 点击收藏 → 反馈
```

---

### 8️⃣ DictionaryDetailScreen (字典详情)
**文件**: `lib/screens/dictionary_detail_screen.dart`  
**状态**: ⏳ 40% 完成  

**框架存在**:
- [x] 基本结构
- [x] 颜色方案

**待完成功能**:
- [ ] 词义详情显示
- [ ] 例句列表
- [ ] 同义词/反义词
- [ ] 发音音频
- [ ] 词性分类

---

## 🎨 统一的 UI 模式

### 颜色方案
```dart
// 主梯度色
LinearGradient(
  colors: [
    Color(0xFFFF6B6B),  // 红色
    Color(0xFFFF8E53),  // 橙色
  ],
)

// 按钮禁用
Opacity(0.5)  // 透明度降低

// SnackBar 颜色
成功: Colors.green
错误: Colors.red
信息: Colors.black87 或默认
```

### 交互反馈
```dart
// 成功操作
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success message'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);

// 错误操作
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error: $message'),
    backgroundColor: Colors.red,
  ),
);

// 确认操作
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      TextButton(onPressed: () { /* action */ }, child: Text('Confirm')),
    ],
  ),
);
```

---

## 🔄 异步操作完整流程

### 标准翻译流程 (用于 HomeScreen, VoiceScreen, CameraScreen, ConversationScreen)

```dart
// 1. 验证输入
if (text.isEmpty) return;

// 2. 显示加载对话框
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => Dialog(
    backgroundColor: Colors.transparent,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        SizedBox(height: 16),
        Text('Translating...'),
      ],
    ),
  ),
);

// 3. 调用翻译 API
ref.read(currentTranslationProvider.notifier)
  .translate(text, sourceLang, targetLang)
  .then((_) {
    // 4. 关闭加载对话框
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // 5. 处理结果
    if (mounted) {
      // 更新 UI
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation successful'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  })
  .catchError((error) {
    // 6. 错误处理
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (mounted) {
      final errorMessage = app_error_handler.ErrorHandler()
        .handleException(error, StackTrace.current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Translation failed: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  });
```

---

## 📊 功能对应表

| 功能 | Home | Voice | Camera | History | Conversation | Settings | Dict-Home | Dict-Detail |
|------|------|-------|--------|---------|--------------|----------|-----------|------------|
| 翻译 | ✅ | ✅ | ✅ | - | ✅ | - | - | - |
| 字符计数 | ✅ | ✅ | ✅ | ✅ | ✅ | - | - | - |
| 搜索 | - | - | - | ✅ | - | - | ✅ | - |
| 清除 | ✅ | - | - | ✅ | ✅ | ✅ | ✅ | - |
| 编辑 | - | - | - | ✅ | - | - | - | - |
| 复制 | - | - | - | ✅ | - | - | - | - |
| 删除 | - | - | - | ✅ | ✅ | ✅ | - | - |
| 收藏 | - | - | - | - | - | - | ✅ | - |
| 设置 | - | - | - | - | - | ✅ | - | - |

---

## 🚀 性能优化建议

### 当前优化
- ✅ 异步操作不阻塞 UI
- ✅ 加载状态反馈
- ✅ 错误恢复机制
- ✅ 内存泄漏预防 (dispose)

### 可进一步优化
- [ ] 分页加载历史记录
- [ ] 缓存翻译结果
- [ ] 图片压缩 (CameraScreen)
- [ ] 语音文件缓存

---

## 🧪 测试要点

### 单元测试
```dart
// 搜索过滤测试
test('search filter works', () {
  final items = [...];
  final query = 'test';
  final result = items.where((i) => i.text.contains(query)).toList();
  expect(result.length, 1);
});
```

### 集成测试
```dart
// 翻译流程测试
testWidgets('translation flow', (tester) async {
  // 输入文字
  // 点击翻译
  // 验证加载对话框
  // 验证结果显示
  // 验证成功反馈
});
```

---

## 📚 相关文档

- [STAGE_12_COMPREHENSIVE_SUMMARY.md](./STAGE_12_COMPREHENSIVE_SUMMARY.md) - 完整总结
- [STAGE_12_CONVERSATION_COMPLETE.md](./STAGE_12_CONVERSATION_COMPLETE.md) - ConversationScreen 详情
- [STAGE_12_SETTINGS_COMPLETE.md](./STAGE_12_SETTINGS_COMPLETE.md) - SettingsScreen 详情
- [STAGE_12_HISTORY_SCREEN_COMPLETE.md](./STAGE_12_HISTORY_SCREEN_COMPLETE.md) - HistoryScreen 详情

---

## 💻 常用代码片段

### 显示 SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);
```

### 显示 AlertDialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Title'),
    content: Text('Content'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      TextButton(onPressed: () { /* action */ }, child: Text('OK')),
    ],
  ),
);
```

### 按钮禁用状态
```dart
Opacity(
  opacity: condition ? 1.0 : 0.5,
  child: GlassButton(
    onPressed: condition ? _action : null,
    text: 'Button',
  ),
)
```

### 搜索过滤
```dart
final filtered = _searchQuery.isEmpty
  ? items
  : items.where((item) {
      final q = _searchQuery.toLowerCase();
      return item.field.toLowerCase().contains(q);
    }).toList();
```

---

**快速参考更新**: 2025-12-05  
**版本**: 1.0  
**状态**: ✅ 现用版本

