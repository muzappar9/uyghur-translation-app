# Figma Component Variant Specifications

## iOS 17/18 Glass风格组件导入指南

---

### 1. GlassCard

| Property | Variants | Figma Import Notes |
|----------|----------|-------------------|
| Direction | LTR / RTL | Use Auto Layout with direction swap |
| Theme | Light / Dark | Light: `rgba(255,255,255,0.2)` / Dark: `rgba(0,0,0,0.3)` |
| Blur | Standard (10px) / Heavy (20px) | Effect → Background Blur: 10-20px |
| Corner Radius | 24px default | Border Radius: 24 |
| Border | 1px `rgba(255,255,255,0.3)` | Stroke: Inside, 1px |

**Figma Setup:**
- Create Component Set with 4 variants (LTR-Light, LTR-Dark, RTL-Light, RTL-Dark)
- Use Auto Layout for content
- Add Background Blur effect layer
- Enable "Swap Direction" for RTL variants

---

### 2. GlassButton

| Property | Variants | Figma Import Notes |
|----------|----------|-------------------|
| Direction | LTR / RTL | Auto Layout direction flip |
| Size | Small / Medium / Large | Padding: 12/16/24px |
| State | Default / Pressed / Disabled | Opacity: 1.0 / 0.8 / 0.5 |
| Icon Position | Leading / Trailing / None | Auto Layout order swap |

**Figma Setup:**
- Use Component Properties for icon visibility
- Interactive Components for state transitions
- Auto Layout with 8px gap between icon and text

---

### 3. LanguageSwitchBar

| Property | Variants | Figma Import Notes |
|----------|----------|-------------------|
| Direction | LTR / RTL | Entire row mirrors for RTL |
| Active Side | Source / Target | Highlight active button |

**Figma Setup:**
- 3-column Auto Layout: [Source] [Swap Icon] [Target]
- RTL variant reverses order to: [Target] [Swap Icon] [Source]
- Swap button uses rotation animation (180° on tap)

---

### 4. ModeSegmentedControl

| Property | Variants | Figma Import Notes |
|----------|----------|-------------------|
| Direction | LTR / RTL | Tab order reverses |
| Tabs | 4 fixed (Text/Voice/Camera/Document) | Use Component instances |
| Selected | Index 0-3 | Selection indicator slides |

**Figma Setup:**
- Horizontal Auto Layout with equal distribution
- Selection indicator as separate layer with absolute position
- Interactive Components for tab switching animation

---

### 5. ChatBubble

| Property | Variants | Figma Import Notes |
|----------|----------|-------------------|
| Direction | LTR / RTL | Bubble tail + alignment flip |
| Side | Left / Right | Alignment: start / end |
| Content | Original + Translated | Stacked Auto Layout |

**Figma Setup:**
- Bubble tail: border-radius exception on one corner (8px vs 24px)
- RTL-Left = LTR-Right (mirror all properties)
- Icon positioned opposite to tail side

---

### 6. DictSectionCard

| Property | Variants | Figma Import Notes |
|----------|----------|-------------------|
| Direction | LTR / RTL | Title + content text alignment |
| Type | Basic / Sense / Examples / Related | Content layout differs |
| Collapsed | Yes / No | Height animation |

**Figma Setup:**
- GlassCard as base component
- Title uses caption style (smaller, 60% opacity)
- Content uses Auto Layout with vertical stacking
- Examples type has nested items with speak icons

---

## Global Design Tokens

\`\`\`
// Colors
$glass-light: rgba(255, 255, 255, 0.2)
$glass-dark: rgba(0, 0, 0, 0.3)
$border-light: rgba(255, 255, 255, 0.3)
$coral-gradient: linear-gradient(180deg, #FF6B6B, #FF8E53)

// Blur
$blur-standard: 10px
$blur-heavy: 20px

// Radius
$radius-card: 24px
$radius-button: 24px
$radius-chip: 16px

// Typography (占位)
$font-uyghur: 'Noto Sans Arabic Uyghur'
$font-chinese: 'PingFang SC'
\`\`\`

---

## RTL Implementation Checklist

1. [ ] All Auto Layouts have "Swap Direction" enabled
2. [ ] Icons with directional meaning (arrows) are mirrored
3. [ ] Text alignment changes from left to right
4. [ ] Bubble tails flip sides
5. [ ] Navigation back arrows rotate 180°
6. [ ] Progress indicators reverse direction

---

## Dev Mode Export Settings

- **Format:** SVG for icons, PNG @2x for complex graphics
- **Code:** React / Flutter snippets enabled
- **Spacing:** Use 4px base unit
- **Naming:** kebab-case for all layers

---

## Component Library Structure

\`\`\`
📁 Uyghur Translate App
├── 📁 Foundations
│   ├── Colors
│   ├── Typography
│   └── Effects (Blur, Shadow)
├── 📁 Components
│   ├── GlassCard
│   ├── GlassButton
│   ├── LanguageSwitchBar
│   ├── ModeSegmentedControl
│   ├── ChatBubble
│   └── DictSectionCard
└── 📁 Screens
    ├── SplashScreen
    ├── OnboardingScreen
    ├── HomeScreen
    ├── TranslateResultScreen
    ├── ConversationScreen
    ├── VoiceInputScreen
    ├── CameraScreen
    ├── OcrResultScreen
    ├── DictionaryHomeScreen
    ├── DictionaryDetailScreen
    ├── HistoryScreen
    ├── SettingsScreen
    └── LanguageSwitcherPage
