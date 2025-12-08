/// 多语言支持功能测试
/// 验证报告中第一到第八项所有功能
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/core/i18n/language_config.dart';
import 'package:uyghur_translator/core/i18n/safe_text_renderer.dart';

void main() {
  group('【一】38种语言配置验证', () {
    test('应该有38种语言配置（Hunyuan-MT 36种 + 繁体中文 + 粤语）', () {
      expect(SupportedLanguages.all.length, equals(38));
    });

    test('所有语言应该有完整的配置信息', () {
      for (final lang in SupportedLanguages.all) {
        expect(lang.code, isNotEmpty, reason: '${lang.nameZh} 缺少语言代码');
        expect(lang.nameZh, isNotEmpty, reason: '${lang.code} 缺少中文名称');
        expect(lang.nameEn, isNotEmpty, reason: '${lang.code} 缺少英文名称');
        expect(lang.nameNative, isNotEmpty, reason: '${lang.code} 缺少本地名称');
      }
    });

    test('应该包含全部Hunyuan-MT-7B支持的语言', () {
      final requiredLanguages = [
        'zh', 'zh-Hant', 'en', 'ug', 'bo', 'mn', 'kk', 'yue', // 中国相关
        'ja', 'ko', // 东亚
        'th', 'vi', 'id', 'ms', 'tl', 'km', 'my', // 东南亚
        'hi', 'bn', 'ta', 'te', 'mr', 'gu', 'ur', // 南亚
        'ar', 'fa', 'he', 'tr', // 中东
        'fr', 'de', 'es', 'pt', 'it', 'nl', // 欧洲
        'ru', 'uk', 'pl', 'cs', // 斯拉夫
      ];

      for (final code in requiredLanguages) {
        final config = SupportedLanguages.getByCode(code);
        expect(config, isNotNull, reason: '缺少语言: $code');
      }
    });
  });

  group('【二】RTL语言识别验证', () {
    test('应该正确识别5种RTL语言', () {
      expect(SupportedLanguages.rtlLanguageCodes,
          containsAll(['ug', 'ar', 'fa', 'he', 'ur']));
    });

    test('isRTL() 方法应该正确工作', () {
      // RTL 语言
      expect(SupportedLanguages.isRTL('ug'), isTrue);
      expect(SupportedLanguages.isRTL('ar'), isTrue);
      expect(SupportedLanguages.isRTL('fa'), isTrue);
      expect(SupportedLanguages.isRTL('he'), isTrue);
      expect(SupportedLanguages.isRTL('ur'), isTrue);

      // LTR 语言
      expect(SupportedLanguages.isRTL('zh'), isFalse);
      expect(SupportedLanguages.isRTL('en'), isFalse);
      expect(SupportedLanguages.isRTL('ja'), isFalse);
    });

    test('getTextDirection() 应该返回正确的方向', () {
      expect(SupportedLanguages.getTextDirection('ug'), TextDirection.rtl);
      expect(SupportedLanguages.getTextDirection('ar'), TextDirection.rtl);
      expect(SupportedLanguages.getTextDirection('zh'), TextDirection.ltr);
      expect(SupportedLanguages.getTextDirection('en'), TextDirection.ltr);
    });
  });

  group('【三】字体分类验证', () {
    test('内置字体应该标记正确', () {
      final builtIn = SupportedLanguages.builtInLanguages;
      expect(builtIn.map((l) => l.code),
          containsAll(['zh', 'zh-Hant', 'en', 'ug']));
    });

    test('字体分类应该正确', () {
      // 阿拉伯语系
      expect(SupportedLanguages.getFontCategory('ug'), FontCategory.arabic);
      expect(SupportedLanguages.getFontCategory('ar'), FontCategory.arabic);
      expect(SupportedLanguages.getFontCategory('fa'), FontCategory.arabic);
      expect(SupportedLanguages.getFontCategory('ur'), FontCategory.arabic);

      // CJK
      expect(SupportedLanguages.getFontCategory('zh'), FontCategory.cjk);
      expect(SupportedLanguages.getFontCategory('ja'), FontCategory.cjk);
      expect(SupportedLanguages.getFontCategory('ko'), FontCategory.cjk);

      // 南亚字体
      expect(SupportedLanguages.getFontCategory('hi'), FontCategory.devanagari);
      expect(SupportedLanguages.getFontCategory('bn'), FontCategory.bengali);
      expect(SupportedLanguages.getFontCategory('ta'), FontCategory.tamil);

      // 系统字体
      expect(SupportedLanguages.getFontCategory('en'), FontCategory.system);
      expect(SupportedLanguages.getFontCategory('fr'), FontCategory.system);
    });
  });

  group('【四】中国少数民族语言验证', () {
    test('应该有5种中国少数民族语言', () {
      final minorities = SupportedLanguages.chineseMinorityLanguages;
      expect(minorities.length, equals(5));
      expect(minorities.map((l) => l.code),
          containsAll(['ug', 'bo', 'mn', 'kk', 'yue']));
    });

    test('少数民族语言标记应该正确', () {
      expect(SupportedLanguages.getByCode('ug')?.isChineseMinority, isTrue);
      expect(SupportedLanguages.getByCode('bo')?.isChineseMinority, isTrue);
      expect(SupportedLanguages.getByCode('zh')?.isChineseMinority, isFalse);
    });
  });

  group('【五】语言分组验证', () {
    test('应该有8个语言分组', () {
      expect(LanguageGroup.values.length, equals(8));
    });

    test('分组应该正确', () {
      expect(SupportedLanguages.getByCode('zh')?.group, LanguageGroup.common);
      expect(SupportedLanguages.getByCode('ug')?.group,
          LanguageGroup.chineseMinority);
      expect(
          SupportedLanguages.getByCode('ja')?.group, LanguageGroup.eastAsian);
      expect(SupportedLanguages.getByCode('th')?.group,
          LanguageGroup.southeastAsian);
      expect(
          SupportedLanguages.getByCode('hi')?.group, LanguageGroup.southAsian);
      expect(
          SupportedLanguages.getByCode('ar')?.group, LanguageGroup.middleEast);
      expect(SupportedLanguages.getByCode('fr')?.group, LanguageGroup.european);
      expect(SupportedLanguages.getByCode('ru')?.group, LanguageGroup.slavic);
    });

    test('groupedLanguages 应该按组分类', () {
      final grouped = SupportedLanguages.groupedLanguages;
      expect(grouped.keys.length, greaterThan(0));

      for (final group in grouped.keys) {
        expect(grouped[group], isNotEmpty, reason: '分组 $group 不应该为空');
      }
    });
  });

  group('【六】语言搜索功能验证', () {
    test('应该支持中文搜索', () {
      final results = SupportedLanguages.search('维吾尔');
      expect(results.map((l) => l.code), contains('ug'));
    });

    test('应该支持英文搜索', () {
      final results = SupportedLanguages.search('Arabic');
      expect(results.map((l) => l.code), contains('ar'));
    });

    test('应该支持语言代码搜索', () {
      final results = SupportedLanguages.search('zh');
      expect(results.map((l) => l.code), contains('zh'));
    });

    test('空搜索应该返回全部语言', () {
      final results = SupportedLanguages.search('');
      expect(results.length, equals(38));
    });
  });

  group('【七】双向文本处理验证', () {
    test('detectTextDirection 应该正确检测RTL文本', () {
      // 阿拉伯语文本
      expect(detectTextDirection('مرحبا'), TextDirection.rtl);
      // 希伯来语文本
      expect(detectTextDirection('שלום'), TextDirection.rtl);
      // 维吾尔语文本
      expect(detectTextDirection('ياخشىمۇسىز'), TextDirection.rtl);
    });

    test('detectTextDirection 应该正确检测LTR文本', () {
      expect(detectTextDirection('Hello'), TextDirection.ltr);
      expect(detectTextDirection('你好'), TextDirection.ltr);
      expect(detectTextDirection('こんにちは'), TextDirection.ltr);
    });

    test('detectTextDirection 混合文本应该基于占比判断', () {
      // RTL 占多数
      expect(detectTextDirection('مرحبا Hello'), TextDirection.rtl);
      // LTR 占多数
      expect(detectTextDirection('Hello World مرحبا'), TextDirection.ltr);
    });
  });

  group('【八】显示名称功能验证', () {
    test('getDisplayName 应该返回正确的名称', () {
      expect(SupportedLanguages.getDisplayName('ug', locale: 'zh'), '维吾尔语');
      expect(SupportedLanguages.getDisplayName('ug', locale: 'en'), 'Uyghur');
      expect(SupportedLanguages.getDisplayName('ar', locale: 'zh'), '阿拉伯语');
    });

    test('getFullDisplayName 应该返回完整名称', () {
      final fullName =
          SupportedLanguages.getFullDisplayName('ug', locale: 'zh');
      expect(fullName, contains('维吾尔语'));
      expect(fullName, contains('ئۇيغۇرچە'));
    });

    test('未知语言代码应该返回代码本身', () {
      expect(SupportedLanguages.getDisplayName('unknown'), 'UNKNOWN');
    });
  });
}
