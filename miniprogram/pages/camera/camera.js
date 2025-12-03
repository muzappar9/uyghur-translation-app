// CameraScreen: 相机/OCR页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/page.js") // Declare the Page variable
const wx = require("../../utils/wx.js") // Declare the wx variable

Page({
  data: {
    isRtl: false,
    title: "",
    captureText: "",
    albumText: "",
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("camera.title"),
      captureText: i18n.t("camera.button.capture"),
      albumText: i18n.t("camera.button.album"),
    })
  },

  onCapture() {
    // TODO: 拍照实现
    wx.navigateTo({ url: "/pages/ocr-result/ocr-result" })
  },

  onAlbum() {
    // TODO: 选择相册
    wx.navigateTo({ url: "/pages/ocr-result/ocr-result" })
  },
})
