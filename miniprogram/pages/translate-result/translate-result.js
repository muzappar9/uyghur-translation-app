// TranslateResultScreen: 翻译结果页
const i18n = require("../../utils/i18n.js")
const wx = require("wx") // Declare wx variable

Page({
  data: {
    isRtl: false,
    title: "",
    sourceTitle: "",
    targetTitle: "",
    sourceText: "", // TODO: 实际文本
    targetText: "", // TODO: 实际文本
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("result.title"),
      sourceTitle: i18n.t("result.source.title"),
      targetTitle: i18n.t("result.target.title"),
    })
  },

  onSpeak(e) {
    // TODO: 朗读实现
  },

  onCopy(e) {
    // TODO: 复制实现
  },

  onFavorite() {
    // TODO: 收藏实现
  },

  onShare() {
    // TODO: 分享实现
  },

  onNewTranslate() {
    wx.navigateBack()
  },

  onConversation() {
    wx.navigateTo({ url: "/pages/conversation/conversation" })
  },

  onDictionary() {
    wx.navigateTo({ url: "/pages/dictionary-home/dictionary-home" })
  },
})
