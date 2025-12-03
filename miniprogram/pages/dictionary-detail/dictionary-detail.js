// DictionaryDetailScreen: 词典详情页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/Page.js") // Declare the Page variable

Page({
  data: {
    isRtl: false,
    title: "",
    wordHead: "", // TODO: 词头
    sections: {
      basic: "",
      sense: "",
      professional: "",
      examples: "",
      related: "",
      source: "",
    },
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("dict_detail.title"),
      sections: {
        basic: i18n.t("dict_detail.section.basic"),
        sense: i18n.t("dict_detail.section.sense"),
        professional: i18n.t("dict_detail.section.professional"),
        examples: i18n.t("dict_detail.section.examples"),
        related: i18n.t("dict_detail.section.related"),
        source: i18n.t("dict_detail.label.source"),
      },
    })
  },

  onSpeak() {
    // TODO: 朗读词头
  },

  onFavorite() {
    // TODO: 收藏
  },

  onCopy() {
    // TODO: 复制
  },
})
