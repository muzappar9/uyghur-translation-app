# 框架与依赖版本矩阵

## 构建工具链版本矩阵

```
┌─────────────────────────────────────────────────────────────┐
│              构建工具链版本关系                               │
├─────────────────────────────────────────────────────────────┤
│ Flutter 3.35.4                                              │
│  ├─ Dart SDK: 3.9.2                                         │
│  └─ Engine: c298091351                                      │
│                                                             │
│ Android Build Tools                                         │
│  ├─ AGP (Current): 8.3.2 ⚠️ [推荐升级至 8.6.0+]           │
│  ├─ Gradle (Current): 8.4 ⚠️ [推荐升级至 8.7+]            │
│  ├─ Kotlin: 2.1.0 ✅                                       │
│  ├─ compileSdk: 36 ✅                                      │
│  ├─ minSdk: 21 ✅                                          │
│  └─ NDK: 27.0.12077973 ✅                                  │
│                                                             │
│ Java Environment                                            │
│  ├─ Java Version: OpenJDK 21.0.8                            │
│  ├─ Target: Java 17 ✅                                     │
│  └─ Status: ⚠️ JAVA_HOME 未配置                            │
└─────────────────────────────────────────────────────────────┘
```

## 核心框架依赖关系图

```
┌──────────────────────────────────────────────────────────────┐
│  Dart/Flutter Core Framework                                 │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Flutter 3.35.4                                             │
│    │                                                        │
│    ├─→ State Management: flutter_riverpod 2.6.1            │
│    │   └─→ riverpod (transitive)                           │
│    │                                                        │
│    ├─→ Routing: go_router 13.2.5                           │
│    │   └─→ flutter_web_plugins                             │
│    │                                                        │
│    ├─→ Localization: intl 0.20.2                           │
│    │   └─→ flutter_localizations (sdk)                     │
│    │                                                        │
│    ├─→ UI Components: cupertino_icons 1.0.8                │
│    │                                                        │
│    └─→ Platform Channels: ffi 2.1.4                        │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 数据持久化层依赖关系

```
┌──────────────────────────────────────────────────────────────┐
│  Data Persistence Layer                                      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Primary (Current):                                         │
│  ├─ Isar 3.1.0+1 ✅ (已手动修复 namespace)                │
│  │  ├─ isar_flutter_libs 3.1.0+1                          │
│  │  └─ isar_generator 3.1.0+1 (dev)                       │
│  │                                                        │
│  Secondary (Fallback):                                     │
│  ├─ Hive 1.1.0 ✅ (可升级至最新)                          │
│  │  ├─ hive_flutter 1.1.0                                │
│  │  └─ hive_generator 2.0.0 (dev)                        │
│  │                                                        │
│  Shared Storage:                                           │
│  ├─ SharedPreferences 2.2.2                               │
│  │                                                        │
│  Secure Storage:                                           │
│  └─ flutter_secure_storage 9.2.2                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 网络与 API 层依赖关系

```
┌──────────────────────────────────────────────────────────────┐
│  Network & API Layer                                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  HTTP Clients (Parallel):                                   │
│  ├─ http 1.5.0 (Direct)                                   │
│  │                                                        │
│  ├─ dio 5.3.0 (Advanced)                                 │
│  │  ├─ http_parser                                       │
│  │  └─ path                                              │
│  │                                                        │
│  Translation Service:                                      │
│  ├─ translator 1.0.0                                      │
│  │  └─ 依赖 Google Translate API                        │
│  │                                                        │
│  Cloud Services:                                           │
│  ├─ firebase_core 2.32.0 (✅ 可升级至 4.2.1)             │
│  │  └─ _flutterfire_internals 1.3.35                     │
│  │                                                        │
│  ├─ firebase_auth 4.16.0 (✅ 可升级至 6.1.2)             │
│  │  ├─ firebase_core 2.32.0                              │
│  │  └─ firebase_auth_platform_interface 7.3.0            │
│  │                                                        │
│  Network Monitoring:                                        │
│  └─ connectivity_plus 5.0.2 (可升级至 7.0.0)             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 文件、权限与多媒体层

```
┌──────────────────────────────────────────────────────────────┐
│  Files, Permissions & Media Layer                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  File Management:                                           │
│  ├─ path_provider 2.1.4                                    │
│  ├─ file_picker 8.3.7 (可升级至 10.3.7)                   │
│  │  └─ file_picker_platform_interface 2.0.0               │
│  │                                                        │
│  Media Capture:                                            │
│  ├─ image_picker 1.1.2                                    │
│  │  ├─ image_picker_android 0.8.0+                       │
│  │  └─ image_picker_ios 0.8.0+                           │
│  │                                                        │
│  Permissions:                                              │
│  ├─ permission_handler 11.4.0 (可升级至 12.0.1)          │
│  │  ├─ permission_handler_android 13.0.0+                │
│  │  └─ permission_handler_ios 9.0.0+                     │
│  │                                                        │
│  Sharing:                                                  │
│  ├─ share_plus 7.2.2 (可升级至 12.0.1) ⚠️ [TLS 失败]    │
│  │  └─ share_plus_platform_interface 3.4.0               │
│  │                                                        │
│  OCR & Vision:                                             │
│  └─ google_mlkit_text_recognition 0.13.1 (可升级至 0.15.0)│
│     ├─ google_mlkit_commons 0.8.1                        │
│     └─ native libraries                                   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 代码生成与序列化层

```
┌──────────────────────────────────────────────────────────────┐
│  Code Generation & Serialization (dev only)                  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Freezed (Immutable Models):                                │
│  ├─ freezed_annotation 2.4.4 (可升级至 3.1.0)            │
│  ├─ freezed 2.5.2 (dev, 可升级至 3.2.3)                  │
│  │                                                        │
│  JSON Serialization:                                        │
│  ├─ json_annotation 4.8.1                                 │
│  ├─ json_serializable 6.8.0 (dev, 可升级至 6.11.3)      │
│  │                                                        │
│  Build System:                                             │
│  ├─ build_runner 2.4.13 (dev, 可升级至 2.10.4)          │
│  │  ├─ analyzer                                          │
│  │  ├─ glob                                              │
│  │  └─ path                                              │
│  │                                                        │
│  Database Generators:                                      │
│  ├─ isar_generator 3.1.0+1 (dev)                         │
│  ├─ hive_generator 2.0.0 (dev)                           │
│  │                                                        │
│  UI & Tools:                                               │
│  ├─ flutter_launcher_icons 0.13.1 (dev, 可升级至 0.14.4) │
│  │                                                        │
│  Testing:                                                  │
│  └─ mocktail 1.0.0 (dev)                                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 实用工具层

```
┌──────────────────────────────────────────────────────────────┐
│  Utility & Logging Layer                                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Logging & Debugging:                                       │
│  ├─ logger 2.0.0                                           │
│  │                                                        │
│  Environment Management:                                    │
│  ├─ flutter_dotenv 5.2.1 (可升级至 6.0.0)               │
│  │                                                        │
│  Unique Identifiers:                                       │
│  ├─ uuid 4.0.0                                            │
│  │                                                        │
│  Animations:                                               │
│  ├─ flutter_animate 4.5.0                                 │
│  │                                                        │
│  FFI (Native Interop):                                     │
│  └─ ffi 2.1.4                                             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 依赖版本兼容性矩阵

```
┌─────────────────────────────────────────────────────────────────┐
│  Compatibility Matrix (Current vs Recommended)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Firebase Ecosystem (PRIMARY CONCERN - TLS FAILURE):           │
│  ├─ firebase_core: 2.32.0 → 4.2.1                             │
│  │  └─ Status: ⚠️ 需要 AGP 8.6+                              │
│  ├─ firebase_auth: 4.16.0 → 6.1.2                             │
│  │  └─ Status: ⚠️ 需要 AGP 8.6+ 且 compileSdk 36+            │
│  │                                                            │
│  Google/Jetpack Ecosystem:                                     │
│  ├─ go_router: 13.2.5 → 17.0.0                                │
│  ├─ permission_handler: 11.4.0 → 12.0.1                       │
│  ├─ share_plus: 7.2.2 → 12.0.1 (⚠️ 下载失败)                 │
│  │                                                            │
│  Kotlin Ecosystem:                                             │
│  ├─ Kotlin: 1.9.24 → 2.1.0 ✅ (已升级)                       │
│  │                                                            │
│  Gradle Ecosystem:                                             │
│  ├─ AGP: 8.3.2 → 8.6.0+ (推荐升级)                            │
│  ├─ Gradle: 8.4 → 8.7+ (推荐升级)                             │
│  │                                                            │
│  State Management:                                             │
│  ├─ flutter_riverpod: 2.6.1 → 3.0.3 (可选)                    │
│  │                                                            │
└─────────────────────────────────────────────────────────────────┘
```

## 失败任务关系图

```
TLS 握手失败 (Root Cause)
│
├─→ Task: :share_plus:compileDebugKotlin ❌
│   └─→ 无法下载 kotlin-build-tools-impl-2.1.0.jar
│       └─→ 来源: repo.maven.apache.org
│
├─→ Task: :firebase_core:compileDebugJavaWithJavac ❌
│   ├─→ 无法下载 firebase-common-20.4.3.aar
│   ├─→ 无法下载 firebase-components-17.1.5.aar
│   └─→ 来源: dl.google.com & maven.aliyun.com
│
├─→ 关联失败的所有插件:
│   ├─ firebase_auth (需要 firebase_core)
│   ├─ google_mlkit_text_recognition
│   ├─ permission_handler
│   └─ 其他 Google Play Services 集成
│
└─→ Build 失败: BUILD FAILED in 5m 26s
```

## 版本升级路径建议

```
Phase 1 - 立即修复 (Next Build):
├─ Gradle TLS Configuration ✓
├─ Java Environment Setup ✓
└─ Clear Cache & Rebuild ✓

Phase 2 - 中期优化 (This Sprint):
├─ AGP: 8.3.2 → 8.6.0
├─ Gradle: 8.4 → 8.7 
├─ Firebase: 2.32.0 → 4.2.1
└─ Firebase Auth: 4.16.0 → 6.1.2

Phase 3 - 长期改进 (Next Quarter):
├─ go_router: 13.2.5 → 17.0.0
├─ flutter_riverpod: 2.6.1 → 3.0.3
├─ share_plus: 7.2.2 → 12.0.1
└─ 其他依赖升级

Phase 4 - 架构优化 (Optional):
├─ 评估从 Isar 迁移至 Hive/Drift
└─ 优化依赖注入和代码生成
```

