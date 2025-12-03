// HomeScreen: 主页
const i18n = require("../../utils/i18n.js")
const Page = require("../../miniprogram-api").Page
const wx = require("../../miniprogram-api").wx

Page({
  data: {
    isRtl: false,
    title: "",
    inputPlaceholder: "",
    sourceLanguage: "",
    targetLanguage: "",
    currentMode: 0,
    modes: [],
    inputText: "",
  },

  onLoad() {
    const isRtl = i18n.isRtl()
    this.setData({
      isRtl,
      title: i18n.t("home.title"),
      inputPlaceholder: i18n.t("home.input.placeholder"),
      sourceLanguage: i18n.t("home.language.source"),
      targetLanguage: i18n.t("home.language.target"),
      modes: [
        { key: "text", label: i18n.t("home.mode.text") },
        { key: "voice", label: i18n.t("home.mode.voice") },
        { key: "camera", label: i18n.t("home.mode.camera") },
        { key: "document", label: i18n.t("home.mode.document") },
      ],
    })
  },

  onInputChange(e) {
    this.setData({ inputText: e.detail.value })
  },

  onModeChange(e) {
    const index = e.currentTarget.dataset.index
    this.setData({ currentMode: index })
  },

  onSwapLanguage() {
    // TODO: 实现语言交换
  },

  onTranslate() {
    wx.navigateTo({ url: "/pages/translate-result/translate-result" })
  },

  onVoiceInput() {
    wx.navigateTo({ url: "/pages/voice-input/voice-input" })
  },

  onCameraInput() {
    wx.navigateTo({ url: "/pages/camera/camera" })
  },
})
