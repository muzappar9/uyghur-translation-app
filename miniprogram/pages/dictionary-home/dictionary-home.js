// DictionaryHomeScreen: 词典首页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/Page.js") // Declare the Page variable
const wx = require("../../utils/wx.js") // Declare the wx variable

Page({
  data: {
    isRtl: false,
    title: "",
    searchPlaceholder: "",
    recommendSection: "",
    categorySection: "",
    recommendChips: [], // TODO: 推荐词列表
    categoryChips: [], // TODO: 分类列表
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("dict.title"),
      searchPlaceholder: i18n.t("dict.search.placeholder"),
      recommendSection: i18n.t("dict.section.recommend"),
      categorySection: i18n.t("dict.section.category"),
    })
  },

  onSearch(e) {
    // TODO: 搜索实现
  },

  onChipTap(e) {
    wx.navigateTo({ url: "/pages/dictionary-detail/dictionary-detail" })
  },
})
