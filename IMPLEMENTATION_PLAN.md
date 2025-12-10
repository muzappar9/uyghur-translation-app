# 🎯 项目恢复实施计划

## 项目目标

**维吾尔语-中文双语翻译应用**，功能包括：
- ✅ 文本翻译 (维吾尔语 ↔ 中文)
- ✅ OCR 图片文字识别
- ✅ 语音输入
- ⚠️ 翻译历史记录存储 (需要数据库)
- ⚠️ 收藏功能 (需要数据库)
- ⚠️ RL 反馈导出 (需要数据库)

---

## 📊 当前状态 vs 目标状态

| 模块 | 当前状态 | 目标状态 | 差距 |
|------|----------|----------|------|
| UI 层 | ✅ 13 个页面 | ✅ 完成 | - |
| Glass 组件 | ✅ 6 个组件 | ✅ 完成 | - |
| i18n 国际化 | ✅ 220+ 键 | ✅ 完成 | - |
| 数据持久化 | ❌ 缺失 | isar_community | 需实现 |
| 翻译 API | ❌ 假数据 | DeepSeek API | 需实现 |
| 历史记录 | ⚠️ 假数据 | 真实存储 | 需连接 |

---

## 🛠️ 实施步骤

### 第一阶段：数据库集成 ✅ 已完成

#### 1.1 更新依赖 ✅
```yaml
# pubspec.yaml
dependencies:
  isar_community: ^3.3.0
  isar_community_flutter_libs: ^3.3.0
  provider: ^6.1.2
  http: ^1.2.2
  path_provider: ^2.1.4
  flutter_dotenv: ^5.2.1

dev_dependencies:
  isar_community_generator: ^3.3.0
  build_runner: ^2.4.13
```

#### 1.2 创建数据模型 ✅
- `lib/shared/models/translation_history.dart` - 翻译历史
- `lib/shared/models/dictionary_entry.dart` - 词典条目
- `lib/shared/models/app_settings.dart` - 应用设置

#### 1.3 创建数据服务 ✅
- `lib/shared/services/database_service.dart` - 数据库初始化
- `lib/shared/repositories/translation_history_repository.dart` - 历史记录仓库

---

### 第二阶段：代码生成 ⏳ 需手动执行

在 PowerShell 中运行：
```powershell
cd "d:\princip plan\ai translation\uyghur-translation-app1"
dart run build_runner build --delete-conflicting-outputs
```

这将生成：
- `translation_history.g.dart`
- `dictionary_entry.g.dart`
- `app_settings.g.dart`

---

### 第三阶段：连接 UI 到数据层

#### 3.1 修改 history_screen.dart
- 从 Repository 获取真实数据
- 实现收藏/删除功能
- 实现 RL 反馈导出

#### 3.2 修改 translate_result_screen.dart
- 保存翻译结果到数据库
- 收藏功能连接数据库

#### 3.3 修改 home_screen.dart
- 显示最近翻译
- 连接到翻译 API

---

### 第四阶段：翻译 API 集成

#### 4.1 创建翻译服务
```dart
// lib/shared/services/translation_service.dart
class TranslationService {
  final String apiKey;
  final String endpoint = 'https://api.deepseek.com/v1/chat/completions';
  
  Future<String> translate(String text, String from, String to) async {
    // 调用 DeepSeek API
  }
}
```

#### 4.2 环境变量配置
已有 `.env` 文件：
```
DEEPSEEK_API_KEY=sk-9034336091e7419b83729a18f3f38f87
DEEPSEEK_MODEL=deepseek-chat
```

---

### 第五阶段：修复弃用警告

主要修复：
1. `withOpacity` → `withValues(alpha: x)`
2. `Radio.groupValue/onChanged` → `RadioGroup`
3. `CupertinoSwitch.activeColor` → `activeThumbColor`

---

## 📋 手动执行清单

请按顺序执行：

### Step 1: 生成 Isar 代码
```powershell
cd "d:\princip plan\ai translation\uyghur-translation-app1"
dart run build_runner build --delete-conflicting-outputs
```

### Step 2: 验证编译
```powershell
flutter analyze
flutter build apk --debug
```

### Step 3: 测试运行
```powershell
flutter run
```

### Step 4: 推送到 GitHub
```powershell
.\PUSH_TO_GITHUB.ps1
```

---

## 📁 新增文件列表

```
lib/
├── shared/
│   ├── models/
│   │   ├── models.dart              # 导出
│   │   ├── translation_history.dart # 翻译历史模型
│   │   ├── dictionary_entry.dart    # 词典条目模型
│   │   └── app_settings.dart        # 应用设置模型
│   ├── services/
│   │   ├── services.dart            # 导出
│   │   └── database_service.dart    # 数据库服务
│   └── repositories/
│       ├── repositories.dart        # 导出
│       └── translation_history_repository.dart
```

---

## ⚠️ 已知问题

1. **终端无响应** - VS Code 终端有时不响应，需要手动在外部 PowerShell 中执行命令

2. **Git 冲突** - `codemagic.yaml` 可能有冲突，推送时使用 `--force`

3. **弃用警告** - 约 60+ 个弃用警告，不影响编译，后续可修复

---

## 🔗 相关资源

- [isar_community 文档](https://isar-community.dev/)
- [DeepSeek API 文档](https://platform.deepseek.com/api-docs/)
- [Flutter 本地化](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

---

*创建时间: 2025年12月8日*
