# Phase 2.5 快速参考卡

## 🚀 10秒快速开始

```bash
cd d:\princip计划\ai翻译\uyghur-translation-app1
dart test test/unit/ -v
```

---

## 📊 当前状态

| 项目 | 状态 | 进度 |
|------|------|------|
| Phase 2.4 (离线架构) | ✅ 完成 | 100% |
| Phase 2.5 (测试框架) | 🚀 就绪 | 40% (初始化完成) |
| 测试执行 | ⏳ 待启动 | 0% |

---

## 🧪 测试命令速查

### 运行所有单元测试
```bash
dart test test/unit/ -v
```

### 运行特定测试文件
```bash
# TranslationService
dart test test/unit/services/translation_service_test.dart -v

# NetworkProvider  
dart test test/unit/services/network_provider_test.dart -v

# Repository
dart test test/unit/repositories/pending_translation_repository_test.dart -v
```

### 运行特定测试用例
```bash
dart test test/unit/ -k "translate"  # 名称包含 "translate" 的所有测试
```

### 运行集成测试
```bash
flutter test test/integration/offline_sync_flow_test.dart
```

### 运行性能测试
```bash
flutter test test/performance/queue_performance_test.dart --release -v
```

### 生成覆盖率报告
```bash
dart test --coverage=coverage
# 检查 coverage/lcov.info 或打开 HTML 报告
```

---

## 📋 文档索引

| 文档 | 用途 | 何时阅读 |
|------|------|---------|
| PHASE2_5_PLAN.md | 详细的12小时执行计划 | 规划阶段 |
| PHASE2_5_STARTUP_GUIDE.md | 逐步执行指南 + 故障排除 | 开始前 |
| PHASE2_5_VERIFICATION_CHECKLIST.md | 100+项功能验证清单 | 功能验证阶段 |
| PHASE2_5_INIT.md | 初始化总结 | 快速参考 |
| PHASE2_5_STATUS.md | 执行状态报告 | 进度追踪 |
| 本文件 | 快速参考卡 | 日常使用 |

---

## 🎯 测试覆盖

### 已创建的测试文件 (6个, 1150 LOC)

| 文件 | 用例数 | 关键测试 |
|------|-------|---------|
| TranslationService | 11 | 离线队列、重试、错误 |
| NetworkProvider | 13 | 网络状态、转换、恢复 |
| Repository | 45+ | CRUD、一致性、性能 |
| Integration E2E | 8 | 完整流程、同步、UI |
| Performance | 30+ | 基准、压力、内存 |
| Mocks | - | 支持类和工具 |

---

## 🔍 测试执行顺序 (推荐)

### 第1阶段: 单元测试 (5小时)
```bash
# 1. TranslationService (2小时)
dart test test/unit/services/translation_service_test.dart -v

# 2. NetworkProvider (1.5小时)
dart test test/unit/services/network_provider_test.dart -v

# 3. Repository (1.5小时)
dart test test/unit/repositories/pending_translation_repository_test.dart -v

# 结果: 69个测试用例，>90%覆盖率
```

### 第2阶段: 集成测试 (2小时)
```bash
# 4. E2E流程测试
flutter test test/integration/offline_sync_flow_test.dart

# 结果: 8个完整工作流验证
```

### 第3阶段: 性能测试 (1.5小时)
```bash
# 5. 性能基准测试
flutter test test/performance/queue_performance_test.dart --release -v

# 结果: 30+个性能指标验证
```

### 第4阶段: 功能验证 (2-3小时)
```bash
# 6. 手动验证 (使用设备/模拟器)
flutter run

# 使用 PHASE2_5_VERIFICATION_CHECKLIST.md 检查 100+项
```

---

## ✅ 性能目标

| 指标 | 目标 | 验证方法 |
|------|------|---------|
| 1000项查询 | <100ms | performance_test.dart |
| 100项同步 | <5秒 | performance_test.dart |
| 网络检测 | <100ms | network_provider_test.dart |
| 内存使用 | 无泄漏 | performance_test.dart |
| UI响应 | 流畅60fps | 手动验证 |

---

## 🛠️ 常用命令

### 环境验证
```bash
flutter analyze          # 代码分析
flutter pub get          # 下载依赖
dart run build_runner build --delete-conflicting-outputs  # 生成代码
```

### 调试测试
```bash
dart test test/unit/ -v --chain-stack-traces  # 详细堆栈跟踪
dart test test/unit/ --timeout=60s             # 延长超时时间
dart test test/unit/ -x                        # 首次失败后停止
```

### 生成报告
```bash
dart test --coverage=coverage
dart run coverage:format_coverage --packages=.packages -i coverage -o coverage/lcov.info
# 打开生成的HTML报告查看覆盖率
```

---

## 🐛 问题排查

### 测试找不到文件
```bash
# 确认工作目录
pwd  # 应该在项目根目录

# 验证文件存在
ls test/unit/services/translation_service_test.dart
```

### Mock类错误
```bash
# 检查 mock_classes.dart 是否在 test/mocks 目录
# 所有测试文件应该导入: import '../../../mocks/mock_classes.dart';
```

### 网络相关测试失败
```bash
# 可能是设备网络状态，运行: 
flutter test test/unit/services/network_provider_test.dart --platform=vm
```

### 性能测试超时
```bash
# 增加超时时间
flutter test test/performance/ --timeout=300s --release
```

---

## 📈 进度追踪

### Checklist
- [ ] 验证环境 (`flutter analyze`)
- [ ] 运行 TranslationService 测试
- [ ] 运行 NetworkProvider 测试  
- [ ] 运行 Repository 测试
- [ ] 运行集成测试
- [ ] 运行性能测试
- [ ] 手动功能验证 (100+项)
- [ ] 生成最终报告

### 预计时间
- 环境验证: 5分钟
- 单元测试: 5小时
- 集成测试: 2小时
- 性能测试: 1.5小时
- 功能验证: 2-3小时
- **总计**: ~12小时

---

## 🎯 成功标志

✅ **Phase 2.5 完成** 当:
- [ ] 所有单元测试通过 (69/69)
- [ ] 所有集成测试通过 (8/8)  
- [ ] 所有性能测试通过 (30+/30+)
- [ ] 功能验证 >90% (>90/100)
- [ ] 0编译错误
- [ ] 覆盖率 >85%
- [ ] 文档已更新

---

## 📞 需要帮助?

1. **查看详细计划**: `cat PHASE2_5_PLAN.md`
2. **查看执行指南**: `cat PHASE2_5_STARTUP_GUIDE.md`
3. **查看功能清单**: `cat PHASE2_5_VERIFICATION_CHECKLIST.md`
4. **查看当前状态**: `cat PHASE2_5_STATUS.md`

---

## 🚀 现在开始!

```bash
# 最快的开始方式
cd d:\princip计划\ai翻译\uyghur-translation-app1
dart test test/unit/ -v
```

预祝测试顺利! 🎉

---

**快速卡版本**: 1.0  
**生成时间**: 2025-12-05  
**有效期**: 直到Phase 2.5完成

