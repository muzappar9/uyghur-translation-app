/// 辅助功能设置页面
///
/// 提供辅助功能设置界面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/accessibility/accessibility.dart';
import '../widgets/glass_card.dart';

/// 辅助功能设置页面
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '辅助功能',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        notifier.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已重置为默认设置')),
                        );
                      },
                      child: const Text(
                        '重置',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 视觉
                      const _SectionTitle(title: '视觉'),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            // 字体大小
                            _SettingsRow(
                              title: '字体大小',
                              subtitle: settings.fontSize.displayName,
                              icon: Icons.text_fields,
                              trailing: DropdownButton<FontSizePreset>(
                                value: settings.fontSize,
                                dropdownColor: Colors.black87,
                                underline: const SizedBox(),
                                items: FontSizePreset.values.map((preset) {
                                  return DropdownMenuItem(
                                    value: preset,
                                    child: Text(
                                      preset.displayName,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    notifier.setFontSize(value);
                                  }
                                },
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 粗体文字
                            _SettingsRow(
                              title: '粗体文字',
                              subtitle: '使用更粗的字体',
                              icon: Icons.format_bold,
                              trailing: Switch(
                                value: settings.boldText,
                                onChanged: (value) =>
                                    notifier.setBoldText(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 对比度
                            _SettingsRow(
                              title: '对比度',
                              subtitle: settings.contrast.displayName,
                              icon: Icons.contrast,
                              trailing: DropdownButton<ContrastPreset>(
                                value: settings.contrast,
                                dropdownColor: Colors.black87,
                                underline: const SizedBox(),
                                items: ContrastPreset.values.map((preset) {
                                  return DropdownMenuItem(
                                    value: preset,
                                    child: Text(
                                      preset.displayName,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    notifier.setContrast(value);
                                  }
                                },
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 减少透明度
                            _SettingsRow(
                              title: '减少透明度',
                              subtitle: '增强可读性',
                              icon: Icons.opacity,
                              trailing: Switch(
                                value: settings.reduceTransparency,
                                onChanged: (value) =>
                                    notifier.setReduceTransparency(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 色盲模式
                            _SettingsRow(
                              title: '色盲模式',
                              subtitle: settings.colorBlindMode.displayName,
                              icon: Icons.colorize,
                              trailing: DropdownButton<ColorBlindMode>(
                                value: settings.colorBlindMode,
                                dropdownColor: Colors.black87,
                                underline: const SizedBox(),
                                items: ColorBlindMode.values.map((mode) {
                                  return DropdownMenuItem(
                                    value: mode,
                                    child: Text(
                                      mode.displayName,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    notifier.setColorBlindMode(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 动效
                      const _SectionTitle(title: '动效'),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            // 动画设置
                            _SettingsRow(
                              title: '动画效果',
                              subtitle: settings.animation.displayName,
                              icon: Icons.animation,
                              trailing: DropdownButton<AnimationPreset>(
                                value: settings.animation,
                                dropdownColor: Colors.black87,
                                underline: const SizedBox(),
                                items: AnimationPreset.values.map((preset) {
                                  return DropdownMenuItem(
                                    value: preset,
                                    child: Text(
                                      preset.displayName,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    notifier.setAnimation(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 交互
                      const _SectionTitle(title: '交互'),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            // 触摸目标放大
                            _SettingsRow(
                              title: '放大触摸目标',
                              subtitle: '增加按钮和控件的点击区域',
                              icon: Icons.touch_app,
                              trailing: Switch(
                                value: settings.largerTouchTargets,
                                onChanged: (value) =>
                                    notifier.setLargerTouchTargets(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 焦点高亮
                            _SettingsRow(
                              title: '焦点高亮',
                              subtitle: '显示当前焦点位置',
                              icon: Icons.center_focus_strong,
                              trailing: Switch(
                                value: settings.highlightFocus,
                                onChanged: (value) =>
                                    notifier.setHighlightFocus(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 触觉反馈
                            _SettingsRow(
                              title: '触觉反馈',
                              subtitle: '操作时震动提示',
                              icon: Icons.vibration,
                              trailing: Switch(
                                value: settings.hapticFeedback,
                                onChanged: (value) =>
                                    notifier.setHapticFeedback(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 屏幕阅读器
                      const _SectionTitle(title: '屏幕阅读器'),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            // 屏幕阅读器优化
                            _SettingsRow(
                              title: '屏幕阅读器优化',
                              subtitle: '为 VoiceOver/TalkBack 优化',
                              icon: Icons.record_voice_over,
                              trailing: Switch(
                                value: settings.screenReaderOptimized,
                                onChanged: (value) =>
                                    notifier.setScreenReaderOptimized(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),

                            // 语音反馈
                            _SettingsRow(
                              title: '语音反馈',
                              subtitle: '朗读操作结果',
                              icon: Icons.volume_up,
                              trailing: Switch(
                                value: settings.voiceFeedback,
                                onChanged: (value) =>
                                    notifier.setVoiceFeedback(value),
                                activeTrackColor: Colors.white.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget trailing;

  const _SettingsRow({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
