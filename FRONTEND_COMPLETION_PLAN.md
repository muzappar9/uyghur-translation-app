# 维吾尔语翻译 App 前端完成计划
**目标**：将前端从 10% 完成度提升到 90% 完成度，在接入后端 API 之前实现完整的交互逻辑和状态管理

---

## 📋 缺失部分清单（按优先级）

### **P0 - 核心基础设施（必做，影响全局）**

#### 1.1 状态管理框架
**现状**：无任何状态管理
**需要**：
- [ ] 选择状态管理方案（推荐 **Riverpod** - 易于测试且对 Flutter 最优）
- [ ] 创建 `lib/providers/` 文件夹结构
- [ ] 实现核心 StateNotifier：
  - `AppStateProvider` - 全局应用状态（当前语言、主题、用户信息）
  - `TranslationProvider` - 翻译历史和缓存
  - `VoiceInputProvider` - 语音输入状态
  - `CameraProvider` - 摄像头和 OCR 状态
  - `NavigationProvider` - 路由和导航状态

**文件清单**：
```
lib/providers/
├── app_state_provider.dart      // 全局状态
├── translation_provider.dart    // 翻译数据
├── voice_input_provider.dart    // 语音输入
├── camera_provider.dart         // 摄像头
├── history_provider.dart        // 历史记录
└── settings_provider.dart       // 设置
```

**预期工作量**：6-8 小时

---

#### 1.2 导航和路由管理
**现状**：使用基础 Navigator.pushNamed()，无深度链接支持
**需要**：
- [ ] 升级到 **go_router**（推荐）或保持 Named Routes
- [ ] 实现路由守卫（如需要登录检查）
- [ ] 创建路由配置文件 `lib/routes/app_routes.dart`
- [ ] 实现深度链接支持（如 `uyghur-translator://translate?text=hello`）
- [ ] 页面过渡动画配置

**文件清单**：
```
lib/routes/
├── app_routes.dart              // 路由定义
├── route_names.dart             // 路由常量
└── route_guard.dart             // 路由守卫
```

**预期工作量**：4-6 小时

---

### **P1 - 数据持久化（必做，保留用户数据）**

#### 2.1 本地数据库
**现状**：无任何本地存储
**需要**：
- [ ] 集成 **sqflite** 或 **hive**
- [ ] 创建 `lib/database/` 数据库层
- [ ] 实现数据模型类（Models）：
  - `TranslationHistory` - 翻译历史
  - `SavedDictionary` - 收藏词汇
  - `UserPreferences` - 用户偏好
  - `CacheData` - 离线缓存

**数据库表设计**：
```sql
-- translations (翻译历史)
CREATE TABLE translations (
  id TEXT PRIMARY KEY,
  sourceText TEXT,
  targetText TEXT,
  sourceLang TEXT,
  targetLang TEXT,
  timestamp DATETIME,
  isFavorite BOOLEAN
);

-- saved_words (收藏词汇)
CREATE TABLE saved_words (
  id TEXT PRIMARY KEY,
  word TEXT,
  definition TEXT,
  language TEXT,
  addedDate DATETIME
);

-- user_settings (用户设置)
CREATE TABLE user_settings (
  key TEXT PRIMARY KEY,
  value TEXT
);
```

**文件清单**：
```
lib/database/
├── database_service.dart        // 数据库单例
├── models/
│   ├── translation.dart
│   ├── saved_word.dart
│   └── user_preferences.dart
└── migrations/
    └── schema.dart
```

**预期工作量**：8-10 小时

---

#### 2.2 SharedPreferences（简单配置）
**现状**：无
**需要**：
- [ ] 集成 **shared_preferences**
- [ ] 存储：
  - 当前语言设置
  - 主题（亮/暗）
  - 用户偏好设置
  - App 首次启动标志

**文件清单**：
```
lib/services/
└── preference_service.dart      // SharedPreferences 包装
```

**预期工作量**：2-3 小时

---

### **P2 - 屏幕交互逻辑（关键功能实现）**

#### 3.1 HomeScreen（主页）
**现状**：UI 完整但无交互逻辑
**需要完成**：
- [ ] 文本输入验证
  - 输入为空时禁用翻译按钮
  - 输入长度限制（如 5000 字符）
  - 实时字符计数显示
  
- [ ] 翻译模式切换（ModeSegmentedControl）
  - 文本翻译模式
  - 语音输入模式
  - 图像识别模式
  - 对话模式
  - 各模式显示不同的 UI 元素
  
- [ ] 语言交换按钮逻辑
  - 交换源语言和目标语言
  - 交换输入框内容（如已有）
  - 动画效果（旋转交换图标）
  
- [ ] 按钮事件处理
  - 翻译按钮 → 调用 API（暂时 Mock）
  - 麦克风按钮 → 跳转到语音输入
  - 摄像头按钮 → 跳转到摄像头
  - 清除按钮 → 清空输入框

**文件修改**：
```
lib/screens/home_screen.dart
lib/providers/translation_provider.dart      // 新建
lib/models/translation_request.dart          // 新建
```

**预期工作量**：6-8 小时

---

#### 3.2 VoiceInputScreen（语音输入）
**现状**：有 UI 动画但无实际功能
**需要完成**：
- [ ] 集成 **speech_to_text** 或 **flutter_sound**
- [ ] 实现麦克风权限请求
- [ ] 语音录制状态管理：
  - 未开始
  - 录制中
  - 已停止
  - 处理中
  
- [ ] 波形动画与实际音频关联
- [ ] 识别结果显示
- [ ] 重新录制功能
- [ ] 识别结果提交到翻译

**文件清单**：
```
lib/screens/voice_input_screen.dart         // 修改
lib/services/speech_service.dart            // 新建
lib/providers/voice_input_provider.dart     // 修改
lib/models/speech_recognition.dart          // 新建
```

**依赖包**：
```yaml
speech_to_text: ^6.1.0
permission_handler: ^11.0.0
```

**预期工作量**：10-12 小时

---

#### 3.3 CameraScreen（摄像头 + OCR）
**现状**：UI 框架，无摄像头集成
**需要完成**：
- [ ] 集成 **camera** 插件
- [ ] 实现摄像头权限请求
- [ ] 拍照功能
- [ ] 图像裁剪/编辑（可选高级功能）
- [ ] 本地 OCR 识别（**google_ml_kit** 或 **tesseract**）
- [ ] OCR 结果展示
- [ ] 识别文本提交到翻译

**文件清单**：
```
lib/screens/camera_screen.dart              // 修改
lib/services/camera_service.dart            // 新建
lib/services/ocr_service.dart               // 新建
lib/providers/camera_provider.dart          // 修改
lib/models/ocr_result.dart                  // 新建
```

**依赖包**：
```yaml
camera: ^0.10.0
google_mlkit_text_recognition: ^0.8.0
permission_handler: ^11.0.0
image_picker: ^1.0.0
```

**预期工作量**：12-16 小时

---

#### 3.4 TranslateResultScreen（翻译结果）
**现状**：UI 完整但无数据绑定
**需要完成**：
- [ ] 接收翻译数据并显示
- [ ] 实现"复制"按钮（复制到剪贴板）
- [ ] 实现"朗读"功能
  - 源语言朗读
  - 目标语言朗读
  - 集成 **flutter_tts**
  
- [ ] 实现"保存"功能
  - 保存到翻译历史
  - 标记为收藏
  - 显示保存状态反馈
  
- [ ] 实现"分享"按钮
  - 分享翻译结果
  - 集成 **share_plus**
  
- [ ] 返回按钮逻辑

**文件清单**：
```
lib/screens/translate_result_screen.dart    // 修改
lib/services/text_to_speech_service.dart    // 新建
lib/providers/translation_provider.dart     // 修改
lib/models/translation_result.dart          // 新建
```

**依赖包**：
```yaml
flutter_tts: ^4.0.2
share_plus: ^7.0.0
clipboard: ^0.1.3
```

**预期工作量**：8-10 小时

---

#### 3.5 HistoryScreen（翻译历史）
**现状**：UI 框架，无数据加载
**需要完成**：
- [ ] 从数据库加载翻译历史列表
- [ ] 实现搜索/过滤功能
  - 按文本搜索
  - 按日期筛选
  - 按语言对筛选
  
- [ ] 实现删除功能
  - 单项删除
  - 批量删除
  - 删除确认对话框
  
- [ ] 实现收藏功能
  - 标记/取消标记收藏
  - 单独的收藏列表
  
- [ ] 点击历史项 → 重新翻译
- [ ] 分页或虚拟滚动（处理大数据）

**文件清单**：
```
lib/screens/history_screen.dart             // 修改
lib/providers/history_provider.dart         // 修改
lib/widgets/history_item.dart               // 新建
```

**预期工作量**：8-10 小时

---

#### 3.6 DictionaryScreen（词典）
**现状**：UI 框架，无数据
**需要完成**：
- [ ] 实现词汇搜索功能
  - 实时搜索建议
  - 模糊匹配
  
- [ ] 词汇详情页面
  - 定义、例句、发音、同义词
  
- [ ] 收藏词汇功能
- [ ] 发音播放

**文件清单**：
```
lib/screens/dictionary_home_screen.dart     // 修改
lib/screens/dictionary_detail_screen.dart   // 修改
lib/providers/dictionary_provider.dart      // 新建
lib/services/dictionary_service.dart        // 新建
lib/models/dictionary_entry.dart            // 新建
```

**预期工作量**：8-10 小时

---

#### 3.7 ConversationScreen（对话）
**现状**：UI 框架，无状态管理
**需要完成**：
- [ ] 实现会话数据模型
- [ ] 消息列表显示
- [ ] 输入和发送消息
- [ ] 消息气泡样式（发送/接收不同）
- [ ] 实时更新和滚动到最新消息
- [ ] 本地消息保存

**文件清单**：
```
lib/screens/conversation_screen.dart        // 修改
lib/providers/conversation_provider.dart    // 新建
lib/models/conversation.dart                // 新建
lib/models/message.dart                     // 新建
lib/widgets/message_bubble.dart             // 修改
```

**预期工作量**：8-10 小时

---

#### 3.8 SettingsScreen（设置）
**现状**：UI 框架，无功能
**需要完成**：
- [ ] 语言切换
  - 从提供商读取当前语言
  - 保存选择到 SharedPreferences
  - 立即应用（整个应用切换）
  
- [ ] 主题切换（亮/暗）
  - 保存选择
  - 应用主题
  
- [ ] 其他设置项
  - 文本大小
  - 朗读速度
  - 历史记录导出/清空
  - 关于应用
  - 反馈/帮助

**文件清单**：
```
lib/screens/settings_screen.dart            // 修改
lib/providers/app_state_provider.dart       // 修改
lib/services/theme_service.dart             // 新建
```

**预期工作量**：6-8 小时

---

#### 3.9 其他屏幕
- [ ] SplashScreen - 品牌展示和初始化检查
- [ ] OnboardingScreen - 首次启动引导
- [ ] LanguageSwitcherPage - 专门的语言选择界面

**预期工作量**：4-6 小时

---

### **P3 - 错误处理和用户反馈**

#### 4.1 全局错误处理
**现状**：无
**需要**：
- [ ] 创建 `lib/models/app_exception.dart`
  - 网络错误异常
  - 验证错误异常
  - 权限错误异常
  - 通用异常
  
- [ ] 实现全局错误日志
- [ ] 用户友好的错误提示（SnackBar/Dialog）
- [ ] 错误恢复机制（重试按钮）

**文件清单**：
```
lib/models/app_exception.dart
lib/services/error_handler.dart             // 新建
lib/widgets/error_dialog.dart               // 新建
```

**预期工作量**：4-6 小时

---

#### 4.2 Loading States（加载状态）
**现状**：无加载指示器
**需要**：
- [ ] 全局 Loading Widget
- [ ] 异步操作时显示 Loading
- [ ] Skeleton Loaders（可选高级功能）
- [ ] 加载超时提示

**文件清单**：
```
lib/widgets/loading_indicator.dart          // 新建
lib/widgets/skeleton_loader.dart            // 新建（可选）
```

**预期工作量**：3-4 小时

---

#### 4.3 Empty States（空状态）
**现状**：列表为空时无提示
**需要**：
- [ ] 历史记录为空提示
- [ ] 搜索结果为空提示
- [ ] 收藏列表为空提示

**文件清单**：
```
lib/widgets/empty_state.dart                // 新建
```

**预期工作量**：2-3 小时

---

### **P4 - 代码质量和测试**

#### 5.1 单元测试
**现状**：仅有 widget test 骨架
**需要**：
- [ ] 数据模型测试（Models）
- [ ] 业务逻辑测试（Services）
- [ ] 提供者测试（StateNotifiers）
- [ ] 至少 60% 代码覆盖率

**文件清单**：
```
test/
├── models/
├── services/
├── providers/
└── mocks/
```

**预期工作量**：12-16 小时

---

#### 5.2 集成测试
**现状**：无
**需要**：
- [ ] 关键用户流测试（翻译流程）
- [ ] 页面导航测试
- [ ] 状态管理测试

**文件清单**：
```
integration_test/
├── translation_flow_test.dart
├── navigation_test.dart
└── voice_input_test.dart
```

**预期工作量**：10-12 小时

---

#### 5.3 代码规范和 Lint 修复
**现状**：60+ 弃用 API 警告，print 调试语句
**需要**：
- [ ] 替换 `withOpacity()` → `.withValues()`（50+ 处）
- [ ] 更新 `Radio` 小部件（6 处）
- [ ] 移除 `print()` 调试语句（已部分完成）
- [ ] 添加缺少的 `const` 构造函数
- [ ] 运行 `dart analyze` 达到零警告

**预期工作量**：4-6 小时

---

### **P5 - 性能优化（可选高级）**

#### 6.1 缓存和离线支持
- [ ] 实现 HTTP 缓存策略
- [ ] 离线模式支持
- [ ] 智能数据预加载

**预期工作量**：6-8 小时

---

#### 6.2 内存和渲染优化
- [ ] ListView 虚拟化（大列表）
- [ ] 图像优化
- [ ] 帧率优化

**预期工作量**：4-6 小时

---

## 📦 需要新增的 Pub 依赖包

```yaml
# 状态管理
riverpod: ^2.4.0
flutter_riverpod: ^2.4.0

# 路由
go_router: ^12.0.0

# 本地存储
sqflite: ^2.2.8
hive: ^2.2.3
shared_preferences: ^2.2.0

# 语音和媒体
speech_to_text: ^6.1.0
flutter_tts: ^4.0.2
camera: ^0.10.0

# OCR
google_mlkit_text_recognition: ^0.8.0

# 工具
permission_handler: ^11.0.0
share_plus: ^7.0.0
image_picker: ^1.0.0
clipboard: ^0.1.3
get_it: ^7.5.0           # 依赖注入
logger: ^2.0.0           # 日志
dio: ^5.3.0              # HTTP（为后端 API 预准备）
```

---

## 🎯 实现顺序（推荐）

### 第 1 阶段（基础设施）- 第 1-2 周
1. **状态管理** (Riverpod) → 6-8 小时
2. **本地数据库** (Sqflite) → 8-10 小时
3. **SharedPreferences** → 2-3 小时
4. **路由管理** (go_router) → 4-6 小时

**小计**：20-27 小时 | 1 周左右

---

### 第 2 阶段（核心屏幕）- 第 2-3 周
1. **HomeScreen** 交互 → 6-8 小时
2. **VoiceInputScreen** 语音输入 → 10-12 小时
3. **CameraScreen + OCR** → 12-16 小时
4. **TranslateResultScreen** 结果展示 → 8-10 小时

**小计**：36-46 小时 | 1.5-2 周

---

### 第 3 阶段（辅助屏幕）- 第 3-4 周
1. **HistoryScreen** → 8-10 小时
2. **DictionaryScreen** → 8-10 小时
3. **ConversationScreen** → 8-10 小时
4. **SettingsScreen** → 6-8 小时
5. **其他屏幕** → 4-6 小时

**小计**：34-44 小时 | 1.5-2 周

---

### 第 4 阶段（质量）- 第 4 周
1. **错误处理** → 4-6 小时
2. **加载/空状态** → 5-7 小时
3. **代码规范修复** → 4-6 小时
4. **单元测试** → 12-16 小时
5. **集成测试** → 10-12 小时

**小计**：35-47 小时 | 1.5-2 周

---

## 📊 工作量总结

| 阶段 | 工作量 | 时间 | 完成度 |
|-----|-------|------|--------|
| 第 1 阶段（基础设施） | 20-27 h | 1 周 | 15% → 25% |
| 第 2 阶段（核心屏幕） | 36-46 h | 1.5-2 周 | 25% → 50% |
| 第 3 阶段（辅助屏幕） | 34-44 h | 1.5-2 周 | 50% → 75% |
| 第 4 阶段（质量） | 35-47 h | 1.5-2 周 | 75% → 90% |
| **总计** | **125-164 h** | **6-8 周** | **10% → 90%** |

---

## ✅ 完成标准（Definition of Done）

对于每个模块，完成标准为：

1. ✅ 功能代码完成（>= 90% 代码覆盖）
2. ✅ 单元测试编写（>= 80% 覆盖率）
3. ✅ 集成测试验证
4. ✅ 代码审查通过（无 lint 警告）
5. ✅ 性能基准测试（帧率 >= 60 fps）
6. ✅ 文档更新（JSDoc/代码注释）
7. ✅ Git commit 信息清晰

---

## 🚀 集成后端 API 准备

完成上述工作后，集成后端 API 时只需：

1. 创建 `lib/services/api_service.dart` - HTTP 客户端
2. 修改 `lib/providers/` - 将 Mock 数据替换为 API 调用
3. 添加网络请求的错误处理
4. 添加请求/响应拦截器（Token、日志等）
5. 更新集成测试（使用 Mock Server）

---

## 📝 注意事项

- **Mock 数据**：在第 2 阶段开始前，为每个屏幕创建 Mock 数据，使前端可以独立开发
- **并行开发**：多个屏幕可以并行开发，因为它们相对独立
- **代码复用**：充分利用 Glass 组件库和现有的 Widget
- **国际化**：所有文本使用 `t(context, 'key')` 方式，已经完全支持
- **测试优先**：至少为核心业务逻辑（Services、Providers）编写测试

---

**生成日期**：2025年12月4日
**项目**：维吾尔语翻译 App
**状态**：前端结构完整，待交互逻辑实现
