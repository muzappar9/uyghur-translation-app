# Phase 3 实现计划 - 真实 API 集成

## 📋 Phase 3 目标

从 Mock 实现转移到真实 API 集成，实现以下关键功能：

1. **真实翻译 API** (Google Translate)
2. **真实 OCR API** (Google Vision 或 Paddle OCR)
3. **用户认证系统** (Firebase/本地)
4. **数据持久化** (Isar 数据库)
5. **离线支持**
6. **API 错误处理和重试**

---

## 🎯 实现步骤

### Step 1: 依赖和配置管理 (2-3 小时)

#### 1.1 添加必需包
```bash
flutter pub add google_translate_flutter
flutter pub add google_mlkit_text_recognition
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add isar
flutter pub add isar_flutter_libs
flutter pub add http
flutter pub add connectivity_plus
```

#### 1.2 环境配置
- 创建 `.env` 和 `.env.example` 文件
- 配置 API 密钥管理
- 设置开发/生产环境切换

**文件**:
```
lib/core/config/env_config.dart (新建)
lib/core/config/api_keys.dart (新建)
.env (新建)
.env.example (新建)
```

### Step 2: API 服务层实现 (4-5 小时)

#### 2.1 翻译服务
```dart
// lib/features/translation/data/services/google_translate_service.dart

class GoogleTranslateService {
  Future<String> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async;
  
  Future<List<String>> detectLanguage(String text) async;
  Future<Map<String, dynamic>> getAvailableLanguages() async;
}
```

#### 2.2 OCR 服务
```dart
// lib/features/ocr/data/services/google_vision_service.dart

class GoogleVisionService {
  Future<OcrResult> recognizeText(File imageFile) async;
  Future<OcrResult> recognizeTextFromUrl(String imageUrl) async;
  Future<List<String>> detectLanguagesInImage(File imageFile) async;
}
```

#### 2.3 API 客户端基类
```dart
// lib/shared/services/api/api_client.dart (改进)

class ApiClient {
  // 添加重试逻辑
  // 添加速率限制
  // 添加缓存机制
  // 添加请求拦截器
}
```

### Step 3: 数据库集成 (3-4 小时)

#### 3.1 Isar 模型定义
```dart
// lib/shared/data/models/isar_models/

@collection
class TranslationHistoryModel {
  late Id id;
  late String sourceText;
  late String translatedText;
  late String sourceLanguage;
  late String targetLanguage;
  late DateTime timestamp;
  late bool isSynced;
}

@collection
class UserPreferencesModel {
  late Id id;
  late String userId;
  late String sourceLanguage;
  late String targetLanguage;
  late bool darkMode;
  late DateTime lastUpdated;
}

@collection
class OcrResultModel {
  late Id id;
  late String imageUrl;
  late String recognizedText;
  late String detectedLanguage;
  late List<String> editHistory;
  late DateTime createdAt;
}
```

#### 3.2 数据库服务
```dart
// lib/shared/services/database/isar_database_service.dart

class IsarDatabaseService {
  Future<void> saveTranslationHistory(TranslationHistoryModel data) async;
  Future<List<TranslationHistoryModel>> getTranslationHistory() async;
  Future<void> deleteTranslationHistory(int id) async;
  
  Future<void> saveUserPreferences(UserPreferencesModel data) async;
  Future<UserPreferencesModel?> getUserPreferences(String userId) async;
  
  Future<void> saveOcrResult(OcrResultModel data) async;
  Future<List<OcrResultModel>> getOcrResults() async;
}
```

### Step 4: 认证系统 (2-3 小时)

#### 4.1 认证服务
```dart
// lib/features/auth/data/services/auth_service.dart

class AuthService {
  Future<AuthUser> signUpWithEmail(String email, String password) async;
  Future<AuthUser> signInWithEmail(String email, String password) async;
  Future<void> signOut() async;
  Future<bool> isAuthenticated() async;
  Stream<AuthUser?> authStateChanges();
}
```

#### 4.2 认证 Provider
```dart
// lib/features/auth/presentation/providers/auth_provider.dart

final authServiceProvider = Provider((ref) => AuthService());
final authStateProvider = StreamProvider((ref) => ref.watch(authServiceProvider).authStateChanges());
final currentUserProvider = StateProvider<AuthUser?>((ref) => null);
```

### Step 5: Repository 实现更新 (4-5 小时)

#### 5.1 翻译 Repository
```dart
// lib/features/translation/data/repositories/translation_repository_impl.dart

class TranslationRepositoryImpl implements TranslationRepository {
  final GoogleTranslateService _googleTranslateService;
  final IsarDatabaseService _databaseService;
  final NetworkConnectivityNotifier _networkNotifier;

  @override
  Future<TranslationResult> translate(TranslationRequest request) async {
    try {
      // 检查网络
      if (await _networkNotifier.isOnline) {
        // 调用真实 API
        final result = await _googleTranslateService.translate(
          request.text,
          request.sourceLanguage,
          request.targetLanguage,
        );
        
        // 保存到本地数据库
        await _databaseService.saveTranslationHistory(
          TranslationHistoryModel(
            sourceText: request.text,
            translatedText: result,
            sourceLanguage: request.sourceLanguage,
            targetLanguage: request.targetLanguage,
            timestamp: DateTime.now(),
            isSynced: true,
          ),
        );
        
        return TranslationResult.success(result);
      } else {
        // 离线模式：返回缓存或错误
        return TranslationResult.offline();
      }
    } catch (e) {
      return TranslationResult.error(e.toString());
    }
  }
}
```

#### 5.2 OCR Repository
```dart
// lib/features/ocr/data/repositories/ocr_repository_impl.dart

class OcrRepositoryImpl implements OcrRepository {
  final GoogleVisionService _googleVisionService;
  final IsarDatabaseService _databaseService;

  @override
  Future<OcrResult> recognizeText(File imageFile) async {
    try {
      final ocrResult = await _googleVisionService.recognizeText(imageFile);
      
      // 保存结果
      await _databaseService.saveOcrResult(
        OcrResultModel(
          imageUrl: imageFile.path,
          recognizedText: ocrResult.text,
          detectedLanguage: ocrResult.detectedLanguage,
          editHistory: [ocrResult.text],
          createdAt: DateTime.now(),
        ),
      );
      
      return ocrResult;
    } catch (e) {
      return OcrResult.error(e.toString());
    }
  }
}
```

### Step 6: UI 层更新 (3-4 小时)

#### 6.1 加载状态处理
- 添加 Loading Widget
- 添加 Error Widget
- 添加 Empty State Widget
- 添加重试机制

#### 6.2 屏幕更新
- TranslateResultScreen: 集成真实翻译
- OcrResultScreen: 集成真实 OCR
- HistoryScreen: 显示真实数据库数据
- SettingsScreen: 用户认证相关功能

### Step 7: 错误处理和重试机制 (2-3 小时)

#### 7.1 自定义异常
```dart
// lib/core/exceptions/app_exceptions.dart

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}
```

#### 7.2 重试策略
```dart
// lib/shared/utils/retry_helper.dart

class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool exponentialBackoff = true,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;
        
        final waitTime = exponentialBackoff
            ? delay * (1 << (attempts - 1))
            : delay;
        await Future.delayed(waitTime);
      }
    }
  }
}
```

### Step 8: 单元测试和集成测试 (3-4 小时)

#### 8.1 Service 层测试
```
test/features/translation/data/services/
├── google_translate_service_test.dart
└── google_vision_service_test.dart

test/shared/services/
├── isar_database_service_test.dart
└── api_client_test.dart
```

#### 8.2 Repository 层测试
```
test/features/translation/data/repositories/
└── translation_repository_impl_test.dart

test/features/ocr/data/repositories/
└── ocr_repository_impl_test.dart
```

#### 8.3 集成测试
```
test/integration/
├── api_integration_test.dart
├── database_integration_test.dart
└── auth_integration_test.dart
```

### Step 9: 性能优化 (2-3 小时)

#### 9.1 缓存策略
- 实现请求缓存（http 响应缓存）
- 数据库查询优化
- 图片缓存

#### 9.2 性能监控
- API 响应时间监控
- 数据库查询性能分析
- 内存使用监控

### Step 10: 最终验证和部署准备 (2-3 小时)

#### 10.1 代码质量检查
```bash
flutter analyze
flutter test --coverage
```

#### 10.2 功能测试清单
- [ ] 翻译功能（离线/在线）
- [ ] OCR 功能（图片识别）
- [ ] 用户认证（注册/登录/登出）
- [ ] 数据持久化（保存/检索）
- [ ] 历史记录（查看/删除）
- [ ] 错误处理（网络错误/超时/重试）

#### 10.3 文档更新
- API 集成指南
- 环境配置说明
- 部署步骤

---

## 📦 依赖版本说明

```yaml
# 翻译和 OCR
google_translate_flutter: ^3.0.0
google_mlkit_text_recognition: ^0.10.0

# 认证
firebase_core: ^2.24.0
firebase_auth: ^4.14.0
cloud_firestore: ^4.13.0

# 数据库
isar: ^3.1.0+1
isar_flutter_libs: ^3.1.0+1

# 网络和连接
http: ^1.1.0
connectivity_plus: ^5.0.0

# 环境管理
flutter_dotenv: ^5.1.0
```

---

## ⏱️ 时间估算

| Step | 任务 | 小时数 |
|------|------|--------|
| 1 | 依赖和配置 | 2-3 |
| 2 | API 服务层 | 4-5 |
| 3 | 数据库集成 | 3-4 |
| 4 | 认证系统 | 2-3 |
| 5 | Repository 更新 | 4-5 |
| 6 | UI 层更新 | 3-4 |
| 7 | 错误处理 | 2-3 |
| 8 | 测试 | 3-4 |
| 9 | 性能优化 | 2-3 |
| 10 | 验证和部署 | 2-3 |
| **总计** | | **28-37 小时** |

---

## 🔐 安全考虑

### API 密钥管理
- 使用 `.env` 文件存储敏感信息
- 不提交 `.env` 到 Git
- 使用环境变量注入

### 数据安全
- 敏感数据加密存储
- HTTPS 对所有 API 请求
- 用户数据隐私保护

### 认证
- 安全的密码存储
- Token 刷新机制
- 会话管理

---

## 📊 进度追踪

| 步骤 | 状态 | 完成日期 |
|------|------|----------|
| 1. 依赖和配置 | ⏳ 待开始 | - |
| 2. API 服务层 | ⏳ 待开始 | - |
| 3. 数据库集成 | ⏳ 待开始 | - |
| 4. 认证系统 | ⏳ 待开始 | - |
| 5. Repository 更新 | ⏳ 待开始 | - |
| 6. UI 层更新 | ⏳ 待开始 | - |
| 7. 错误处理 | ⏳ 待开始 | - |
| 8. 测试 | ⏳ 待开始 | - |
| 9. 性能优化 | ⏳ 待开始 | - |
| 10. 最终验证 | ⏳ 待开始 | - |

---

## 📝 完成标准

✅ Phase 3 完成条件：
- [ ] 所有 10 个步骤完成
- [ ] 0 编译错误，0 警告
- [ ] 新增 50+ 集成测试全部通过
- [ ] API 集成文档完善
- [ ] 性能基准满足要求
- [ ] 代码审查通过
- [ ] 生产环境部署就绪

---

**Phase 3 开始时间**：2025年12月5日  
**预计完成时间**：2025年12月17日～24日  
**状态**：✅ 规划完成，准备开始实现
