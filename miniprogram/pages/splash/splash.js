// SplashScreen: 启动页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/page.js") // 声明 Page 变量
const wx = require("../../utils/wx.js") // 声明 wx 变量

Page({
  data: {
    loadingText: "",
  },

  onLoad() {
    this.setData({
      loadingText: i18n.t("splash.loading"),
    })

    // 3秒延时后跳转home
    setTimeout(() => {
      wx.redirectTo({ url: "/pages/home/home" })
    }, 3000)
  },
})
