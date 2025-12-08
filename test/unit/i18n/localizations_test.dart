import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/i18n/localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    group('中文翻译', () {
      late AppLocalizations zhLocalizations;

      setUp(() {
        zhLocalizations = AppLocalizations(const Locale('zh', 'CN'));
      });

      test('应返回正确的中文翻译', () {
        expect(zhLocalizations.t('home.title'), '翻译');
        expect(zhLocalizations.t('home.button.translate'), '翻译');
        expect(zhLocalizations.t('common.cancel'), '取消');
      });

      test('应返回所有 Splash 键的翻译', () {
        expect(zhLocalizations.t('splash.loading'), '加载中');
        expect(zhLocalizations.t('splash.logo.alt'), '翻译应用');
        expect(zhLocalizations.t('splash.version'), '版本');
      });

      test('应返回所有 Onboarding 键的翻译', () {
        expect(zhLocalizations.t('onboarding.welcome'), '欢迎');
        expect(zhLocalizations.t('onboarding.button.next'), '下一步');
        expect(zhLocalizations.t('onboarding.button.start'), '开始');
        expect(zhLocalizations.t('onboarding.button.skip'), '跳过');
      });

      test('应返回所有 Home 键的翻译', () {
        expect(zhLocalizations.t('home.subtitle'), '维吾尔语-汉语');
        expect(zhLocalizations.t('home.input.placeholder'), '请输入文本');
        expect(zhLocalizations.t('home.mode.text'), '文本');
        expect(zhLocalizations.t('home.mode.voice'), '语音');
        expect(zhLocalizations.t('home.lang.chinese'), '汉语');
        expect(zhLocalizations.t('home.lang.uyghur'), '维吾尔语');
      });

      test('应返回所有 Result 键的翻译', () {
        expect(zhLocalizations.t('result.title'), '翻译结果');
        expect(zhLocalizations.t('result.action.copy'), '复制');
        expect(zhLocalizations.t('result.action.favorite'), '收藏');
        expect(zhLocalizations.t('result.action.share'), '分享');
      });

      test('应返回所有 Settings 键的翻译', () {
        expect(zhLocalizations.t('settings.title'), '设置');
        expect(zhLocalizations.t('settings.theme.dark'), '深色');
        expect(zhLocalizations.t('settings.language.zh'), '汉语');
      });

      test('不存在的键应返回键名', () {
        expect(zhLocalizations.t('nonexistent.key'), '[nonexistent.key]');
      });
    });

    group('维吾尔语翻译', () {
      late AppLocalizations ugLocalizations;

      setUp(() {
        ugLocalizations = AppLocalizations(const Locale('ug', 'CN'));
      });

      test('应返回正确的维吾尔语翻译', () {
        expect(ugLocalizations.t('home.title'), 'تەرجىمان');
        expect(ugLocalizations.t('home.button.translate'), 'تەرجىمە');
        expect(ugLocalizations.t('common.cancel'), 'بىكار قىلىش');
      });

      test('应返回所有 Splash 键的维吾尔语翻译', () {
        expect(ugLocalizations.t('splash.loading'), 'يۈكلىنىۋاتىدۇ');
        expect(ugLocalizations.t('splash.logo.alt'), 'تەرجىمان ئەپ');
        expect(ugLocalizations.t('splash.version'), 'نەشرى');
      });

      test('应返回所有 Onboarding 键的维吾尔语翻译', () {
        expect(ugLocalizations.t('onboarding.welcome'), 'خوش كەپسىز');
        expect(ugLocalizations.t('onboarding.button.next'), 'كېيىنكى');
        expect(ugLocalizations.t('onboarding.button.start'), 'باشلاش');
        expect(ugLocalizations.t('onboarding.button.skip'), 'ئاتلاش');
      });

      test('应返回所有 Home 键的维吾尔语翻译', () {
        expect(ugLocalizations.t('home.subtitle'), 'ئۇيغۇرچە-خەنزۇچە');
        expect(ugLocalizations.t('home.input.placeholder'), 'تېكىستنى كىرگۈزۈڭ');
        expect(ugLocalizations.t('home.mode.text'), 'تېكىست');
        expect(ugLocalizations.t('home.mode.voice'), 'ئاۋاز');
        expect(ugLocalizations.t('home.lang.chinese'), 'خەنزۇچە');
        expect(ugLocalizations.t('home.lang.uyghur'), 'ئۇيغۇرچە');
      });

      test('应返回所有 Result 键的维吾尔语翻译', () {
        expect(ugLocalizations.t('result.title'), 'تەرجىمە نەتىجىسى');
        expect(ugLocalizations.t('result.action.copy'), 'كۆچۈرۈش');
        expect(ugLocalizations.t('result.action.favorite'), 'خالىغانلار');
        expect(ugLocalizations.t('result.action.share'), 'ئورتاقلىشىش');
      });

      test('不存在的键应返回键名', () {
        expect(ugLocalizations.t('nonexistent.key'), '[nonexistent.key]');
      });
    });

    group('AppLocalizationsDelegate', () {
      const delegate = AppLocalizationsDelegate();

      test('应支持中文', () {
        expect(delegate.isSupported(const Locale('zh', 'CN')), true);
        expect(delegate.isSupported(const Locale('zh')), true);
      });

      test('应支持维吾尔语', () {
        expect(delegate.isSupported(const Locale('ug', 'CN')), true);
        expect(delegate.isSupported(const Locale('ug')), true);
      });

      test('不应支持英语', () {
        expect(delegate.isSupported(const Locale('en', 'US')), false);
        expect(delegate.isSupported(const Locale('en')), false);
      });

      test('不应重新加载', () {
        expect(delegate.shouldReload(delegate), false);
      });

      test('应正确加载本地化', () async {
        final localization = await delegate.load(const Locale('zh', 'CN'));
        expect(localization, isA<AppLocalizations>());
        expect(localization.locale.languageCode, 'zh');
      });
    });

    group('翻译键完整性', () {
      test('中文和维吾尔语应有相同数量的翻译键', () {
        final zh = AppLocalizations(const Locale('zh'));
        final ug = AppLocalizations(const Locale('ug'));

        // 测试一些关键部分确保镜像
        final zhKeys = [
          'home.title', 'home.subtitle', 'settings.title',
          'common.cancel', 'common.confirm', 'result.title',
          'voice.title', 'camera.title', 'dict.title',
        ];

        for (final key in zhKeys) {
          expect(zh.t(key), isNot(startsWith('[')), reason: '中文缺少键: $key');
          expect(ug.t(key), isNot(startsWith('[')), reason: '维吾尔语缺少键: $key');
        }
      });

      test('错误消息应完整', () {
        final zh = AppLocalizations(const Locale('zh'));
        final ug = AppLocalizations(const Locale('ug'));

        final errorKeys = [
          'error.network.title', 'error.network.message',
          'error.server.title', 'error.server.message',
          'error.timeout.title', 'error.timeout.message',
          'error.permission.title', 'error.permission.message',
          'error.unknown.title', 'error.unknown.message',
        ];

        for (final key in errorKeys) {
          expect(zh.t(key), isNot(startsWith('[')), reason: '中文缺少错误键: $key');
          expect(ug.t(key), isNot(startsWith('[')), reason: '维吾尔语缺少错误键: $key');
        }
      });

      test('无障碍文本应完整', () {
        final zh = AppLocalizations(const Locale('zh'));
        final ug = AppLocalizations(const Locale('ug'));

        final a11yKeys = [
          'a11y.button.back', 'a11y.button.close', 'a11y.button.menu',
          'a11y.button.settings', 'a11y.button.search',
          'a11y.input.text', 'a11y.input.voice',
        ];

        for (final key in a11yKeys) {
          expect(zh.t(key), isNot(startsWith('[')), reason: '中文缺少a11y键: $key');
          expect(ug.t(key), isNot(startsWith('[')), reason: '维吾尔语缺少a11y键: $key');
        }
      });
    });
  });
}
