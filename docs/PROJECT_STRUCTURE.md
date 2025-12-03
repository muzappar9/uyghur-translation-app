# 公益维吾尔语翻译App - 项目结构

## Flutter项目 (lib/)

\`\`\`
lib/
├── main.dart                    # 入口 + MaterialApp + 路由 + i18n + RTL
├── i18n/
│   └── localizations.dart       # t(key)函数 + zh/ug键值Map
├── screens/
│   ├── splash_screen.dart       # 启动页
│   ├── onboarding_screen.dart   # 引导页(3页轮播)
│   ├── home_screen.dart         # 主页
│   ├── translate_result_screen.dart  # 翻译结果
│   ├── conversation_screen.dart # 对话翻译
│   ├── voice_input_screen.dart  # 语音输入
│   ├── camera_screen.dart       # 相机/OCR
│   ├── ocr_result_screen.dart   # OCR结果
│   ├── dictionary_home_screen.dart   # 词典首页
│   ├── dictionary_detail_screen.dart # 词典详情
│   ├── history_screen.dart      # 历史记录
│   ├── settings_screen.dart     # 设置
│   └── language_switcher_page.dart   # 语言切换
└── widgets/
    ├── glass_card.dart          # Glass卡片组件
    ├── glass_button.dart        # Glass按钮组件
    ├── language_switch_bar.dart # 语言切换栏
    ├── mode_segmented_control.dart  # 模式Tab
    ├── chat_bubble.dart         # 聊天气泡
    └── dict_section_card.dart   # 词典分区卡片
\`\`\`

## 微信小程序 (miniprogram/)

\`\`\`
miniprogram/
├── app.js                       # 全局App + i18n初始化
├── app.json                     # 页面路由配置
├── app.wxss                     # 全局样式 + RTL类
├── utils/
│   └── i18n.js                  # t(key)函数 + 语言切换
├── i18n/
│   └── keys.json                # 完整i18n键列表
└── pages/
    ├── splash/
    │   ├── splash.js
    │   ├── splash.wxml
    │   ├── splash.wxss
    │   └── splash.json
    ├── home/
    ├── translate-result/
    ├── conversation/
    ├── voice-input/
    ├── camera/
    ├── ocr-result/
    ├── dictionary-home/
    ├── dictionary-detail/
    ├── history/
    ├── settings/
    └── language-switcher/
\`\`\`

## 文档 (docs/)

\`\`\`
docs/
├── FIGMA_COMPONENT_SPECS.md     # Figma组件变体规格表
└── PROJECT_STRUCTURE.md         # 本文档
\`\`\`

---

## RTL安全机制

### Flutter
- `Directionality` widget包裹整个App
- 语言切换时通过`setState`触发根Widget rebuild
- 使用`AlignmentDirectional`而非`Alignment`
- 使用`EdgeInsetsDirectional`而非`EdgeInsets`

### 小程序
- 全局`.rtl`类设置`direction: rtl`
- 语言切换使用`wx.reLaunch()`重建整个App
- Flexbox使用`row-reverse`适配RTL

---

## i18n键命名规范

\`\`\`
{页面}.{区块}.{元素}
例: home.input.placeholder
    settings.section.language
    dict_detail.section.basic
\`\`\`

---

## Glass风格参数

| 属性 | 值 |
|------|-----|
| Blur Sigma | 10-20px |
| 背景色(Light) | rgba(255,255,255,0.2) |
| 背景色(Dark) | rgba(0,0,0,0.3) |
| 边框 | 1px rgba(255,255,255,0.3) |
| 圆角 | 24px |
| 渐变背景 | #FF6B6B → #FF8E53 (Coral) |
