# 应用图标配置说明

## 需要的图标文件

请将以下图标文件放置在此目录：

### 必需文件
1. **app_icon.png** - 主应用图标
   - 尺寸: 1024x1024 像素
   - 格式: PNG (透明背景)
   - 用途: iOS 图标、Android 图标、Web 图标

2. **app_icon_foreground.png** - Android 自适应图标前景
   - 尺寸: 1024x1024 像素
   - 格式: PNG (透明背景)
   - 注意: 图标内容应在中心 66% 区域内

## 图标设计建议

### 维汉翻译 App 图标设计元素
- 🔤 文字/翻译符号 (如 "中⇄ug" 或翻译气泡)
- 🌐 语言/地球元素
- 📱 简洁现代的设计风格
- 🎨 推荐配色:
  - 主色: #2196F3 (蓝色) 或 #4CAF50 (绿色)
  - 背景: #FFFFFF (白色)

## 生成图标命令

在添加图标文件后，运行以下命令生成所有平台图标：

```bash
flutter pub get
dart run flutter_launcher_icons
```

## 临时方案

如果暂时没有设计好的图标，可以使用在线工具生成：
- https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
- https://www.appicon.co/
- https://icon.kitchen/

## 当前状态

⚠️ 目前使用 Flutter 默认图标，建议在正式发布前替换为专业设计的图标。
