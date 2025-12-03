// OcrResultScreen: OCR结果页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/Page.js") // Declare the Page variable
const wx = require("../../utils/wx.js") // Declare the wx variable

Page({
  data: {
    isRtl: false,
    title: "",
    ocrText: "", // TODO: OCR识别文本
    editButtonText: "",
    translateButtonText: "",
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("ocr_result.title"),
      editButtonText: i18n.t("ocr_result.button.edit"),
      translateButtonText: i18n.t("ocr_result.button.translate"),
    })
  },

  onTextChange(e) {
    this.setData({ ocrText: e.detail.value })
  },

  onEdit() {
    // TODO: 编辑模式
  },

  onTranslate() {
    wx.navigateTo({ url: "/pages/translate-result/translate-result" })
  },
})
