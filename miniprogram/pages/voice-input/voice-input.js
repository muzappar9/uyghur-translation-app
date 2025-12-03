// VoiceInputScreen: 语音输入页
const i18n = require("../../utils/i18n.js")
const Page = require("miniprogram-api") // Assuming this is where Page is declared

Page({
  data: {
    isRtl: false,
    title: "",
    statusText: "",
    stopButtonText: "",
    recognizedText: "", // TODO: 实时识别文本
  },

  onLoad() {
    this.setData({
      isRtl: i18n.isRtl(),
      title: i18n.t("voice.title"),
      statusText: i18n.t("voice.status.ready"),
      stopButtonText: i18n.t("voice.button.stop"),
    })
  },

  onStartRecording() {
    this.setData({
      statusText: i18n.t("voice.status.recording"),
    })
    // TODO: 开始录音
  },

  onStopRecording() {
    this.setData({
      statusText: i18n.t("voice.status.processing"),
    })
    // TODO: 停止录音并处理
  },
})
