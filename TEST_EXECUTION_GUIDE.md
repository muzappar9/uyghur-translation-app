# 🚀 Step 9 测试执行命令与调试指南

## 目录
1. [快速开始](#快速开始)
2. [运行单个测试](#运行单个测试)
3. [生成覆盖率报告](#生成覆盖率报告)
4. [故障排除](#故障排除)
5. [性能分析](#性能分析)

---

## 快速开始

### 准备环境

```powershell
# 检查 Flutter 版本
flutter --version

# 获取最新依赖
flutter pub get

# 检查测试环境
flutter test --machine 2>&1 | head -20
```

### 运行所有测试

```powershell
# 基础测试运行
flutter test

# 详细输出
flutter test --verbose

# JSON 输出（用于 CI/CD）
flutter test --machine > test_results.json
```

---

## 运行单个测试

### 引擎层测试 (Day 1)

```powershell
# 全部引擎测试
flutter test test/unit/engines/

# 翻译引擎测试
flutter test test/unit/engines/translation_engine_test.dart

# 语音识别引擎测试
flutter test test/unit/engines/voice_recognition_engine_test.dart

# OCR 识别引擎测试
flutter test test/unit/engines/ocr_recognition_engine_test.dart
```

**预期**: 31 个测试全部通过 ✅

```
$ flutter test test/unit/engines/

✓ LocalMockTranslationEngine Tests (10 tests)
✓ LocalVoiceRecognitionEngine Tests (11 tests)
✓ LocalOCRRecognitionEngine Tests (10 tests)

31 tests, 0 failures
```

### 管理器层测试 (Day 2)

```powershell
# 全部管理器测试
flutter test test/unit/managers/

# 翻译管理器测试
flutter test test/unit/managers/translation_manager_test.dart

# 语音识别管理器测试
flutter test test/unit/managers/voice_recognition_manager_test.dart

# OCR 识别管理器测试
flutter test test/unit/managers/ocr_recognition_manager_test.dart
```

**预期**: 36 个测试全部通过 ✅

```
$ flutter test test/unit/managers/

✓ TranslationManager Tests (12 tests)
✓ VoiceRecognitionManager Tests (12 tests)
✓ OCRRecognitionManager Tests (12 tests)

36 tests, 0 failures
```

### 服务层测试 (Day 3 - 待实施)

```powershell
# 全部服务层测试
flutter test test/unit/services/

# 翻译服务测试
flutter test test/unit/services/translation_service_test.dart

# 语音识别服务测试
flutter test test/unit/services/voice_recognition_service_test.dart

# OCR 识别服务测试
flutter test test/unit/services/ocr_recognition_service_test.dart

# 数据库服务测试
flutter test test/unit/services/isar_database_service_test.dart
```

### 仓储层测试 (Day 3 - 待实施)

```powershell
# 全部仓储层测试
flutter test test/unit/repositories/

# 翻译历史仓储测试
flutter test test/unit/repositories/translation_history_repository_test.dart

# 待同步队列测试
flutter test test/unit/repositories/pending_sync_queue_test.dart

# 收藏管理器测试
flutter test test/unit/repositories/favorites_manager_test.dart

# 分析服务测试
flutter test test/unit/repositories/analytics_service_test.dart
```

### 集成测试 (Day 4 - 待实施)

```powershell
# 全部集成测试
flutter test test/integration/

# 翻译完整流程测试
flutter test test/integration/translation_flow_test.dart

# 语音识别完整流程测试
flutter test test/integration/voice_flow_test.dart

# OCR 完整流程测试
flutter test test/integration/ocr_flow_test.dart

# 数据持久化流程测试
flutter test test/integration/data_persistence_test.dart

# 离线同步队列测试
flutter test test/integration/sync_queue_test.dart
```

### 性能测试 (Day 5 - 待实施)

```powershell
# 全部性能测试
flutter test test/performance/

# 缓存性能测试
flutter test test/performance/cache_performance_test.dart

# 数据库性能测试
flutter test test/performance/database_performance_test.dart

# API 性能测试
flutter test test/performance/api_performance_test.dart
```

---

## 生成覆盖率报告

### 方法 1: 使用 Flutter 内置覆盖率

```powershell
# 生成覆盖率数据
flutter test --coverage

# 查看生成的文件
Get-ChildItem coverage/
```

### 方法 2: 使用 lcov 生成 HTML 报告

```powershell
# 安装 lcov（仅需一次）
# Windows 用户: 下载 http://ltp.sourceforge.net/
# 或使用 Chocolatey: choco install lcov

# 生成 HTML 报告
genhtml coverage/lcov.info -o coverage/html

# 打开报告
start coverage/html/index.html
```

### 方法 3: 使用 coverage 包

```powershell
# 安装 coverage 包
flutter pub global activate coverage

# 运行覆盖率收集
dart run coverage:format_coverage --packages=.packages --report-on=lib --in=coverage --out=coverage/lcov.info --lcov

# 生成报告
genhtml -o coverage/html coverage/lcov.info
start coverage/html/index.html
```

### 查看覆盖率统计

```powershell
# 显示覆盖率汇总
dart run coverage:print_coverage coverage/

# 按文件显示覆盖率
dart pub global run coverage:format_coverage --report-on=lib --in=coverage --out=coverage/summary.json
Get-Content coverage/summary.json
```

---

## 故障排除

### 问题 1: 找不到测试文件

```powershell
# ❌ 错误
flutter test test/unit/engines/

# ✅ 解决: 确保在项目根目录
cd d:\princip计划\ai翻译\uyghur-translation-app1
flutter test test/unit/engines/
```

### 问题 2: Mock 类不识别

**症状**: 
```
Error: The class 'MockTranslationEngine' is not defined
```

**解决**:
```powershell
# 1. 清除 pub 缓存
flutter clean
flutter pub get

# 2. 检查 pubspec.yaml 中 mockito 版本
# dev_dependencies:
#   mockito: ^5.4.0

# 3. 运行生成代码
flutter pub run build_runner build
```

### 问题 3: 异步测试超时

**症状**:
```
Test timed out after 30 seconds
```

**解决**:
```powershell
# 增加超时时间
flutter test --test-randomize-ordering-seed=random --timeout=120s

# 或在测试中指定
test('Long operation', () async {
  // ...
}, timeout: Timeout(Duration(minutes: 1)));
```

### 问题 4: 导入路径错误

**症状**:
```
Error: Unable to find module for package:uyghur_translator
```

**解决**:
```powershell
# 检查 pubspec.yaml 中的包名
cat pubspec.yaml | grep "^name:"

# 确保导入正确
# ✅ import 'package:uyghur_translator/...
# ❌ import 'package:uyghur-translator/...
```

### 问题 5: 权限相关错误

**症状**:
```
Test failed: Permission denied for 'coverage' directory
```

**解决**:
```powershell
# 运行提升权限的 PowerShell
Start-Process PowerShell -Verb RunAs

# 或删除旧的覆盖率数据
Remove-Item coverage -Recurse -Force
flutter test --coverage
```

---

## 性能分析

### 测试执行时间统计

```powershell
# 运行测试并显示每个测试的耗时
flutter test --verbose 2>&1 | Select-String "ms|passed"

# 输出格式化的报告
flutter test --machine | ConvertFrom-Json
```

### 分析测试耗时

```powershell
# 获取耗时最长的 10 个测试
flutter test --verbose 2>&1 | 
  Select-String "✓.*ms" | 
  Sort-Object { [int]($_ -replace '.*(\d+)ms.*', '$1') } -Descending | 
  Select-Object -First 10
```

### 内存使用监控

```powershell
# 监控内存使用
while ($true) {
  Get-Process flutter | Select-Object ProcessName, @{Name="Memory (MB)"; Expression={$_.WorkingSet / 1MB}} 
  Start-Sleep 2
}
```

---

## CI/CD 集成

### GitHub Actions 工作流

```yaml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### 本地 CI 模拟

```powershell
# 运行完整的测试套件（如同 CI）
flutter clean
flutter pub get
flutter test --coverage --machine > test_results.json
$results = Get-Content test_results.json | ConvertFrom-Json
$testCount = ($results | Select-Object -ExpandProperty type -Unique | Measure-Object).Count
Write-Host "Tests: $(($results | Where-Object type -eq 'testDone' | Measure-Object).Count) passed"
```

---

## 高级用法

### 并行运行测试

```powershell
# 创建测试任务并发执行
$jobs = @(
  "test/unit/engines/",
  "test/unit/managers/",
  "test/unit/services/",
  "test/unit/repositories/"
)

foreach ($job in $jobs) {
  Start-Job -ScriptBlock {
    param($path)
    Set-Location $path
    flutter test $path
  } -ArgumentList $job
}

Get-Job | Wait-Job
Get-Job | Receive-Job
```

### 自定义测试过滤

```powershell
# 运行包含特定名称的测试
flutter test -n "should translate"

# 排除特定测试
flutter test --exclude-tags slow

# 运行特定标签的测试
flutter test --tags translation

# 随机顺序运行测试
flutter test --test-randomize-ordering-seed=random
```

### 持续集成监控

```powershell
# 设置定时运行
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -Command 'cd D:\project; flutter test --coverage'"
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Flutter Tests" -Description "Daily Flutter Tests"
```

---

## 调试技巧

### 添加日志输出

```dart
// 在测试中添加日志
test('example', () {
  print('Debug: Starting test');
  
  // 代码...
  
  print('Debug: Test completed');
});

// 运行时查看日志
flutter test --verbose
```

### 单步调试

```powershell
# 启用调试器并暂停
flutter test --start-paused

# 使用 observatory 进行远程调试
# 打开浏览器访问输出的 URL
```

### 在 VS Code 中调试

**launch.json**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Tests",
      "type": "dart",
      "request": "launch",
      "program": "test/",
      "console": "integratedTerminal"
    }
  ]
}
```

然后按 F5 开始调试。

---

## 最佳实践

### ✅ 推荐做法

1. **定期运行测试**
   ```powershell
   # 每次提交前运行
   flutter test && git commit -m "..."
   ```

2. **分离单元测试和集成测试**
   ```powershell
   flutter test test/unit/        # 快速
   flutter test test/integration/ # 慢
   ```

3. **使用有意义的测试名称**
   ```dart
   test('✅ Should translate from English to Chinese', () {
     // ...
   });
   ```

4. **添加超时控制**
   ```dart
   test('Long operation', () async {
     // ...
   }, timeout: Timeout(Duration(seconds: 60)));
   ```

### ❌ 避免做法

1. **测试依赖其他测试的结果** ❌
   ```dart
   // 错误：测试 B 依赖测试 A
   late String result;
   test('A', () { result = getValue(); });
   test('B', () { expect(result, isNotNull); }); // 可能失败
   ```

2. **使用过于复杂的 Mock** ❌
   ```dart
   // 避免：Mock 层次过深
   final mock = MockTranslationEngine.deepMock()...
   ```

3. **忽视异步错误** ❌
   ```dart
   // 避免：未等待异步操作
   test('example', () {
     service.initialize(); // 遗漏 await
   });
   ```

---

## 性能基准

基于当前环境的预期性能：

| 测试类型 | 预期耗时 | 数量 |
|---------|--------|------|
| 引擎层测试 | 2-5 秒 | 31 |
| 管理器层测试 | 3-7 秒 | 36 |
| 服务层测试 | 5-10 秒 | 51 |
| 仓储层测试 | 5-10 秒 | 36 |
| 集成测试 | 20-30 秒 | 15 |
| 性能测试 | 30-60 秒 | 5+ |
| **总计** | **60-120 秒** | **68+** |

---

## 参考资源

- [Flutter 测试文档](https://flutter.dev/docs/testing)
- [Mockito 文档](https://pub.dev/packages/mockito)
- [Flutter 测试最佳实践](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Dart 异步测试](https://pub.dev/packages/test#asynchronous-tests)

---

**最后更新**: 2025-12-05  
**状态**: Step 9 Day 1-2 完成，Day 3-5 准备中

