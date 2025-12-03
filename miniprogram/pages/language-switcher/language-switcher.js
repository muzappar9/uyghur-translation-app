// LanguageSwitcherPage: 语言切换页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/Page.js") // Declare the Page variable
const wx = require("../../utils/wx.js") // Declare the wx variable

Page({
  data: {
    isRtl: false,
    title: "",
    currentLanguage: "zh",
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("language.title"),
      currentLanguage: i18n.getCurrentLanguage(),
    })
  },

  onLanguageSelect(e) {
    const lang = e.currentTarget.dataset.lang
    this.setData({ currentLanguage: lang })
  },

  onApply() {
    const { currentLanguage } = this.data
    i18n.setLanguage(currentLanguage)
    // 重建整个App（RTL安全）
    wx.reLaunch({ url: "/pages/home/home" })
  },
})
