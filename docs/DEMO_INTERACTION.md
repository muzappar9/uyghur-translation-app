# Step 2: Multi-Modal Demo Video Specification

## 30-Second Interaction Flow

### Figma Dev Mode Import Path
1. Import `docs/figma-component-variants.csv` to Figma
2. Create components with Auto Layout + Blur Effects (sigma:15)
3. Enable RTL variants by duplicating and flipping direction
4. Set up interactive prototype with Smart Animate transitions

---

## Video Timeline (30s Total)

### 0:00-0:03 - Splash Screen (Coral Gradient)
**Visual**:
- Coral gradient background (#FF7F50 → #FF6B6B → #FF8E53)
- Logo placeholder fades in with sigma:15 blur glass card
- Loading text: "يۈكلىنىۋاتىدۇ" (Uyghur)
- Auto-navigate to Onboarding after 3s

---

### 0:03-0:06 - Onboarding (ug RTL, Right Swipe)
**Visual**:
- RTL layout: Dots right-aligned, "Next" button left side
- Page 1: "خوش كەپسىز" (Welcome) + translation icon
- User swipes RIGHT (RTL direction) → Page 2
- Page 2: Voice feature + "ئاۋاز تەرجىمىسى"
- Glass cards with BackdropFilter blur visible over gradient

---

### 0:06-0:10 - Home Input (RTL Placeholder)
**Visual**:
- AppBar: "تەرجىمان" title right-aligned
- Language bar RTL: "维语 → [⇄] → 中文"
- Tabs reversed: [文档][相机][语音][文字]
- TextField shows: "تېكىستنى كىرگۈزۈڭ" cursor from right
- User types simulated Uyghur text: "سالام"

---

### 0:10-0:16 - Voice Input (Mic Ripple + ASR Mock)
**Visual**:
- Tap mic icon → Navigate to VoiceInputScreen
- Coral gradient fills screen
- Mic button scales 1.0→1.5 with white glow pulse
- 3 ripple waves expand (180px, 160px, 140px) with stagger
- Status text: "ئاڭلاۋاتىدۇ" (Listening)
- Console overlay (bottom): `print('input audio')` from THUYG-20 ASR mock
- After 4s, show result: "Hello" in glass card

---

### 0:16-0:20 - Translate Result (TODO Display)
**Visual**:
- Source Card: "سالام" + speaker/copy/favorite icons
- Target Card: "TODO: Translation Result" + icons
- Bottom buttons: "新翻译" / "对话模式" / "词典"
- User taps copy icon → Toast: "已复制"

---

### 0:20-0:26 - History Edit + RL Correction
**Visual**:
- Navigate to History (top-right icon from Result)
- Glass list items show:
  - Item 1: "سالام" → "你好"
  - Item 2: "TODO: Original" → "TODO: Translation"
- User taps Edit icon on Item 1 → TextField appears
- User changes "你好" to "您好" → Tap check icon
- Console overlay: `print('export RL feedback: user corrected translation')`
- Toast: "تۈزىتىش يوللاندى" (Correction submitted)

---

### 0:26-0:30 - RL Export Modal
**Visual**:
- User taps upload icon (top-right)
- Glass modal pops up (sigma:15 blur):
  \`\`\`
  ┌─────────────────────────────────┐
  │  Export RL Feedback             │
  │  ================================│
  │  5 corrections ready            │
  │  12 translation pairs           │
  │                                 │
  │  [Cancel]  [Export to Agent]    │
  └─────────────────────────────────┘
  \`\`\`
- User taps "Export to Agent" → Loading spinner
- Console: `print('export RL feedback')`
- Success toast: "چىقىرىلدى" (Exported)
- Fade to app logo

---

## Output Formats

### 1. Figma Prototype Video
**Link**: [Figma Embed - 30s MP4]
- Resolution: 1080x2400 (Phone 9:20)
- FPS: 60
- Format: H.264 MP4
- Includes: Smart Animate transitions + Blur effects

### 2. Flutter iOS Simulator GIF
**Link**: [iOS Simulator Recording - 30s GIF]
- Device: iPhone 14 Pro simulator
- Command: `flutter run --locale=ug`
- Shows: Real RTL layout + ripple animation
- Size: ~5MB optimized GIF

### 3. WeChat Mini-Program Demo
**Implementation**:
\`\`\`javascript
// miniprogram/app.js
App({
  globalData: {
    locale: 'ug',
    isRTL: true
  },
  onLaunch() {
    console.log('[v0] Mini-program launched with RTL mode')
  }
})

// pages/voice/voice.js
Page({
  onMicTap() {
    console.log('[v0] input audio') // ASR mock
    wx.navigateTo({ url: '/pages/translate-result/translate-result' })
  }
})

// pages/history/history.js
Page({
  exportRLFeedback() {
    console.log('[v0] export RL feedback')
    wx.showToast({ title: 'چىقىرىلدى' })
  }
})
\`\`\`

**CSS RTL**:
\`\`\`css
/* app.wxss */
.rtl {
  direction: rtl;
  text-align: right;
}
.glass-card {
  backdrop-filter: blur(15px);
  background: rgba(255, 255, 255, 0.25);
  border-radius: 24px;
}
\`\`\`

**Demo Link**: [WeChat DevTools Preview Video - 15s]
