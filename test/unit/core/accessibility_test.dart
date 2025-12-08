/// 辅助功能模块测试
///
/// 测试辅助功能设置和辅助工具
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// flutter_riverpod removed - not used in tests
import 'package:uyghur_translator/core/accessibility/accessibility_settings.dart';
import 'package:uyghur_translator/core/accessibility/accessibility_helpers.dart';
import 'package:uyghur_translator/core/accessibility/accessibility_provider.dart';

void main() {
  group('AccessibilitySettings', () {
    test('should have correct default values', () {
      const settings = AccessibilitySettings();

      expect(settings.fontSize, FontSizePreset.normal);
      expect(settings.boldText, false);
      expect(settings.contrast, ContrastPreset.normal);
      expect(settings.animation, AnimationPreset.normal);
      expect(settings.screenReaderOptimized, false);
      expect(settings.largerTouchTargets, false);
      expect(settings.hapticFeedback, true);
      expect(settings.colorBlindMode, ColorBlindMode.none);
    });

    test('should create copy with modified values', () {
      const settings = AccessibilitySettings();
      final modified = settings.copyWith(
        fontSize: FontSizePreset.large,
        boldText: true,
      );

      expect(modified.fontSize, FontSizePreset.large);
      expect(modified.boldText, true);
      expect(modified.contrast, ContrastPreset.normal); // unchanged
    });

    test('should serialize and deserialize correctly', () {
      const original = AccessibilitySettings(
        fontSize: FontSizePreset.large,
        boldText: true,
        contrast: ContrastPreset.high,
        animation: AnimationPreset.reduced,
      );

      final json = original.toJson();
      final restored = AccessibilitySettings.fromJson(json);

      expect(restored, original);
    });

    test('animationDurationFactor should return correct values', () {
      expect(
        const AccessibilitySettings(animation: AnimationPreset.normal)
            .animationDurationFactor,
        1.0,
      );
      expect(
        const AccessibilitySettings(animation: AnimationPreset.reduced)
            .animationDurationFactor,
        0.5,
      );
      expect(
        const AccessibilitySettings(animation: AnimationPreset.none)
            .animationDurationFactor,
        0.0,
      );
    });

    test('disableAnimations should return true when animation is none', () {
      expect(
        const AccessibilitySettings(animation: AnimationPreset.normal)
            .disableAnimations,
        false,
      );
      expect(
        const AccessibilitySettings(animation: AnimationPreset.none)
            .disableAnimations,
        true,
      );
    });

    test('minTouchTargetSize should be larger when enabled', () {
      expect(
        const AccessibilitySettings(largerTouchTargets: false)
            .minTouchTargetSize,
        44.0,
      );
      expect(
        const AccessibilitySettings(largerTouchTargets: true)
            .minTouchTargetSize,
        56.0,
      );
    });
  });

  group('FontSizePreset', () {
    test('should have correct scale factors', () {
      expect(FontSizePreset.small.scaleFactor, 0.85);
      expect(FontSizePreset.normal.scaleFactor, 1.0);
      expect(FontSizePreset.large.scaleFactor, 1.15);
      expect(FontSizePreset.extraLarge.scaleFactor, 1.3);
      expect(FontSizePreset.huge.scaleFactor, 1.5);
    });
  });

  group('ContrastPreset', () {
    test('should have correct factors', () {
      expect(ContrastPreset.normal.factor, 1.0);
      expect(ContrastPreset.high.factor, 1.2);
      expect(ContrastPreset.highest.factor, 1.5);
    });
  });

  group('AccessibilityHelpers', () {
    test('scaledFontSize should scale correctly', () {
      const settings = AccessibilitySettings(fontSize: FontSizePreset.large);

      expect(
        AccessibilityHelpers.scaledFontSize(16.0, settings),
        closeTo(18.4, 0.1), // 16 * 1.15
      );
    });

    test('scaledFontSize should add extra for bold text', () {
      const settings = AccessibilitySettings(
        fontSize: FontSizePreset.normal,
        boldText: true,
      );

      expect(
        AccessibilityHelpers.scaledFontSize(16.0, settings),
        closeTo(16.8, 0.1), // 16 * 1.0 * 1.05
      );
    });

    test('scaledFontWeight should increase weight when bold enabled', () {
      const normalSettings = AccessibilitySettings(boldText: false);
      const boldSettings = AccessibilitySettings(boldText: true);

      expect(
        AccessibilityHelpers.scaledFontWeight(FontWeight.w400, normalSettings),
        FontWeight.w400,
      );
      expect(
        AccessibilityHelpers.scaledFontWeight(FontWeight.w400, boldSettings),
        FontWeight.w600,
      );
    });

    test('scaledDuration should return zero when animations disabled', () {
      const settings = AccessibilitySettings(animation: AnimationPreset.none);

      expect(
        AccessibilityHelpers.scaledDuration(
          const Duration(milliseconds: 300),
          settings,
        ),
        Duration.zero,
      );
    });

    test('scaledDuration should reduce duration when reduced', () {
      const settings =
          AccessibilitySettings(animation: AnimationPreset.reduced);

      expect(
        AccessibilityHelpers.scaledDuration(
          const Duration(milliseconds: 300),
          settings,
        ),
        const Duration(milliseconds: 150),
      );
    });

    test('calculateContrastRatio should return valid ratio', () {
      // Black on white should have high contrast
      final ratio = AccessibilityHelpers.calculateContrastRatio(
        Colors.black,
        Colors.white,
      );
      expect(ratio, greaterThan(20.0)); // Should be about 21:1
    });

    test('meetsContrastRatioAA should validate correctly', () {
      // High contrast colors
      expect(
        AccessibilityHelpers.meetsContrastRatioAA(Colors.black, Colors.white),
        true,
      );

      // Low contrast colors (both dark)
      expect(
        AccessibilityHelpers.meetsContrastRatioAA(
          Colors.grey.shade800,
          Colors.grey.shade700,
        ),
        false,
      );
    });
  });

  group('AccessibilityColors', () {
    test('should simulate protanopia', () {
      const settings = AccessibilitySettings(
        colorBlindMode: ColorBlindMode.protanopia,
      );
      const colors = AccessibilityColors(settings);

      final adjusted = colors.adjust(Colors.red);
      // Red should appear different in protanopia
      expect(adjusted.r, isNot(Colors.red.r));
    });

    test('should simulate achromatopsia (grayscale)', () {
      const settings = AccessibilitySettings(
        colorBlindMode: ColorBlindMode.achromatopsia,
      );
      const colors = AccessibilityColors(settings);

      final adjusted = colors.adjust(Colors.red);
      // In grayscale, R=G=B
      expect(adjusted.r, adjusted.g);
      expect(adjusted.g, adjusted.b);
    });

    test('should not modify when colorBlindMode is none', () {
      const settings = AccessibilitySettings(
        colorBlindMode: ColorBlindMode.none,
      );
      const colors = AccessibilityColors(settings);

      const original = Color(0xFFFF5722);
      final adjusted = colors.adjust(original);
      expect(adjusted, original);
    });
  });

  group('AccessibilityProvider', () {
    // 这些测试需要 Hive 初始化，在单元测试中跳过
    // 应该在集成测试中测试这些功能
    test('provider should be defined', () {
      // 只测试 provider 是否被正确定义
      expect(accessibilityProvider, isNotNull);
      expect(reduceMotionProvider, isNotNull);
      expect(fontScaleProvider, isNotNull);
      expect(minTouchTargetProvider, isNotNull);
      expect(hapticFeedbackEnabledProvider, isNotNull);
    });
  });

  group('AccessibilityColorExtension', () {
    test('contrastingColor should return black for light colors', () {
      expect(Colors.white.contrastingColor, Colors.black);
      expect(Colors.yellow.contrastingColor, Colors.black);
    });

    test('contrastingColor should return white for dark colors', () {
      expect(Colors.black.contrastingColor, Colors.white);
      expect(Colors.deepPurple.shade900.contrastingColor, Colors.white);
    });
  });
}
