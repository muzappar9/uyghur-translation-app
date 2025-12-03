// ConversationScreen: 对话翻译页
const i18n = require("../../utils/i18n.js")
const Page = require("../../utils/page.js") // Declare the Page variable

Page({
  data: {
    isRtl: false,
    title: "",
    micLeftLabel: "",
    micRightLabel: "",
    messages: [], // TODO: 实际对话消息
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("conversation.title"),
      micLeftLabel: i18n.t("conversation.mic.left"),
      micRightLabel: i18n.t("conversation.mic.right"),
    })
  },

  onMicLeft() {
    // TODO: 左侧麦克风录音
  },

  onMicRight() {
    // TODO: 右侧麦克风录音
  },

  onSpeakMessage(e) {
    // TODO: 朗读消息
  },
})
