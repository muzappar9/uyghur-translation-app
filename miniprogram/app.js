/**
 * 微信小程序入口
 * 公益维吾尔语翻译App
 */
const i18n = require("./utils/i18n.js")
const App = require("app") // 声明 App 变量
const wx = require("wx") // 声明 wx 变量
const getCurrentPages = require("getCurrentPages") // 声明 getCurrentPages 变量

App({
  globalData: {
    locale: "zh", // 'zh' | 'ug'
    isRTL: false,
  },

  onLaunch() {
    // 初始化语言设置
    const savedLocale = wx.getStorageSync("locale") || "zh"
    this.setLocale(savedLocale)
  },

  setLocale(locale) {
    this.globalData.locale = locale
    this.globalData.isRTL = locale === "ug"
    wx.setStorageSync("locale", locale)

    // 通知所有页面更新
    const pages = getCurrentPages()
    pages.forEach((page) => {
      if (page.onLocaleChange) {
        page.onLocaleChange(locale)
      }
    })
  },

  t(key) {
    return i18n.t(key, this.globalData.locale)
  },
})
