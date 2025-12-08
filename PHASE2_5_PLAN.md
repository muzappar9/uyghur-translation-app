# Phase 2.5 执行计划：测试覆盖 & 性能优化

**状态**: 📋 **规划中**  
**日期**: 2025年12月5日  
**目标**: 为Phase 2.4的离线架构添加生产级测试和性能验证

---

## 🎯 Phase 2.5 目标

### 主要目标
1. **✅ 离线架构测试覆盖** - 确保网络状态转换可靠
2. **✅ 队列管理验证** - 验证数据持久化和同步
3. **✅ 性能基准测试** - 大型队列处理性能
4. **✅ UI功能验证** - 网络指示器和同步按钮

### 成功标准
- ✅ TranslationService: 90%+ 测试覆盖
- ✅ NetworkProvider: 100% 覆盖（关键路径）
- ✅ PendingTranslationRepository: 95%+ 覆盖
- ✅ 集成测试: 离线→在线→同步 完整流程
- ✅ 性能: 1000项队列处理 <5秒

---

## 📊 工作量估计

| 任务 | 预计时间 | 优先级 |
|------|---------|--------|
| 单元测试设置 | 1h | P0 |
| TranslationService测试 | 2h | P0 |
| NetworkProvider测试 | 1.5h | P0 |
| Repository测试 | 1.5h | P0 |
| 集成测试 | 2h | P1 |
| 性能测试 | 1.5h | P1 |
| UI功能验证 | 1.5h | P2 |
| 文档生成 | 1h | P2 |
| **总计** | **12h** | - |

---

## 🔧 Task 1: 单元测试基础设置 (1h)

### 1.1 创建测试目录结构

```
test/
├── unit/
│   ├── services/
│   │   ├── translation_service_test.dart
│   │   └── network_provider_test.dart
│   ├── repositories/
│   │   ├── pending_translation_repository_test.dart
│   │   └── translation_repository_test.dart
│   └── providers/
│       └── pending_translation_provider_test.dart
├── integration/
│   └── offline_sync_flow_test.dart
└── performance/
    └── queue_performance_test.dart
```

### 1.2 配置mocktail和测试依赖

**pubspec.yaml添加**:
```yaml
dev_dependencies:
  mocktail: ^1.0.0        # 用于mock
  flutter_test:           # 已有
  integration_test:       # 集成测试
```

### 1.3 测试辅助类

**创建**: `test/mocks/mock_classes.dart`

```dart
// Mock Isar实例
class MockIsar extends Mock implements Isar {}

// Mock Connectivity
class MockConnectivity extends Mock implements Connectivity {}

// Mock ApiClient
class MockApiClient extends Mock implements ApiClient {}

// Mock TranslationRepository
class MockTranslationRepository extends Mock implements TranslationRepository {}

// Mock PendingTranslationRepository
class MockPendingTranslationRepository extends Mock 
    implements PendingTranslationRepository {}
```

---

## 🧪 Task 2: TranslationService 单元测试 (2h)

### 文件: `test/unit/services/translation_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uyghur_translator/shared/services/translation_service.dart';
import 'package:uyghur_translator/features/translation/data/repositories/translation_repository.dart';
import 'package:uyghur_translator/features/translation/data/repositories/pending_translation_repository.dart';

void main() {
  group('TranslationService', () {
    late TranslationService translationService;
    late MockTranslationRepository mockRepository;
    late MockPendingTranslationRepository mockPendingRepo;

    setUp(() {
      mockRepository = MockTranslationRepository();
      mockPendingRepo = MockPendingTranslationRepository();
      
      translationService = TranslationService(
        repository: mockRepository,
        pendingRepository: mockPendingRepo,
        logger: Logger(),
      );
    });

    group('translate()', () {
      test('在线时应返回API翻译结果', () async {
        // Arrange
        when(() => mockRepository.translate('你好', 'zh', 'ug'))
            .thenAnswer((_) async => 'سلام');
        
        // Act
        final result = await translationService.translate('你好', 'zh', 'ug');
        
        // Assert
        expect(result, 'سلام');
        verify(() => mockRepository.translate('你好', 'zh', 'ug')).called(1);
      });

      test('离线时应保存到待翻译队列', () async {
        // Arrange
        when(() => mockRepository.translate('你好', 'zh', 'ug'))
            .thenThrow(OfflineTranslationException('No internet'));
        when(() => mockPendingRepo.addPending('你好', 'zh', 'ug'))
            .thenAnswer((_) async {});
        
        // Act & Assert
        expect(
          () => translationService.translate('你好', 'zh', 'ug'),
          throwsA(isA<OfflineTranslationException>()),
        );
        
        verify(() => mockPendingRepo.addPending('你好', 'zh', 'ug')).called(1);
      });

      test('API错误应重新抛出而非保存到队列', () async {
        // Arrange
        when(() => mockRepository.translate('你好', 'zh', 'ug'))
            .thenThrow(Exception('API Error'));
        
        // Act & Assert
        expect(
          () => translationService.translate('你好', 'zh', 'ug'),
          throwsA(isA<Exception>()),
        );
        
        // 不应调用addPending
        verifyNever(() => mockPendingRepo.addPending(any(), any(), any()));
      });
    });

    group('processPendingTranslations()', () {
      test('应处理所有可重试的翻译', () async {
        // Arrange
        final pending1 = PendingTranslationModel()
          ..id = 1
          ..sourceText = '你好'
          ..sourceLang = 'zh'
          ..targetLang = 'ug'
          ..retryCount = 0;
        
        when(() => mockPendingRepo.getRetryableList())
            .thenAnswer((_) async => [pending1]);
        when(() => mockRepository.translate(any(), any(), any()))
            .thenAnswer((_) async => 'سلام');
        when(() => mockPendingRepo.markSynced(1))
            .thenAnswer((_) async {});
        
        // Act
        await translationService.processPendingTranslations();
        
        // Assert
        verify(() => mockRepository.translate('你好', 'zh', 'ug')).called(1);
        verify(() => mockPendingRepo.markSynced(1)).called(1);
      });

      test('失败项应增加重试计数', () async {
        // Arrange
        final pending1 = PendingTranslationModel()
          ..id = 1
          ..sourceText = '你好'
          ..sourceLang = 'zh'
          ..targetLang = 'ug'
          ..retryCount = 0;
        
        when(() => mockPendingRepo.getRetryableList())
            .thenAnswer((_) async => [pending1]);
        when(() => mockRepository.translate(any(), any(), any()))
            .thenThrow(Exception('Network error'));
        when(() => mockPendingRepo.updateRetryCount(1, 1, any()))
            .thenAnswer((_) async {});
        
        // Act
        await translationService.processPendingTranslations();
        
        // Assert
        verify(() => mockPendingRepo.updateRetryCount(1, 1, any())).called(1);
      });

      test('重试达到5次后应停止', () async {
        // Arrange
        final pending1 = PendingTranslationModel()
          ..id = 1
          ..sourceText = '你好'
          ..sourceLang = 'zh'
          ..targetLang = 'ug'
          ..retryCount = 5; // 已经5次
        
        when(() => mockPendingRepo.getRetryableList())
            .thenAnswer((_) async => [pending1]);
        
        // Act
        await translationService.processPendingTranslations();
        
        // Assert
        // 不应尝试翻译
        verifyNever(() => mockRepository.translate(any(), any(), any()));
      });

      test('应等待指定延迟后重试', () async {
        // Arrange
        final pending1 = PendingTranslationModel()
          ..id = 1
          ..sourceText = '你好'
          ..sourceLang = 'zh'
          ..targetLang = 'ug'
          ..retryCount = 0;
        
        when(() => mockPendingRepo.getRetryableList())
            .thenAnswer((_) async => [pending1]);
        when(() => mockRepository.translate(any(), any(), any()))
            .thenThrow(Exception('Retry'))
            .thenAnswer((_) async => 'سلام');
        when(() => mockPendingRepo.updateRetryCount(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockPendingRepo.markSynced(1))
            .thenAnswer((_) async {});
        
        final stopwatch = Stopwatch()..start();
        
        // Act
        await translationService.processPendingTranslations();
        
        stopwatch.stop();
        
        // Assert - 应至少等待延迟时间
        // 第一次失败后延迟1秒
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
      });
    });
  });
}
```

---

## 🔌 Task 3: NetworkProvider 单元测试 (1.5h)

### 文件: `test/unit/services/network_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uyghur_translator/shared/providers/network_provider.dart';

void main() {
  group('NetworkConnectivityNotifier', () {
    late NetworkConnectivityNotifier notifier;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
      // 在实际测试中需要注入mock
      notifier = NetworkConnectivityNotifier();
    });

    test('初始化应检查网络状态', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      
      // Act
      final result = await notifier.build();
      
      // Assert
      expect(result, NetworkStatus.online);
    });

    test('检测到在线应返回online状态', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);
      
      // Act
      final result = await notifier.build();
      
      // Assert
      expect(result, NetworkStatus.online);
    });

    test('检测到无网络应返回offline状态', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);
      
      // Act
      final result = await notifier.build();
      
      // Assert
      expect(result, NetworkStatus.offline);
    });

    test('网络状态变化应通知监听器', () async {
      // 这个测试需要stream操作的特殊处理
      // 实现方式取决于具体的Connectivity实现
      expect(true, true);
    });
  });
}
```

---

## 🗄️ Task 4: Repository 单元测试 (1.5h)

### 文件: `test/unit/repositories/pending_translation_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uyghur_translator/features/translation/data/models/pending_translation_model.dart';
import 'package:uyghur_translator/features/translation/data/repositories/pending_translation_repository.dart';

void main() {
  group('PendingTranslationRepository', () {
    late PendingTranslationRepository repository;
    late MockIsar mockIsar;

    setUp(() {
      mockIsar = MockIsar();
      repository = PendingTranslationRepositoryImpl(isar: mockIsar);
    });

    test('addPending应保存新记录', () async {
      // Arrange
      when(() => mockIsar.writeTxn(any()))
          .thenAnswer((_) async => 1);
      
      // Act
      await repository.addPending('你好', 'zh', 'ug');
      
      // Assert
      verify(() => mockIsar.writeTxn(any())).called(1);
    });

    test('getPendingList应返回所有未同步项', () async {
      // Arrange
      final pending1 = PendingTranslationModel()
        ..id = 1
        ..sourceText = '你好'
        ..isSynced = false;
      
      final mockQuery = MockQueryBuilder();
      when(() => mockIsar.pendingTranslationModels.filter())
          .thenReturn(mockQuery);
      when(() => mockQuery.isSyncedEqualTo(false))
          .thenReturn(mockQuery);
      when(() => mockQuery.findAll())
          .thenAnswer((_) async => [pending1]);
      
      // Act
      final result = await repository.getPendingList();
      
      // Assert
      expect(result, hasLength(1));
      expect(result.first.sourceText, '你好');
    });

    test('markSynced应更新isSynced标记', () async {
      // Arrange
      final model = PendingTranslationModel()
        ..id = 1
        ..isSynced = false;
      
      when(() => mockIsar.pendingTranslationModels.get(1))
          .thenAnswer((_) async => model);
      when(() => mockIsar.writeTxn(any()))
          .thenAnswer((_) async => 1);
      
      // Act
      await repository.markSynced(1);
      
      // Assert
      expect(model.isSynced, true);
      verify(() => mockIsar.writeTxn(any())).called(1);
    });

    test('removePending应删除记录', () async {
      // Arrange
      when(() => mockIsar.writeTxn(any()))
          .thenAnswer((_) async => 1);
      
      // Act
      await repository.removePending(1);
      
      // Assert
      verify(() => mockIsar.writeTxn(any())).called(1);
    });

    test('updateRetryCount应更新重试计数', () async {
      // Arrange
      final model = PendingTranslationModel()
        ..id = 1
        ..retryCount = 0;
      
      when(() => mockIsar.pendingTranslationModels.get(1))
          .thenAnswer((_) async => model);
      when(() => mockIsar.writeTxn(any()))
          .thenAnswer((_) async => 1);
      
      // Act
      await repository.updateRetryCount(1, 1, 'Network error');
      
      // Assert
      expect(model.retryCount, 1);
      expect(model.errorMessage, 'Network error');
      verify(() => mockIsar.writeTxn(any())).called(1);
    });

    test('getRetryableList应返回可重试项', () async {
      // Arrange
      final pending1 = PendingTranslationModel()
        ..id = 1
        ..retryCount = 2
        ..isSynced = false;
      
      final pending2 = PendingTranslationModel()
        ..id = 2
        ..retryCount = 5  // 不可重试
        ..isSynced = false;
      
      final mockQuery = MockQueryBuilder();
      when(() => mockIsar.pendingTranslationModels.filter())
          .thenReturn(mockQuery);
      when(() => mockQuery.isSyncedEqualTo(false))
          .thenReturn(mockQuery);
      when(() => mockQuery.findAll())
          .thenAnswer((_) async => [pending1, pending2]);
      
      // Act
      final result = await repository.getRetryableList();
      
      // Assert
      expect(result, hasLength(1));
      expect(result.first.id, 1);
    });

    test('clearAll应删除所有记录', () async {
      // Arrange
      final models = [
        PendingTranslationModel()..id = 1,
        PendingTranslationModel()..id = 2,
      ];
      
      final mockQuery = MockQueryBuilder();
      when(() => mockIsar.pendingTranslationModels.where())
          .thenReturn(mockQuery);
      when(() => mockQuery.findAll())
          .thenAnswer((_) async => models);
      when(() => mockIsar.writeTxn(any()))
          .thenAnswer((_) async => 1);
      
      // Act
      await repository.clearAll();
      
      // Assert
      verify(() => mockIsar.writeTxn(any())).called(1);
    });
  });
}
```

---

## 🔗 Task 5: 集成测试 - 离线到在线流程 (2h)

### 文件: `test/integration/offline_sync_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/app.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('离线同步完整流程', () {
    testWidgets('用户离线翻译 -> 在线恢复 -> 自动同步', 
        (WidgetTester tester) async {
      // 1. 启动应用
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // 2. 验证初始在线状态
      expect(find.byIcon(Icons.circle), findsWidgets);
      
      // 3. 模拟离线
      // (需要使用platform channel或mock)
      
      // 4. 输入翻译
      await tester.enterText(find.byType(TextField), '你好');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      
      // 5. 验证离线状态指示
      expect(find.byIcon(Icons.cloud_off), findsWidgets);
      
      // 6. 验证待同步徽章出现
      expect(find.byType(Badge), findsWidgets);
      
      // 7. 模拟在线恢复
      // (需要使用platform channel或mock)
      
      // 8. 等待自动同步
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 9. 验证同步完成
      expect(find.byIcon(Icons.cloud_done), findsWidgets);
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('手动同步按钮功能', 
        (WidgetTester tester) async {
      // 1. 启动应用
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // 2. 导航到HistoryScreen
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      
      // 3. 验证同步按钮存在
      expect(find.byIcon(Icons.sync), findsWidgets);
      
      // 4. 点击同步按钮
      await tester.tap(find.byIcon(Icons.sync));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 5. 验证SnackBar出现
      expect(find.byType(SnackBar), findsWidgets);
    });

    testWidgets('重试机制验证', 
        (WidgetTester tester) async {
      // 这个测试验证指数退避重试是否工作
      // 需要控制API响应来测试
      expect(true, true);
    });
  });
}
```

---

## ⚡ Task 6: 性能测试 (1.5h)

### 文件: `test/performance/queue_performance_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/features/translation/data/repositories/pending_translation_repository.dart';
import 'package:uyghur_translator/shared/services/translation_service.dart';

void main() {
  group('性能测试', () {
    late PendingTranslationRepository repository;
    late TranslationService service;

    setUp(() {
      // 初始化with real Isar instance (需要测试数据库)
    });

    test('1000项队列查询性能', () async {
      // Arrange - 插入1000项
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        await repository.addPending(
          '测试文本$i',
          'zh',
          'ug',
        );
      }
      
      stopwatch.stop();
      print('插入1000项耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // Act - 查询所有
      stopwatch.reset();
      stopwatch.start();
      final result = await repository.getPendingList();
      stopwatch.stop();
      
      print('查询1000项耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // Assert
      expect(result, hasLength(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 应<100ms
    });

    test('批量同步性能 - 100项', () async {
      // Arrange - 插入100项待同步
      for (int i = 0; i < 100; i++) {
        await repository.addPending('文本$i', 'zh', 'ug');
      }
      
      final stopwatch = Stopwatch()..start();
      
      // Act
      await service.processPendingTranslations();
      
      stopwatch.stop();
      print('同步100项耗时: ${stopwatch.elapsedMilliseconds}ms');
      
      // Assert - 应在5秒内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('内存使用 - 查询大型列表', () async {
      // 这需要dart:developer的接口来测量内存
      // 基本思路是在加载大型列表前后检查内存
      expect(true, true);
    });
  });
}
```

---

## 📋 Task 7: UI功能验证 (1.5h)

### 检查清单

```
网络状态指示器:
  [ ] 初始状态显示正确 (绿色/灰色)
  [ ] 离线→在线转换时更新
  [ ] Tooltip显示正确文本
  [ ] 在所有屏幕上可见

待同步徽章:
  [ ] 有待同步项时显示
  [ ] 计数正确
  [ ] 颜色为橙色
  [ ] 同步完成后消失

同步按钮:
  [ ] 存在于HistoryScreen
  [ ] 点击时禁用(loading状态)
  [ ] 同步完成后显示SnackBar
  [ ] SnackBar文本正确

自动同步:
  [ ] 网络恢复时自动触发
  [ ] 用户看不到加载状态 (后台)
  [ ] 同步完成后UI自动更新
  [ ] 不会触发多次同步
```

---

## 📝 Task 8: 文档和报告生成 (1h)

### 生成以下文档

1. **PHASE2_5_TEST_REPORT.md**
   - 测试覆盖率总结
   - 测试通过情况
   - 性能基准结果

2. **PHASE2_5_SUMMARY.md**
   - 所有测试的快速参考
   - 功能验证检查清单
   - 已知问题

3. **测试执行指南**
   - 如何运行单元测试
   - 如何运行集成测试
   - 如何运行性能测试

---

## 🚀 执行顺序

1. **第1小时**: Task 1 - 测试基础设置
   - 创建目录结构
   - 配置mocktail
   - 创建mock类

2. **第2-3小时**: Task 2 - TranslationService测试
   - 在线/离线场景
   - 重试逻辑
   - 异常处理

3. **第3.5-4.5小时**: Task 3-4 - NetworkProvider和Repository测试
   - 网络状态检测
   - 队列CRUD操作
   - 过滤和查询

4. **第4.5-6.5小时**: Task 5 - 集成测试
   - 离线→在线流程
   - 手动同步
   - UI更新

5. **第7-8小时**: Task 6 - 性能测试
   - 大型队列测试
   - 批量同步测试
   - 内存使用测试

6. **第8.5-10小时**: Task 7 - UI功能验证
   - 手动验证
   - 跨屏幕检查
   - 边界情况测试

7. **第10-11小时**: Task 8 - 文档生成
   - 汇总测试结果
   - 生成报告
   - 更新进度

---

## ✅ 完成标准

| 项目 | 标准 | 状态 |
|------|------|------|
| 单元测试覆盖 | 90%+ | ⏳ |
| 集成测试 | 完整流程 | ⏳ |
| 性能基准 | <5s/100项 | ⏳ |
| 编译状态 | 0 errors | ✅ |
| 文档完整 | 3份报告 | ⏳ |

---

## 🎯 预期成果

### 代码质量
- ✅ TranslationService: 95%+ 覆盖
- ✅ NetworkProvider: 100% 覆盖
- ✅ Repository: 95%+ 覆盖
- ✅ 集成测试: 离线同步完整验证

### 性能指标
- ✅ 单次查询: <10ms
- ✅ 批量查询(1000项): <100ms
- ✅ 同步100项: <5s
- ✅ 内存使用: <50MB增长

### 文档
- ✅ 详细的测试报告
- ✅ 性能基准数据
- ✅ 功能验证检查清单
- ✅ 执行指南

---

## 🔄 备选方案

如果时间不足:

**优先完成** (必须):
1. TranslationService单元测试
2. NetworkProvider单元测试
3. Repository单元测试
4. 集成测试 (离线→在线)

**可延后** (可选):
- 性能测试 (可用性能分析工具验证)
- UI功能验证 (手动点击测试)
- 完整的文档

---

## 📌 注意事项

1. **Isar测试**: 需要使用`isar.openSync()`或内存数据库
2. **Mock网络**: 使用mocktail或http_mock_adapter
3. **Async测试**: 使用`pumpAndSettle()`确保完成
4. **性能测试**: 在release mode下运行以获得准确结果
5. **CI/CD**: 考虑集成到GitHub Actions

---

**预计完成时间**: 12小时  
**开始时间**: 待指令  
**优先级**: P0 (必须完成)

