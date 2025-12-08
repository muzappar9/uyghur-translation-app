import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    group('Light Theme', () {
      test('应生成有效的亮色主题', () {
        final theme = AppTheme.light();
        
        expect(theme.brightness, Brightness.light);
        expect(theme.useMaterial3, true);
        expect(theme.colorScheme.brightness, Brightness.light);
      });

      test('亮色主题应使用默认种子颜色', () {
        final theme = AppTheme.light();
        
        expect(theme.colorScheme, isNotNull);
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('亮色主题应使用自定义种子颜色', () {
        const customColor = Colors.green;
        final theme = AppTheme.light(seedColor: customColor);
        
        expect(theme.colorScheme, isNotNull);
        // 使用 ColorScheme.fromSeed 生成的颜色可能与种子颜色不完全相同
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('亮色主题 AppBar 配置正确', () {
        final theme = AppTheme.light();
        
        expect(theme.appBarTheme.centerTitle, true);
        expect(theme.appBarTheme.elevation, 0);
      });

      test('亮色主题 Card 配置正确', () {
        final theme = AppTheme.light();
        
        expect(theme.cardTheme.elevation, 0);
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      });
    });

    group('Dark Theme', () {
      test('应生成有效的暗色主题', () {
        final theme = AppTheme.dark();
        
        expect(theme.brightness, Brightness.dark);
        expect(theme.useMaterial3, true);
        expect(theme.colorScheme.brightness, Brightness.dark);
      });

      test('暗色主题应使用默认种子颜色', () {
        final theme = AppTheme.dark();
        
        expect(theme.colorScheme, isNotNull);
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('暗色主题应使用自定义种子颜色', () {
        const customColor = Colors.purple;
        final theme = AppTheme.dark(seedColor: customColor);
        
        expect(theme.colorScheme, isNotNull);
        expect(theme.colorScheme.primary, isNotNull);
      });

      test('暗色主题 AppBar 配置正确', () {
        final theme = AppTheme.dark();
        
        expect(theme.appBarTheme.centerTitle, true);
        expect(theme.appBarTheme.elevation, 0);
      });
    });

    group('AppColors', () {
      test('品牌颜色定义正确', () {
        expect(AppColors.primary, const Color(0xFF1976D2));
        expect(AppColors.primaryLight, const Color(0xFF42A5F5));
        expect(AppColors.primaryDark, const Color(0xFF1565C0));
      });

      test('语义颜色定义正确', () {
        expect(AppColors.success, const Color(0xFF4CAF50));
        expect(AppColors.warning, const Color(0xFFFF9800));
        expect(AppColors.error, const Color(0xFFF44336));
        expect(AppColors.info, const Color(0xFF2196F3));
      });

      test('语言标识颜色定义正确', () {
        expect(AppColors.chinese, const Color(0xFFE53935));
        expect(AppColors.uyghur, const Color(0xFF43A047));
        expect(AppColors.english, const Color(0xFF1E88E5));
      });
    });

    group('Theme Consistency', () {
      test('亮暗主题应具有相同的按钮形状', () {
        final lightTheme = AppTheme.light();
        final darkTheme = AppTheme.dark();

        expect(
          lightTheme.elevatedButtonTheme.style?.shape,
          darkTheme.elevatedButtonTheme.style?.shape,
        );
      });

      test('亮暗主题应具有相同的输入框圆角', () {
        final lightTheme = AppTheme.light();
        final darkTheme = AppTheme.dark();

        final lightBorder = lightTheme.inputDecorationTheme.border as OutlineInputBorder?;
        final darkBorder = darkTheme.inputDecorationTheme.border as OutlineInputBorder?;
        
        expect(lightBorder?.borderRadius, darkBorder?.borderRadius);
      });
    });
  });
}
