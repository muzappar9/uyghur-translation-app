// SettingsScreen: 设置页
const i18n = require("../../utils/i18n.js")
const Page = require("miniprogram-api").Page
const wx = require("miniprogram-api").wx

Page({
  data: {
    isRtl: false,
    title: "",
    sections: {},
    currentLanguage: "zh",
    currentFont: 0,
    isDarkMode: false,
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("settings.title"),
      sections: {
        language: i18n.t("settings.section.language"),
        font: i18n.t("settings.section.font"),
        theme: i18n.t("settings.section.theme"),
        privacy: i18n.t("settings.section.privacy"),
        about: i18n.t("settings.section.about"),
      },
      currentLanguage: i18n.getCurrentLanguage(),
    })
  },

  onLanguageChange(e) {
    const lang = e.currentTarget.dataset.lang
    i18n.setLanguage(lang)
    // 重建整个App
    wx.reLaunch({ url: "/pages/home/home" })
  },

  onFontChange(e) {
    const index = e.currentTarget.dataset.index
    this.setData({ currentFont: index })
    // TODO: 应用字体变化
  },

  onDarkModeToggle(e) {
    this.setData({ isDarkMode: e.detail.value })
    // TODO: 应用深色模式
  },

  onPrivacyTap() {
    // TODO: 打开隐私政策
  },

  onOpenSourceTap() {
    // TODO: 打开开源信息
  },

  onVersionTap() {
    // TODO: 版本信息
  },
})
