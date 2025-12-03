# 公益维吾尔语翻译App - Flutter项目骨架

iOS 17/18 Glass风格 + 中/维双语RTL支持

## 项目结构

\`\`\`
lib/
├── main.dart                 # 入口 + 路由 + RTL wrapper
├── i18n/
│   └── localizations.dart    # 220+ i18n键 (zh/ug镜像)
├── screens/                  # 13个页面
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
├── widgets/                  # 6个核心组件
│   ├── glass_card.dart
│   ├── glass_button.dart
│   ├── language_switch_bar.dart
│   ├── mode_segmented_control.dart
│   ├── chat_bubble.dart
│   └── dict_section_card.dart
docs/
└── figma-component-variants.csv  # Figma组件变体规格
miniprogram/                  # 微信小程序
├── app.js / app.json / app.wxss
├── utils/i18n.js
└── pages/                    # 13个页面
\`\`\`

## 测试命令

\`\`\`bash
# 安装依赖
flutter pub get

# 中文模式运行 (LTR)
flutter run --dart-define=LOCALE=zh

# 维吾尔语模式运行 (RTL)
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
