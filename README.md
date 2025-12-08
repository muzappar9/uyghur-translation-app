# 公益维吾尔语翻译App

iOS 17/18 Glass风格 + 中/维双语RTL支持 + 10种Alkatip字体

## ✨ 核心特性

- 🔄 **双向翻译**: 维吾尔语 ↔ 汉语 (基于 DeepSeek API)
- 🎨 **10种Alkatip字体**: 用户可自由选择维吾尔语显示字体
- 📝 **8种汉语字体**: 思源、站酷、方正等常见字体
- 💾 **翻译历史**: 本地存储 (Isar数据库)
- 🌓 **主题切换**: 支持亮色/暗色模式
- 🗣️ **语音输入**: 语音转文字翻译
- 📷 **OCR识别**: 图片文字提取翻译
- 📚 **词典功能**: 单词查询和例句
- 📱 **跨平台**: Android、iOS、Windows

## 🚀 快速开始

### 1. 一键安装字体（推荐）

```powershell
# 自动下载所有免费开源字体
.\download_fonts.ps1

# 或仅下载维吾尔语字体（跳过汉语字体）
.\download_fonts.ps1 -SkipChinese
```

自动下载内容：
- ✅ Noto Sans Arabic (Alkatip开源替代，4种字重)
- ✅ 思源黑体/宋体 (Regular + Bold)
- ✅ 站酷快乐体

### 2. 安装依赖

```powershell
flutter pub get
```

### 3. 运行应用

```powershell
# 中文模式运行 (LTR)
flutter run --dart-define=LOCALE=zh

# 维吾尔语模式运行 (RTL)
flutter run --dart-define=LOCALE=ug
```

## 📦 字体系统

### 维吾尔语字体 (10种Alkatip变体)

| 字体 | 说明 | 推荐用途 |
|------|------|---------|
| ئالكاتىپ ئاساسى | 标准体 | 通用文本 |
| ئالكاتىپ كونا | 经典体 | 正式文档 |
| ئالكاتىپ توم | 粗体 | 标题强调 |
| ئالكاتىپ يۇملاق | 圆润体 | 轻松阅读 |
| ئالكاتىپ نازىك | 细体 | 优雅显示 |
| ئالكاتىپ بەسمە | 印刷体 | 印刷品 |
| ئالكاتىپ تارىخى | 古典体 | 古典文献 |
| ئالكاتىپ قول | 手写体 | 个人笔记 |
| ئالكاتىپ كومپيۇتېر | 计算机体 | 代码/技术 |
| ئالكاتىپ چوڭ | 大字体 | 大标题 |

**开源替代方案**: 
- `download_fonts.ps1` 自动下载 **Noto Sans Arabic** 作为免费开源替代
- 如需正版Alkatip，请访问官方网站购买

### 汉语字体 (8种)

- ✅ 思源黑体/宋体 (Adobe开源)
- ✅ 站酷快乐体 (免费)
- ⚠️ 方正楷体/黑体 (需商业授权)
- ℹ️ 微软雅黑/宋体 (系统自带)

详细安装说明: [FONT_INSTALLATION_GUIDE.md](FONT_INSTALLATION_GUIDE.md)

## 🛠️ 技术栈

- **Flutter**: 3.0.0+
- **Riverpod**: 状态管理 + 字体配置持久化
- **Isar**: 本地数据库 (翻译历史)
- **go_router**: 路由管理
- **DeepSeek API**: AI翻译引擎
- **SharedPreferences**: 用户设置存储

## 📂 项目结构

```
lib/
├── main.dart                          # 入口 + 路由 + RTL wrapper
├── core/
│   └── fonts/
│       ├── font_config.dart           # 字体配置模型 (10+8种字体)
│       └── font_config_provider.dart  # Riverpod状态管理
├── widgets/
│   ├── font_selector.dart             # 字体选择器UI
│   ├── translation_text_card.dart     # 翻译结果卡片 (带字体切换)
│   ├── glass_card.dart
│   ├── glass_button.dart
│   ├── language_switch_bar.dart
│   ├── mode_segmented_control.dart
│   ├── chat_bubble.dart
│   └── dict_section_card.dart
├── i18n/
│   └── localizations.dart             # 220+ i18n键 (zh/ug镜像)
├── screens/                           # 13个页面
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── translate_result_screen.dart
│   ├── conversation_screen.dart
│   ├── voice_input_screen.dart
│   ├── camera_screen.dart
│   ├── ocr_result_screen.dart
│   ├── dictionary_home_screen.dart
│   ├── dictionary_detail_screen.dart
│   ├── history_screen.dart
│   ├── settings_screen.dart
│   └── language_switcher_page.dart
assets/fonts/
├── alkatip/                           # 10种维吾尔语字体
└── chinese/                           # 8种汉语字体
docs/
└── figma-component-variants.csv       # Figma组件变体规格
miniprogram/                           # 微信小程序版本
```
flutter run --dart-define=LOCALE=ug

# 指定设备运行
flutter run -d chrome --dart-define=LOCALE=zh
flutter run -d ios --dart-define=LOCALE=ug

# 构建测试
flutter build apk --debug
flutter build ios --debug
\`\`\`

## RTL测试验证

1. 切换至维吾尔语后，全App方向应为RTL
2. Row组件自动镜像（使用RTLRow或Directionality）
3. 文本对齐自动适配
4. 动画方向正确（无错位）
5. Glass组件在RTL下正常渲染

## Glass风格规格

- BackdropFilter: sigma 15
- 背景: LinearGradient(Coral #FF7F50 → White, opacity 0.8)
- 圆角: 24px (Card) / 16px (Button)
- 边框: 0.5px white@50%

## Figma导入

参见 `docs/figma-component-variants.csv` 获取完整组件变体规格。
使用 Auto Layout + Background Blur effect 在 Figma 中重建组件。

## i18n键计数

- 总计: 220+ 键
- zh Map: 220 键
- ug Map: 220 键 (完全镜像)

所有键值为空字符串占位，待填充实际翻译。
