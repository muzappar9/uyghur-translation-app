#!/usr/bin/env python3
"""
自动修复 Flutter 项目中的弃用 API 和代码问题
"""
import os
import re
from pathlib import Path

def fix_with_opacity(content):
    """替换 withOpacity() 为 .withValues()"""
    # Colors.black.withOpacity(0.3) -> Colors.black.withValues(alpha: 0.3)
    # Color(0xFFFF6B6B).withOpacity(0.5) -> Color(0xFFFF6B6B).withValues(alpha: 0.5)
    pattern = r'(\w+(?:\.\w+)*)\s*\.withOpacity\s*\(\s*([\d.]+)\s*\)'
    replacement = r'\1.withValues(alpha: \2)'
    return re.sub(pattern, replacement, content)

def remove_unused_imports(content, unused_imports):
    """移除未使用的 import"""
    for imp in unused_imports:
        # import 'package:flutter/material.dart';
        pattern = f"import\\s+['\"]({re.escape(imp)})['\"];?\\s*\\n"
        content = re.sub(pattern, '', content)
    return content

def remove_print_statements(content):
    """移除生产代码中的 print() 调用"""
    # 只移除顶层的 print 语句，不是作为参数的
    lines = content.split('\n')
    result = []
    for line in lines:
        # 如果是纯 print 语句，注释掉
        if re.match(r'\s*print\s*\(', line):
            result.append('    // ' + line.lstrip('/ '))
        else:
            result.append(line)
    return '\n'.join(result)

# 处理文件列表
files_to_fix = [
    'lib/screens/camera_screen.dart',
    'lib/screens/conversation_screen.dart',
    'lib/screens/dictionary_detail_screen.dart',
    'lib/screens/dictionary_home_screen.dart',
    'lib/screens/history_screen.dart',
    'lib/screens/language_switcher_page.dart',
    'lib/screens/ocr_result_screen.dart',
    'lib/screens/onboarding_screen.dart',
    'lib/screens/settings_screen.dart',
    'lib/screens/splash_screen.dart',
    'lib/screens/translate_result_screen.dart',
    'lib/screens/voice_input_screen.dart',
    'lib/widgets/chat_bubble.dart',
    'lib/widgets/glass_button.dart',
    'lib/widgets/glass_card.dart',
    'lib/widgets/language_switch_bar.dart',
    'lib/widgets/mode_segmented_control.dart',
]

print("开始修复弃用 API...")
for file_path in files_to_fix:
    full_path = Path(file_path)
    if full_path.exists():
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 修复 withOpacity
        content = fix_with_opacity(content)
        
        # 修复 print (history_screen.dart 中有)
        if 'history_screen' in file_path:
            content = remove_print_statements(content)
        
        # 修复 unused imports
        if 'conversation_screen' in file_path:
            content = remove_unused_imports(content, ["../widgets/glass_card.dart"])
        if 'voice_input_screen' in file_path:
            content = remove_unused_imports(content, ["dart:math"])
        
        if content != original_content:
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ 已修复: {file_path}")
        else:
            print(f"✗ 无需修改: {file_path}")
    else:
        print(f"✗ 文件不存在: {file_path}")

print("修复完成！")
