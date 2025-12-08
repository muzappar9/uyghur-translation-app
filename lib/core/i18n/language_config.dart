/// 多语言配置系统
/// 支持 Hunyuan-MT-7B 模型的 36 种语言互译
///
/// 特性：
/// - 完整的语言元数据（代码、名称、方向、字体）
/// - RTL 语言自动处理
/// - 字体按需下载机制
/// - 语言分组便于 UI 展示
library;

import 'package:flutter/material.dart';

/// 语言文字方向
enum TextDirectionType {
  /// 从左到右（大多数语言）
  ltr,

  /// 从右到左（阿拉伯语系、希伯来语等）
  rtl,
}

/// 语言分组（用于 UI 展示）
enum LanguageGroup {
  /// 常用语言
  common('常用', 'Common'),

  /// 中国少数民族语言
  chineseMinority('中国少数民族', 'Chinese Minorities'),

  /// 东亚语言
  eastAsian('东亚', 'East Asian'),

  /// 东南亚语言
  southeastAsian('东南亚', 'Southeast Asian'),

  /// 南亚语言
  southAsian('南亚', 'South Asian'),

  /// 中东语言
  middleEast('中东', 'Middle East'),

  /// 欧洲语言
  european('欧洲', 'European'),

  /// 斯拉夫语言
  slavic('斯拉夫', 'Slavic');

  const LanguageGroup(this.nameZh, this.nameEn);
  final String nameZh;
  final String nameEn;

  String getDisplayName(String locale) {
    return locale == 'zh' ? nameZh : nameEn;
  }
}

/// 字体类型
enum FontCategory {
  /// 系统默认字体（无需下载）
  system,

  /// 阿拉伯语系字体（维、阿、波斯、乌尔都）
  arabic,

  /// CJK 字体（中日韩）
  cjk,

  /// 天城文字体（印地、马拉地）
  devanagari,

  /// 孟加拉文字体
  bengali,

  /// 泰米尔文字体
  tamil,

  /// 泰卢固文字体
  telugu,

  /// 古吉拉特文字体
  gujarati,

  /// 泰文字体
  thai,

  /// 高棉文字体
  khmer,

  /// 缅甸文字体
  myanmar,

  /// 藏文字体
  tibetan,

  /// 蒙古文字体
  mongolian,

  /// 希伯来文字体
  hebrew,
}

/// 单个语言配置
class LanguageConfig {
  /// 语言代码（ISO 639-1/BCP 47）
  final String code;

  /// 中文名称
  final String nameZh;

  /// 英文名称
  final String nameEn;

  /// 本地名称（该语言自己的写法）
  final String nameNative;

  /// 文字方向
  final TextDirectionType direction;

  /// 字体类别
  final FontCategory fontCategory;

  /// 语言分组
  final LanguageGroup group;

  /// 是否为默认内置语言
  final bool isBuiltIn;

  /// 是否为中国少数民族语言
  final bool isChineseMinority;

  const LanguageConfig({
    required this.code,
    required this.nameZh,
    required this.nameEn,
    required this.nameNative,
    this.direction = TextDirectionType.ltr,
    this.fontCategory = FontCategory.system,
    this.group = LanguageGroup.common,
    this.isBuiltIn = false,
    this.isChineseMinority = false,
  });

  /// 获取 Flutter TextDirection
  TextDirection get textDirection => direction == TextDirectionType.rtl
      ? TextDirection.rtl
      : TextDirection.ltr;

  /// 是否为 RTL 语言
  bool get isRTL => direction == TextDirectionType.rtl;

  /// 获取显示名称
  String getDisplayName(String locale) {
    switch (locale) {
      case 'zh':
        return nameZh;
      case 'en':
        return nameEn;
      default:
        return nameNative;
    }
  }

  /// 获取完整显示名称（包含本地名称）
  String getFullDisplayName(String locale) {
    if (locale == 'native' || locale == code) {
      return nameNative;
    }
    final primary = locale == 'zh' ? nameZh : nameEn;
    return '$primary ($nameNative)';
  }
}

/// 支持的全部 36 种语言配置
/// 按照 Hunyuan-MT-7B 模型支持列表
class SupportedLanguages {
  SupportedLanguages._();

  /// ========== 常用语言 ==========

  static const chinese = LanguageConfig(
    code: 'zh',
    nameZh: '简体中文',
    nameEn: 'Chinese (Simplified)',
    nameNative: '简体中文',
    fontCategory: FontCategory.cjk,
    group: LanguageGroup.common,
    isBuiltIn: true,
  );

  static const chineseTraditional = LanguageConfig(
    code: 'zh-Hant',
    nameZh: '繁体中文',
    nameEn: 'Chinese (Traditional)',
    nameNative: '繁體中文',
    fontCategory: FontCategory.cjk,
    group: LanguageGroup.common,
    isBuiltIn: true,
  );

  static const english = LanguageConfig(
    code: 'en',
    nameZh: '英语',
    nameEn: 'English',
    nameNative: 'English',
    group: LanguageGroup.common,
    isBuiltIn: true,
  );

  /// ========== 中国少数民族语言 ==========

  static const uyghur = LanguageConfig(
    code: 'ug',
    nameZh: '维吾尔语',
    nameEn: 'Uyghur',
    nameNative: 'ئۇيغۇرچە',
    direction: TextDirectionType.rtl,
    fontCategory: FontCategory.arabic,
    group: LanguageGroup.chineseMinority,
    isBuiltIn: true,
    isChineseMinority: true,
  );

  static const tibetan = LanguageConfig(
    code: 'bo',
    nameZh: '藏语',
    nameEn: 'Tibetan',
    nameNative: 'བོད་སྐད།',
    fontCategory: FontCategory.tibetan,
    group: LanguageGroup.chineseMinority,
    isChineseMinority: true,
  );

  static const mongolian = LanguageConfig(
    code: 'mn',
    nameZh: '蒙古语',
    nameEn: 'Mongolian',
    nameNative: 'Монгол хэл',
    fontCategory: FontCategory.mongolian,
    group: LanguageGroup.chineseMinority,
    isChineseMinority: true,
  );

  static const kazakh = LanguageConfig(
    code: 'kk',
    nameZh: '哈萨克语',
    nameEn: 'Kazakh',
    nameNative: 'Қазақ тілі',
    fontCategory: FontCategory.system,
    group: LanguageGroup.chineseMinority,
    isChineseMinority: true,
  );

  static const cantonese = LanguageConfig(
    code: 'yue',
    nameZh: '粤语',
    nameEn: 'Cantonese',
    nameNative: '粵語',
    fontCategory: FontCategory.cjk,
    group: LanguageGroup.chineseMinority,
    isChineseMinority: true,
  );

  /// ========== 东亚语言 ==========

  static const japanese = LanguageConfig(
    code: 'ja',
    nameZh: '日语',
    nameEn: 'Japanese',
    nameNative: '日本語',
    fontCategory: FontCategory.cjk,
    group: LanguageGroup.eastAsian,
  );

  static const korean = LanguageConfig(
    code: 'ko',
    nameZh: '韩语',
    nameEn: 'Korean',
    nameNative: '한국어',
    fontCategory: FontCategory.cjk,
    group: LanguageGroup.eastAsian,
  );

  /// ========== 东南亚语言 ==========

  static const thai = LanguageConfig(
    code: 'th',
    nameZh: '泰语',
    nameEn: 'Thai',
    nameNative: 'ไทย',
    fontCategory: FontCategory.thai,
    group: LanguageGroup.southeastAsian,
  );

  static const vietnamese = LanguageConfig(
    code: 'vi',
    nameZh: '越南语',
    nameEn: 'Vietnamese',
    nameNative: 'Tiếng Việt',
    group: LanguageGroup.southeastAsian,
  );

  static const indonesian = LanguageConfig(
    code: 'id',
    nameZh: '印尼语',
    nameEn: 'Indonesian',
    nameNative: 'Bahasa Indonesia',
    group: LanguageGroup.southeastAsian,
  );

  static const malay = LanguageConfig(
    code: 'ms',
    nameZh: '马来语',
    nameEn: 'Malay',
    nameNative: 'Bahasa Melayu',
    group: LanguageGroup.southeastAsian,
  );

  static const filipino = LanguageConfig(
    code: 'tl',
    nameZh: '菲律宾语',
    nameEn: 'Filipino',
    nameNative: 'Filipino',
    group: LanguageGroup.southeastAsian,
  );

  static const khmer = LanguageConfig(
    code: 'km',
    nameZh: '高棉语',
    nameEn: 'Khmer',
    nameNative: 'ភាសាខ្មែរ',
    fontCategory: FontCategory.khmer,
    group: LanguageGroup.southeastAsian,
  );

  static const burmese = LanguageConfig(
    code: 'my',
    nameZh: '缅甸语',
    nameEn: 'Burmese',
    nameNative: 'မြန်မာဘာသာ',
    fontCategory: FontCategory.myanmar,
    group: LanguageGroup.southeastAsian,
  );

  /// ========== 南亚语言 ==========

  static const hindi = LanguageConfig(
    code: 'hi',
    nameZh: '印地语',
    nameEn: 'Hindi',
    nameNative: 'हिन्दी',
    fontCategory: FontCategory.devanagari,
    group: LanguageGroup.southAsian,
  );

  static const bengali = LanguageConfig(
    code: 'bn',
    nameZh: '孟加拉语',
    nameEn: 'Bengali',
    nameNative: 'বাংলা',
    fontCategory: FontCategory.bengali,
    group: LanguageGroup.southAsian,
  );

  static const tamil = LanguageConfig(
    code: 'ta',
    nameZh: '泰米尔语',
    nameEn: 'Tamil',
    nameNative: 'தமிழ்',
    fontCategory: FontCategory.tamil,
    group: LanguageGroup.southAsian,
  );

  static const telugu = LanguageConfig(
    code: 'te',
    nameZh: '泰卢固语',
    nameEn: 'Telugu',
    nameNative: 'తెలుగు',
    fontCategory: FontCategory.telugu,
    group: LanguageGroup.southAsian,
  );

  static const marathi = LanguageConfig(
    code: 'mr',
    nameZh: '马拉地语',
    nameEn: 'Marathi',
    nameNative: 'मराठी',
    fontCategory: FontCategory.devanagari,
    group: LanguageGroup.southAsian,
  );

  static const gujarati = LanguageConfig(
    code: 'gu',
    nameZh: '古吉拉特语',
    nameEn: 'Gujarati',
    nameNative: 'ગુજરાતી',
    fontCategory: FontCategory.gujarati,
    group: LanguageGroup.southAsian,
  );

  static const urdu = LanguageConfig(
    code: 'ur',
    nameZh: '乌尔都语',
    nameEn: 'Urdu',
    nameNative: 'اردو',
    direction: TextDirectionType.rtl,
    fontCategory: FontCategory.arabic,
    group: LanguageGroup.southAsian,
  );

  /// ========== 中东语言 ==========

  static const arabic = LanguageConfig(
    code: 'ar',
    nameZh: '阿拉伯语',
    nameEn: 'Arabic',
    nameNative: 'العربية',
    direction: TextDirectionType.rtl,
    fontCategory: FontCategory.arabic,
    group: LanguageGroup.middleEast,
  );

  static const persian = LanguageConfig(
    code: 'fa',
    nameZh: '波斯语',
    nameEn: 'Persian',
    nameNative: 'فارسی',
    direction: TextDirectionType.rtl,
    fontCategory: FontCategory.arabic,
    group: LanguageGroup.middleEast,
  );

  static const hebrew = LanguageConfig(
    code: 'he',
    nameZh: '希伯来语',
    nameEn: 'Hebrew',
    nameNative: 'עברית',
    direction: TextDirectionType.rtl,
    fontCategory: FontCategory.hebrew,
    group: LanguageGroup.middleEast,
  );

  static const turkish = LanguageConfig(
    code: 'tr',
    nameZh: '土耳其语',
    nameEn: 'Turkish',
    nameNative: 'Türkçe',
    group: LanguageGroup.middleEast,
  );

  /// ========== 欧洲语言 ==========

  static const french = LanguageConfig(
    code: 'fr',
    nameZh: '法语',
    nameEn: 'French',
    nameNative: 'Français',
    group: LanguageGroup.european,
  );

  static const german = LanguageConfig(
    code: 'de',
    nameZh: '德语',
    nameEn: 'German',
    nameNative: 'Deutsch',
    group: LanguageGroup.european,
  );

  static const spanish = LanguageConfig(
    code: 'es',
    nameZh: '西班牙语',
    nameEn: 'Spanish',
    nameNative: 'Español',
    group: LanguageGroup.european,
  );

  static const portuguese = LanguageConfig(
    code: 'pt',
    nameZh: '葡萄牙语',
    nameEn: 'Portuguese',
    nameNative: 'Português',
    group: LanguageGroup.european,
  );

  static const italian = LanguageConfig(
    code: 'it',
    nameZh: '意大利语',
    nameEn: 'Italian',
    nameNative: 'Italiano',
    group: LanguageGroup.european,
  );

  static const dutch = LanguageConfig(
    code: 'nl',
    nameZh: '荷兰语',
    nameEn: 'Dutch',
    nameNative: 'Nederlands',
    group: LanguageGroup.european,
  );

  /// ========== 斯拉夫语言 ==========

  static const russian = LanguageConfig(
    code: 'ru',
    nameZh: '俄语',
    nameEn: 'Russian',
    nameNative: 'Русский',
    group: LanguageGroup.slavic,
  );

  static const ukrainian = LanguageConfig(
    code: 'uk',
    nameZh: '乌克兰语',
    nameEn: 'Ukrainian',
    nameNative: 'Українська',
    group: LanguageGroup.slavic,
  );

  static const polish = LanguageConfig(
    code: 'pl',
    nameZh: '波兰语',
    nameEn: 'Polish',
    nameNative: 'Polski',
    group: LanguageGroup.slavic,
  );

  static const czech = LanguageConfig(
    code: 'cs',
    nameZh: '捷克语',
    nameEn: 'Czech',
    nameNative: 'Čeština',
    group: LanguageGroup.slavic,
  );

  /// 所有支持的语言列表
  static const List<LanguageConfig> all = [
    // 常用
    chinese,
    chineseTraditional,
    english,
    // 中国少数民族
    uyghur,
    tibetan,
    mongolian,
    kazakh,
    cantonese,
    // 东亚
    japanese,
    korean,
    // 东南亚
    thai,
    vietnamese,
    indonesian,
    malay,
    filipino,
    khmer,
    burmese,
    // 南亚
    hindi,
    bengali,
    tamil,
    telugu,
    marathi,
    gujarati,
    urdu,
    // 中东
    arabic,
    persian,
    hebrew,
    turkish,
    // 欧洲
    french,
    german,
    spanish,
    portuguese,
    italian,
    dutch,
    // 斯拉夫
    russian,
    ukrainian,
    polish,
    czech,
  ];

  /// RTL 语言代码列表
  static const List<String> rtlLanguageCodes = ['ug', 'ar', 'fa', 'he', 'ur'];

  /// 默认内置语言
  static List<LanguageConfig> get builtInLanguages =>
      all.where((lang) => lang.isBuiltIn).toList();

  /// 中国少数民族语言
  static List<LanguageConfig> get chineseMinorityLanguages =>
      all.where((lang) => lang.isChineseMinority).toList();

  /// 按分组获取语言
  static List<LanguageConfig> getByGroup(LanguageGroup group) =>
      all.where((lang) => lang.group == group).toList();

  /// 根据代码获取语言配置
  static LanguageConfig? getByCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }

  /// 判断是否为 RTL 语言
  static bool isRTL(String code) => rtlLanguageCodes.contains(code);

  /// 获取文字方向
  static TextDirection getTextDirection(String code) =>
      isRTL(code) ? TextDirection.rtl : TextDirection.ltr;

  /// 获取语言显示名称
  static String getDisplayName(String code, {String locale = 'zh'}) {
    final config = getByCode(code);
    if (config != null) {
      return config.getDisplayName(locale);
    }
    return code.toUpperCase();
  }

  /// 获取完整显示名称
  static String getFullDisplayName(String code, {String locale = 'zh'}) {
    final config = getByCode(code);
    if (config != null) {
      return config.getFullDisplayName(locale);
    }
    return code.toUpperCase();
  }

  /// 获取字体类别
  static FontCategory getFontCategory(String code) {
    final config = getByCode(code);
    return config?.fontCategory ?? FontCategory.system;
  }

  /// 按分组组织的语言（用于 UI）
  static Map<LanguageGroup, List<LanguageConfig>> get groupedLanguages {
    final result = <LanguageGroup, List<LanguageConfig>>{};
    for (final group in LanguageGroup.values) {
      final languages = getByGroup(group);
      if (languages.isNotEmpty) {
        result[group] = languages;
      }
    }
    return result;
  }

  /// 搜索语言（支持中英文和本地名称）
  static List<LanguageConfig> search(String query) {
    if (query.isEmpty) return all;
    final lowerQuery = query.toLowerCase();
    return all.where((lang) {
      return lang.code.toLowerCase().contains(lowerQuery) ||
          lang.nameZh.toLowerCase().contains(lowerQuery) ||
          lang.nameEn.toLowerCase().contains(lowerQuery) ||
          lang.nameNative.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
