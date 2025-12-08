# Flutter 翻译 App - 路由和存储实施指南

## 快速开始清单

### 第一步：依赖安装

```yaml
# pubspec.yaml - 完整依赖配置

dependencies:
  flutter:
    sdk: flutter
  
  # ========== 核心框架 ==========
  go_router: ^17.0.0                # 路由管理
  flutter_riverpod: ^3.0.3          # 状态管理
  
  # ========== 数据库 ==========
  isar: ^3.1.0                      # 主数据库（翻译历史）
  isar_flutter_libs: ^3.1.0         # Isar Flutter 库
  hive: ^2.2.3                      # 配置存储
  hive_flutter: ^1.1.0              # Hive Flutter 支持
  
  # ========== 工具库 ==========
  path_provider: ^2.0.0             # 文件路径
  sqflite: ^2.4.0                   # 备选数据库

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # ========== 代码生成 ==========
  isar_generator: ^3.1.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0        # 可选：Riverpod 代码生成
  
  # ========== 检查和格式化 ==========
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

运行命令：
```bash
flutter pub get
flutter pub run build_runner build   # 生成 Isar 代码
```

---

### 第二步：项目结构搭建

```bash
lib/
├── main.dart
├── app/
│   └── app.dart                     # App 主入口
├── config/
│   └── constants.dart
├── data/
│   ├── datasources/
│   │   ├── local_datasource.dart    # 本地数据源
│   │   └── remote_datasource.dart   # 远程数据源（可选）
│   ├── models/
│   │   ├── translation_models.dart  # 翻译相关模型
│   │   └── user_models.dart         # 用户相关模型
│   └── repositories/
│       ├── translation_repository.dart
│       ├── history_repository.dart
│       └── auth_repository.dart
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── translation_screen.dart
│   │   ├── history_screen.dart
│   │   ├── favorites_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       └── common/
├── providers/
│   ├── database_provider.dart       # 数据库提供者
│   ├── auth_provider.dart           # 认证提供者
│   ├── translation_provider.dart    # 翻译提供者
│   └── preferences_provider.dart    # 偏好设置提供者
├── router/
│   ├── app_router.dart              # GoRouter 配置
│   ├── auth_guard.dart              # 认证守卫
│   └── route_config.dart            # 路由配置常量
└── utils/
    └── logger.dart
```

---

### 第三步：核心文件实现

#### 1. 数据模型定义

**文件**: `lib/data/models/translation_models.dart`

```dart
import 'package:isar/isar.dart';
import 'package:hive/hive.dart';

part 'translation_models.g.dart';

// ============ Isar Models ============

// 1. 翻译历史记录
@collection
class TranslationHistory {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  late String sourceText;
  
  late String targetText;
  
  @Index(type: IndexType.value)
  late String sourceLang;
  
  @Index(type: IndexType.value)
  late String targetLang;
  
  @Index(type: IndexType.value)
  late DateTime timestamp;
  
  late bool isFavorite;
  
  late int usageCount;
}

// 2. 收藏词汇
@collection
class FavoritePhrase {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  late String sourceText;
  
  late String targetText;
  
  late String sourceLang;
  late String targetLang;
  
  late DateTime createdAt;
  
  late String category;
  late String note;
}

// 3. 搜索记录
@collection
class SearchRecord {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  late String query;
  
  @Index(type: IndexType.value)
  late DateTime lastSearched;
  
  late int searchCount;
}

// ============ Hive Models ============

// 4. 用户偏好设置
@HiveType(typeId: 0)
class UserPreferences extends HiveObject {
  @HiveField(0)
  String sourceLang = 'en';
  
  @HiveField(1)
  String targetLang = 'ug';
  
  @HiveField(2)
  bool darkMode = false;
  
  @HiveField(3)
  bool soundEnabled = true;
  
  @HiveField(4)
  String fontSize = 'medium';
  
  @HiveField(5)
  int maxHistoryItems = 1000;
}
```

生成 Isar 代码：
```bash
flutter pub run build_runner build
```

#### 2. 数据库提供者

**文件**: `lib/providers/database_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/translation_models.dart';

/// Isar 数据库提供者
final isarDatabaseProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  final isar = await Isar.open(
    [
      TranslationHistorySchema,
      FavoritePhraseSchema,
      SearchRecordSchema,
    ],
    directory: dir.path,
  );
  
  return isar;
});

/// Hive 用户偏好提供者
final userPreferencesProvider = 
    FutureProvider<Box<UserPreferences>>((ref) async {
  await Hive.initFlutter();
  
  try {
    await Hive.registerAdapter(UserPreferencesAdapter());
  } catch (e) {
    // 适配器已注册
  }
  
  final box = await Hive.openBox<UserPreferences>('user_prefs');
  
  // 初始化默认值
  if (box.isEmpty) {
    await box.put('current', UserPreferences());
  }
  
  return box;
});

/// 获取当前用户偏好
final currentUserPreferencesProvider = 
    FutureProvider<UserPreferences>((ref) async {
  final prefsBox = await ref.watch(userPreferencesProvider.future);
  return prefsBox.get('current') ?? UserPreferences();
});
```

#### 3. 翻译历史仓库

**文件**: `lib/data/repositories/translation_repository.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/translation_models.dart';
import '../../providers/database_provider.dart';

final translationHistoryProvider = 
    StateNotifierProvider<TranslationHistoryNotifier, 
    AsyncValue<List<TranslationHistory>>>((ref) {
  final isarFuture = ref.watch(isarDatabaseProvider);
  
  return isarFuture.when(
    data: (isar) => TranslationHistoryNotifier(isar),
    loading: () => TranslationHistoryNotifier(null),
    error: (error, stack) => TranslationHistoryNotifier(null),
  );
});

class TranslationHistoryNotifier 
    extends StateNotifier<AsyncValue<List<TranslationHistory>>> {
  final Isar? _isar;
  
  TranslationHistoryNotifier(this._isar) 
      : super(const AsyncValue.loading()) {
    if (_isar != null) {
      _loadHistory();
    }
  }
  
  Future<void> _loadHistory() async {
    try {
      final records = await _isar!.translationHistories
        .where()
        .sortByTimestampDesc()
        .limit(100)
        .findAll();
      
      state = AsyncValue.data(records);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 添加翻译记录
  Future<void> addTranslation({
    required String sourceText,
    required String targetText,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (_isar == null) return;
    
    try {
      // 检查是否已存在
      final existing = await _isar!.translationHistories
        .filter()
        .sourceTextEqualTo(sourceText)
        .targetLangEqualTo(targetLang)
        .findFirst();
      
      await _isar!.writeTxn(() async {
        if (existing != null) {
          existing.usageCount++;
          existing.timestamp = DateTime.now();
          await _isar!.translationHistories.put(existing);
        } else {
          await _isar!.translationHistories.put(
            TranslationHistory()
              ..sourceText = sourceText
              ..targetText = targetText
              ..sourceLang = sourceLang
              ..targetLang = targetLang
              ..timestamp = DateTime.now()
              ..isFavorite = false
              ..usageCount = 1
          );
        }
      });
      
      await _loadHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 切换收藏状态
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    if (_isar == null) return;
    
    try {
      await _isar!.writeTxn(() async {
        final record = await _isar!.translationHistories.get(id);
        if (record != null) {
          record.isFavorite = isFavorite;
          await _isar!.translationHistories.put(record);
        }
      });
      
      await _loadHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 搜索翻译
  Future<List<TranslationHistory>> searchTranslations(String query) async {
    if (_isar == null) return [];
    
    try {
      return await _isar!.translationHistories
        .filter()
        .sourceTextContains(query, caseSensitive: false)
        .sortByTimestampDesc()
        .findAll();
    } catch (e) {
      return [];
    }
  }
  
  /// 删除记录
  Future<void> deleteHistory(int id) async {
    if (_isar == null) return;
    
    try {
      await _isar!.writeTxn(() async {
        await _isar!.translationHistories.delete(id);
      });
      
      await _loadHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// 清空历史
  Future<void> clearHistory() async {
    if (_isar == null) return;
    
    try {
      await _isar!.writeTxn(() async {
        await _isar!.translationHistories.clear();
      });
      
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

#### 4. 认证状态提供者

**文件**: `lib/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 认证状态
final authStateProvider = FutureProvider<AuthState>((ref) async {
  // TODO: 实现实际的认证逻辑
  // 例如检查本地存储的 token，验证是否登录
  
  // 模拟认证状态
  await Future.delayed(Duration(milliseconds: 500));
  return AuthState(isAuthenticated: false, user: null);
});

// 用户信息提供者
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  return authState.user;
});

// 认证状态类
class AuthState {
  final bool isAuthenticated;
  final User? user;
  
  AuthState({
    required this.isAuthenticated,
    required this.user,
  });
}

// 用户模型
class User {
  final String id;
  final String email;
  final String displayName;
  
  User({
    required this.id,
    required this.email,
    required this.displayName,
  });
}
```

#### 5. 路由配置

**文件**: `lib/router/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/translation_screen.dart';
import '../presentation/screens/history_screen.dart';

// 路由提供者
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // 等待认证状态加载
      final authValue = await ref.read(authStateProvider.future);
      final isAuthenticated = authValue.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      
      // 如果未认证且不在登录页面，重定向到登录
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      
      // 如果已认证且在登录页面，重定向到首页
      if (isAuthenticated && isLoggingIn) {
        return '/';
      }
      
      return null; // 允许导航
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'translation',
            name: 'translation',
            builder: (context, state) => const TranslationScreen(),
          ),
          GoRoute(
            path: 'history',
            name: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

// 路由扩展
extension GoRouterX on GoRouter {
  void goTranslation(BuildContext context) => pushNamed('translation');
  void goHistory(BuildContext context) => pushNamed('history');
  void goHome(BuildContext context) => go('/');
}
```

#### 6. 主应用入口

**文件**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: '维吾尔语翻译助手',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
    );
  }
}
```

---

### 第四步：测试配置

#### 1. 单元测试示例

**文件**: `test/providers/translation_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/data/models/translation_models.dart';

void main() {
  group('TranslationHistoryNotifier', () {
    late Isar isar;
    
    setUpAll(() async {
      // 初始化 Isar 用于测试
      if (Isar.instanceNames.isEmpty) {
        isar = await Isar.open(
          [TranslationHistorySchema],
          inspector: true,
        );
      }
    });
    
    tearDownAll(() async {
      await isar.close(deleteFromDisk: true);
    });
    
    test('Should add translation to history', () async {
      // 测试代码
    });
    
    test('Should toggle favorite status', () async {
      // 测试代码
    });
  });
}
```

---

### 第五步：运行和调试

```bash
# 1. 生成代码
flutter pub run build_runner build

# 2. 运行应用
flutter run

# 3. 调试 Isar 数据库
# - 在 Isar.open() 中设置 inspector: true
# - 运行应用后，查看控制台输出的 Inspector URL

# 4. 调试 Hive 数据库
# - 使用 HiveBox 的 listenable() 监听变化
# - 在 Flutter DevTools 中查看数据

# 5. 清空数据（开发用）
flutter pub run build_runner clean
```

---

## 常见问题和解决方案

### Q1: 编译错误 "TranslationHistorySchema not found"

**解决方案**:
```bash
# 清空构建产物并重新生成
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Q2: Hive 初始化错误 "Cannot register adapter twice"

**解决方案**:
```dart
try {
  Hive.registerAdapter(UserPreferencesAdapter());
} catch (e) {
  // 适配器已注册，忽略错误
}
```

### Q3: 路由守卫不工作

**解决方案**:
```dart
// ✅ 确保使用 MaterialApp.router
MaterialApp.router(
  routerConfig: goRouter,
  // 不要同时使用 home 或 routes
)

// ❌ 错误的做法
MaterialApp(
  routerConfig: goRouter,  // 这样不会工作
  home: HomeScreen(),      // 冲突
)
```

---

## 性能优化检查清单

- [ ] 为 Isar 查询添加必要的索引
- [ ] 使用事务进行批量操作
- [ ] 在 Riverpod 中正确使用 `.future` 和 `.select()`
- [ ] 避免在 `redirect` 中进行重操作
- [ ] 定期清理过期的翻译历史记录
- [ ] 测试应用的冷启动时间
- [ ] 使用 Flutter DevTools 分析数据库操作

---

## 下一步

1. 完成 UI 屏幕实现
2. 集成翻译 API
3. 添加更多功能（收藏夹、统计等）
4. 进行性能测试和优化
5. 发布到应用商店

