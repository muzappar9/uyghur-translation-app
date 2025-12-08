# 🔒 可重复验证清单 (VERIFICATION_CHECKLIST.md)

**创建日期**: 2025-01-XX  
**目的**: 消除检查结果不一致问题，建立系统化可复现的验证标准

---

## 📊 执行此清单的说明

> **每次检查必须运行以下精确命令，结果必须记录到此文档底部的"验证历史"部分**

---

## ✅ Stage 14-18 验证命令 (PowerShell)

### Stage 14: 离线模式
```powershell
# 文件存在性 + 行数
$f = "d:\princip计划\ai翻译\uyghur-translation-app1\lib\core\network\offline_mode_service.dart"
(Get-Content $f | Measure-Object -Line).Lines
# 期望: 存在，行数记录
```

### Stage 15: 国际化
```powershell
# 主文件行数
$f = "d:\princip计划\ai翻译\uyghur-translation-app1\lib\i18n\localizations.dart"
(Get-Content $f | Measure-Object -Line).Lines
# i18n目录文件数
(Get-ChildItem "d:\princip计划\ai翻译\uyghur-translation-app1\lib\i18n" -File).Count
```

### Stage 16: 性能优化
```powershell
# performance目录所有文件
Get-ChildItem "d:\princip计划\ai翻译\uyghur-translation-app1\lib\core\performance" -File | ForEach-Object { Write-Host "$($_.Name): $((Get-Content $_.FullName | Measure-Object -Line).Lines)" }
```

### Stage 17: 测试覆盖
```powershell
# 测试文件数量
(Get-ChildItem "d:\princip计划\ai翻译\uyghur-translation-app1\test" -Recurse -Filter "*.dart").Count
# 运行测试（只看最终结果）
cd "d:\princip计划\ai翻译\uyghur-translation-app1"; flutter test 2>&1 | Select-String "passed|failed|skipped"
```

### Stage 18: 同步/缓存
```powershell
# sync目录
Get-ChildItem "d:\princip计划\ai翻译\uyghur-translation-app1\lib\core\sync" -File | ForEach-Object { Write-Host "$($_.Name): $((Get-Content $_.FullName | Measure-Object -Line).Lines)" }
# cache目录  
Get-ChildItem "d:\princip计划\ai翻译\uyghur-translation-app1\lib\core\cache" -File | ForEach-Object { Write-Host "$($_.Name): $((Get-Content $_.FullName | Measure-Object -Line).Lines)" }
```

---

## 📋 集成度验证命令

### 检查文件是否被import
```powershell
# 通用格式：检查 [文件名] 被引用次数
Select-String -Path "d:\princip计划\ai翻译\uyghur-translation-app1\lib\**\*.dart" -Pattern "import.*[文件名]" | Measure-Object | Select-Object Count
```

### 示例：检查关键文件集成度
```powershell
# responsive_layout.dart 被引用次数
Select-String -Path "d:\princip计划\ai翻译\uyghur-translation-app1\lib\**\*.dart" -Pattern "responsive_layout" | Measure-Object | Select-Object Count

# offline_mode_service.dart 被引用次数
Select-String -Path "d:\princip计划\ai翻译\uyghur-translation-app1\lib\**\*.dart" -Pattern "offline_mode_service" | Measure-Object | Select-Object Count

# localizations.dart 被引用次数
Select-String -Path "d:\princip计划\ai翻译\uyghur-translation-app1\lib\**\*.dart" -Pattern "localizations" | Measure-Object | Select-Object Count
```

---

## 🎯 一键全量验证脚本

将以下内容保存为 `verify_project.ps1`:

```powershell
# verify_project.ps1 - 项目验证脚本
$projectRoot = "d:\princip计划\ai翻译\uyghur-translation-app1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PROJECT VERIFICATION: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Stage 14
Write-Host "`n[Stage 14] Offline Mode:" -ForegroundColor Yellow
$f14 = "$projectRoot\lib\core\network\offline_mode_service.dart"
$l14 = (Get-Content $f14 -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
Write-Host "  offline_mode_service.dart: $l14 lines"

# 2. Stage 15
Write-Host "`n[Stage 15] i18n:" -ForegroundColor Yellow
$f15 = "$projectRoot\lib\i18n\localizations.dart"
$l15 = (Get-Content $f15 -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
$i18nFiles = (Get-ChildItem "$projectRoot\lib\i18n" -File -ErrorAction SilentlyContinue).Count
Write-Host "  localizations.dart: $l15 lines"
Write-Host "  i18n files count: $i18nFiles"

# 3. Stage 16
Write-Host "`n[Stage 16] Performance:" -ForegroundColor Yellow
Get-ChildItem "$projectRoot\lib\core\performance" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    Write-Host "  $($_.Name): $lines lines"
}

# 4. Stage 17
Write-Host "`n[Stage 17] Tests:" -ForegroundColor Yellow
$testFiles = (Get-ChildItem "$projectRoot\test" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue).Count
Write-Host "  Test files: $testFiles"

# 5. Stage 18
Write-Host "`n[Stage 18] Sync/Cache:" -ForegroundColor Yellow
Get-ChildItem "$projectRoot\lib\core\sync" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    Write-Host "  $($_.Name): $lines lines"
}
Get-ChildItem "$projectRoot\lib\core\cache" -File -ErrorAction SilentlyContinue | ForEach-Object {
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    Write-Host "  $($_.Name): $lines lines"
}

# 6. 关键文件集成度
Write-Host "`n[Integration Check]:" -ForegroundColor Yellow
$patterns = @("responsive_layout", "offline_mode_service", "localizations", "performance_monitor")
foreach ($p in $patterns) {
    $count = (Select-String -Path "$projectRoot\lib\**\*.dart" -Pattern $p -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "  $p imports: $count"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
```

---

## 📝 验证历史记录

### 验证 #1: 2025-XX-XX (本次)

| 项目 | EXECUTION_PLAN_V2.md 声称 | 实际测量值 | 差异 |
|------|-------------------------|-----------|-----|
| Stage 14: offline_mode_service.dart | 518 lines | **444 lines** | -74 |
| Stage 15: localizations.dart | 795 lines | **759 lines** | -36 |
| Stage 16: performance/ | 完整 | **2 files, 669 lines** | ✅ |
| Stage 17: test files | 43 files | **44 files** | +1 |
| Stage 17: test count | 491 tests | **521 pass + 42 skip** | +72 |
| Stage 18: sync/ | 存在 | **2 files, 505 lines** | ✅ |
| Stage 18: cache/ | 存在 | **2 files, 688 lines** | ✅ |

**结论**: Stage 14-18 **文件全部存在**，但行数与文档声称有偏差(可能是后续修改导致)。核心功能已实现。

---

## ⚠️ 为什么以前的检查结果不一致？

### 根本原因分析

1. **模糊定义问题**
   - "完成度"没有明确定义：是"文件存在"还是"功能集成"？
   - 不同角度得出不同结论

2. **没有固定验证流程**
   - 每次用不同方法检查
   - 人为判断引入主观性

3. **文档与代码不同步**
   - EXECUTION_PLAN_V2.md 声称的行数与实际不符
   - 可能在写文档后代码又有修改

4. **集成度 vs 存在性混淆**
   - 文件存在 ≠ 功能集成
   - 例如：responsive_layout.dart 存在 537 行，但 0 次被import

### 解决方案

1. **使用此清单**：每次验证运行相同命令
2. **记录历史**：将结果追加到本文档
3. **区分概念**：
   - **存在性**: 文件是否存在
   - **行数**: 代码量
   - **集成度**: 被其他文件import次数
   - **测试覆盖**: 有无对应测试
4. **自动化**: 使用 verify_project.ps1 脚本

---

## 🔑 关键指标定义

| 指标 | 定义 | 验证方法 |
|-----|------|---------|
| 文件存在 | 文件物理存在于预期路径 | `Test-Path` |
| 代码行数 | 非空行数 | `Measure-Object -Line` |
| 集成度 | 被其他 .dart 文件 import 的次数 | `Select-String -Pattern` |
| 测试覆盖 | 对应功能有测试文件且测试通过 | `flutter test` |
| 编译状态 | 0 错误 0 警告 | `flutter analyze` |

