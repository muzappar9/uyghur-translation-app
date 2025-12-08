/// 字体配置管理
/// 支持 Alkatip 维吾尔语字体和常见汉语字体
library;

import 'package:flutter/material.dart';

/// Alkatip 字体变体枚举
enum AlkatipFont {
  /// Alkatip 标准字体
  standard('Alkatip', 'Alkatip 标准', 'ئالكاتىپ ئاساسى'),
  
  /// Alkatip Kona - 经典版
  kona('AlkatipKona', 'Alkatip 经典', 'ئالكاتىپ كونا'),
  
  /// Alkatip Tor - 粗体
  tor('AlkatipTor', 'Alkatip 粗体', 'ئالكاتىپ توم'),
  
  /// Alkatip Yumilaq - 圆润体
  yumilaq('AlkatipYumilaq', 'Alkatip 圆润', 'ئالكاتىپ يۇملاق'),
  
  /// Alkatip Nazik - 细体
  nazik('AlkatipNazik', 'Alkatip 细体', 'ئالكاتىپ نازىك'),
  
  /// Alkatip Basma - 印刷体
  basma('AlkatipBasma', 'Alkatip 印刷', 'ئالكاتىپ بەسمە'),
  
  /// Alkatip Tarixi - 古典体
  tarixi('AlkatipTarixi', 'Alkatip 古典', 'ئالكاتىپ تارىخى'),
  
  /// Alkatip Qol - 手写体
  qol('AlkatipQol', 'Alkatip 手写', 'ئالكاتىپ قول'),
  
  /// Alkatip Kompyuter - 计算机体
  kompyuter('AlkatipKompyuter', 'Alkatip 计算机', 'ئالكاتىپ كومپيۇتېر'),
  
  /// Alkatip Chong - 大字体
  chong('AlkatipChong', 'Alkatip 大字', 'ئالكاتىپ چوڭ');

  const AlkatipFont(this.fontFamily, this.displayNameZh, this.displayNameUg);

  /// Flutter 字体族名称
  final String fontFamily;
  
  /// 中文显示名称
  final String displayNameZh;
  
  /// 维吾尔语显示名称
  final String displayNameUg;

  /// 获取显示名称（根据语言）
  String getDisplayName(String languageCode) {
    switch (languageCode) {
      case 'ug':
        return displayNameUg;
      case 'zh':
      default:
        return displayNameZh;
    }
  }
}

/// 常见汉语字体枚举
enum ChineseFont {
  /// 系统默认
  system('System', '系统默认'),
  
  /// 思源黑体
  sourceHanSans('SourceHanSansSC', '思源黑体'),
  
  /// 思源宋体
  sourceHanSerif('SourceHanSerifSC', '思源宋体'),
  
  /// 站酷快乐体
  zhanku('ZhanKuKuaiLe', '站酷快乐体'),
  
  /// 方正楷体
  fangZhengKai('FZKai', '方正楷体'),
  
  /// 方正黑体
  fangZhengHei('FZHei', '方正黑体'),
  
  /// 微软雅黑（如果可用）
  microsoftYaHei('MicrosoftYaHei', '微软雅黑'),
  
  /// 宋体（如果可用）
  simsun('SimSun', '宋体');

  const ChineseFont(this.fontFamily, this.displayName);

  /// Flutter 字体族名称
  final String fontFamily;
  
  /// 中文显示名称
  final String displayName;
}

/// 字体配置类
class FontConfig {
  /// 当前选中的维吾尔语字体
  final AlkatipFont uyghurFont;
  
  /// 当前选中的汉语字体
  final ChineseFont chineseFont;
  
  /// 字体大小
  final double fontSize;
  
  /// 行高倍数
  final double lineHeight;

  const FontConfig({
    this.uyghurFont = AlkatipFont.standard,
    this.chineseFont = ChineseFont.system,
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
  });

  /// 复制并修改
  FontConfig copyWith({
    AlkatipFont? uyghurFont,
    ChineseFont? chineseFont,
    double? fontSize,
    double? lineHeight,
  }) {
    return FontConfig(
      uyghurFont: uyghurFont ?? this.uyghurFont,
      chineseFont: chineseFont ?? this.chineseFont,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  /// 根据语言代码获取字体
  String getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'ug':
        return uyghurFont.fontFamily;
      case 'zh':
        return chineseFont.fontFamily == 'System' 
            ? '' // 使用系统默认
            : chineseFont.fontFamily;
      default:
        return '';
    }
  }

  /// 获取文本样式
  TextStyle getTextStyle(String languageCode, {
    double? customFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(languageCode),
      fontSize: customFontSize ?? fontSize,
      height: lineHeight,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

/// 字体配置常量
class FontConstants {
  FontConstants._();

  /// 默认字体大小
  static const double defaultFontSize = 16.0;
  
  /// 最小字体大小
  static const double minFontSize = 12.0;
  
  /// 最大字体大小
  static const double maxFontSize = 32.0;
  
  /// 字体大小步进
  static const double fontSizeStep = 2.0;

  /// 默认行高
  static const double defaultLineHeight = 1.5;
  
  /// 最小行高
  static const double minLineHeight = 1.0;
  
  /// 最大行高
  static const double maxLineHeight = 2.5;
  
  /// 行高步进
  static const double lineHeightStep = 0.1;

  /// Alkatip 字体推荐大小
  static const Map<AlkatipFont, double> alkatipRecommendedSizes = {
    AlkatipFont.standard: 16.0,
    AlkatipFont.kona: 18.0,
    AlkatipFont.tor: 16.0,
    AlkatipFont.yumilaq: 17.0,
    AlkatipFont.nazik: 15.0,
    AlkatipFont.basma: 16.0,
    AlkatipFont.tarixi: 18.0,
    AlkatipFont.qol: 17.0,
    AlkatipFont.kompyuter: 15.0,
    AlkatipFont.chong: 20.0,
  };

  /// 获取推荐字体大小
  static double getRecommendedSize(AlkatipFont font) {
    return alkatipRecommendedSizes[font] ?? defaultFontSize;
  }
}
