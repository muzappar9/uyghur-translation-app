import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置屏幕
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // 显示和主题
          _buildSectionHeader('显示和主题'),
          ListTile(
            title: const Text('深色模式'),
            subtitle: const Text('使用深色主题'),
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ),
          const Divider(),

          // 语言和翻译
          _buildSectionHeader('语言和翻译'),
          ListTile(
            title: const Text('默认语言'),
            subtitle: const Text('中文'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('翻译引擎'),
            subtitle: const Text('Google Translate'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('当前仅支持Google Translate')),
              );
            },
          ),
          const Divider(),

          // 数据和同步
          _buildSectionHeader('数据和同步'),
          ListTile(
            title: const Text('自动同步'),
            subtitle: const Text('云同步翻译记录和识别结果'),
            trailing: Switch(
              value: _autoSync,
              onChanged: (value) {
                setState(() {
                  _autoSync = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('清空缓存'),
            subtitle: const Text('删除本地缓存的翻译记录'),
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          const Divider(),

          // 通知和提醒
          _buildSectionHeader('通知和提醒'),
          ListTile(
            title: const Text('启用通知'),
            subtitle: const Text('接收同步完成等通知'),
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
          ),
          const Divider(),

          // 关于应用
          _buildSectionHeader('关于应用'),
          const ListTile(
            title: Text('应用版本'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('打开浏览器')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('用户协议'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('打开浏览器')),
              );
            },
          ),
          const Divider(),

          // 登出按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择默认语言'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLanguageOption('中文 (简体)', 'zh'),
              _buildLanguageOption('维吾尔语', 'ug'),
              _buildLanguageOption('英语', 'en'),
              _buildLanguageOption('阿拉伯语', 'ar'),
              _buildLanguageOption('俄语', 'ru'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空缓存'),
        content: const Text('确定要删除所有本地缓存的翻译记录吗？\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清空')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现登出逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已登出')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
