# 公益维吾尔语翻译App - 项目结构

## ZIP 文件树

\`\`\`
uyghur-translator-app/
├── lib/
│   ├── main.dart                           # 入口 + MaterialApp + 路由 + RTL Wrapper
│   ├── i18n/
│   │   └── localizations.dart              # 220+ i18n键 (zh/ug完全镜像)
│   ├── screens/
│   │   ├── splash_screen.dart              # 启动页
│   │   ├── onboarding_screen.dart          # 引导页 (3页轮播)
│   │   ├── home_screen.dart                # 首页 (翻译输入)
│   │   ├── translate_result_screen.dart    # 翻译结果
│   │   ├── conversation_screen.dart        # 对话翻译
│   │   ├── voice_input_screen.dart         # 语音输入 (带波纹动画)
│   │   ├── camera_screen.dart              # 相机拍照
│   │   ├── ocr_result_screen.dart          # OCR结果
│   │   ├── dictionary_home_screen.dart     # 词典首页
│   │   ├── dictionary_detail_screen.dart   # 词典详情
│   │   ├── history_screen.dart             # 历史记录 (含RL钩子)
│   │   ├── settings_screen.dart            # 设置
│   │   └── language_switcher_page.dart     # 语言切换
│   └── widgets/
│       ├── glass_card.dart                 # Glass卡片 (sigma:15 + Coral渐变)
│       ├── glass_button.dart               # Glass按钮
│       ├── language_switch_bar.dart        # 语言切换栏
│       ├── mode_segmented_control.dart     # 模式Tab控件
│       ├── chat_bubble.dart                # 聊天气泡
│       └── dict_section_card.dart          # 词典分区卡片
├── miniprogram/
│   ├── app.js / app.json / app.wxss        # 小程序全局配置
│   ├── utils/
│   │   └── i18n.js                         # t(key) 函数
│   └── pages/
│       ├── splash/ (wxml/wxss/js/json)
│       ├── onboarding/
│       ├── home/
│       ├── translate-result/
│       ├── conversation/
│       ├── voice-input/
│       ├── camera/
│       ├── ocr-result/
│       ├── dictionary-home/
│       ├── dictionary-detail/
│       ├── history/
│       ├── settings/
│       └── language-switcher/
├── docs/
│   ├── figma-component-variants.csv        # Figma组件变体表 (17组件)
│   └── i18n-keys.json                      # 完整i18n键列表
├── pubspec.yaml                            # Flutter依赖
└── README.md                               # 测试命令
\`\`\`

## 关键代码片段

### main.dart (RTL Wrapper)
\`\`\`dart
// RTL安全重建：语言切换时rebuild根Widget
builder: (context, child) {
  final locale = Localizations.localeOf(context);
  final isRTL = locale.languageCode == 'ug';
  return Directionality(
    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
    child: Theme(
      data: ThemeData(
        fontFamily: isRTL ? 'Noto Sans Arabic Uyghur' : null,
        // RTL时Row自动镜像
      ),
      child: child!,
    ),
  );
}
\`\`\`

### i18n/localizations.dart (220+ 键)
\`\`\`dart
static const Map<String, Map<String, String>> _translations = {
  'zh': {
    'splash.loading': '',
    'onboarding.welcome': '',
    // ... 110+ 中文键
    'dict_detail.section.examples': '',
    'dict_detail.section.related': '',
    'dict_detail.label.source': '',
    'dict_detail.action.read': '',
    'dict_detail.action.copy': '',
    'dict_detail.action.favorite': '',
    'history.rl.exported': '',
  },
  'ug': {
    // 完全镜像zh的所有键
    'splash.loading': '',
    'onboarding.welcome': '',
    // ... 110+ 维吾尔语键
  },
};
\`\`\`

### voice_input_screen.dart (波纹动画)
\`\`\`dart
// 三层波纹动画 scale 1.0→1.5, 500ms
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return Transform.scale(
      scale: 1.0 + (_animationController.value * 0.5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.3 - _animationController.value * 0.3),
        ),
      ),
    );
  },
)
\`\`\`

---

## Figma CSV 前5行

| Component Name | Variants | Figma Import Notes |
|----------------|----------|-------------------|
| GlassCard | LTR/Default \| RTL/Mirror \| Light/Blur15 \| Dark/Blur15 \| Gradient/Coral | Auto Layout: Vertical, Padding 16px, Corner Radius 24px, Background Blur sigma:15, Fill: rgba(255,255,255,0.8) or LinearGradient(#FF7F50→#FFFFFF,0.8), Border: 0.5px white@50% |
| GlassButton | LTR/Default \| RTL/Mirror \| Light/Small \| Light/Medium \| Light/Large \| Dark/Small \| Dark/Medium \| Dark/Large \| Pressed \| Disabled \| Loading \| CoralGradient | Auto Layout: Horizontal, H:Center V:Center, Padding 14x20, Corner Radius 16px, Blur sigma:15, Icon+Text frame with 8px gap, States: hover opacity 0.9, pressed scale 0.98 |
| LanguageSwitchBar | LTR/ZH-UG \| RTL/UG-ZH \| Light \| Dark \| Compact \| Expanded | Auto Layout: Horizontal, Gap 12px, RTL variant reverses child order, Source Button + Swap Icon (rotate animation) + Target Button, Blur sigma:15 |
| ModeSegmentedControl | LTR/4Tabs \| RTL/4Tabs \| Light \| Dark \| Text/Selected \| Voice/Selected \| Camera/Selected \| Document/Selected | Auto Layout: Horizontal, Equal width tabs, Selected state: Coral fill + white text, Unselected: transparent + gray text, Corner Radius 12px, Indicator animation 200ms |
| ChatBubble | LTR/Left \| LTR/Right \| RTL/Left \| RTL/Right \| Light \| Dark \| WithAudio \| WithActions | Auto Layout: Vertical, Padding 12x16, Corner Radius 16px (tail on sender side), Original Text + Translated Text + Action Icons Row, RTL mirrors bubble tail position |

---

## 测试模拟

### flutter run --locale=ug 预期结果

\`\`\`
✅ RTL布局测试:
   - AppBar: 返回箭头在右侧，标题右对齐
   - LanguageSwitchBar: 源语言(维)在右，目标语言(中)在左
   - TextField: 文本从右向左输入
   - ListView: 项目从右侧开始排列
   - ChatBubble: 我方气泡在左侧，对方在右侧 (镜像)

✅ 波纹动画测试:
   - VoiceInputScreen: 麦克风按钮显示3层同心波纹
   - 波纹scale从1.0→1.5，duration 500ms
   - 波纹透明度从0.3→0 (淡出效果)
   - 录音状态时波纹持续动画

✅ Glass效果测试:
   - GlassCard: 背景模糊sigma:15可见
   - Coral渐变 (#FF7F50→white) 正确显示
   - 0.8 opacity半透明层正常

✅ 字体测试:
   - 维吾尔语文本使用 Noto Sans Arabic Uyghur
   - 阿拉伯字母正确连写
\`\`\`

### 测试命令

\`\`\`bash
# 安装依赖
flutter pub get

# 中文模式运行 (LTR)
flutter run --locale=zh

# 维吾尔语模式运行 (RTL)
flutter run --locale=ug

# 检查RTL布局
flutter run --locale=ug --debug

# 小程序开发
cd miniprogram && 微信开发者工具打开
\`\`\`

---

## RL钩子说明

HistoryScreen 包含以下RL反馈钩子:

1. **_exportRLFeedback()**: 导出全部历史翻译反馈数据
   - 触发: 点击AppBar上传图标
   - 输出: `print('export RL feedback')`

2. **_submitCorrection()**: 提交单条翻译校正
   - 触发: 点击历史项的编辑图标，修改译文后提交
   - 输出: `print('export RL feedback: correction for $translationId')`
   - 数据格式: `{ translationId, originalText, correctedText, timestamp }`

3. **用户交互流程**:
   - 用户点击历史记录的编辑按钮
   - TextField变为可编辑状态
   - 用户修改译文并提交
   - 触发RL钩子发送校正数据

---

## 下载

点击v0界面右上角 **三点菜单 → Download ZIP** 获取完整项目。

或使用 shadcn CLI:
\`\`\`bash
npx shadcn@latest add https://v0.dev/chat/xxx
