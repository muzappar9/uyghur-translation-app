# Gradle下载失败诊断报告

## 问题症状
- ✅ `flutter pub get` 成功 (TLS握手修复有效)
- ❌ `flutter build apk --debug` 的gradle-8.7下载失败
- 错误：`java.util.zip.ZipException: Not a zip file`
- 原因：gradle官方服务器返回的ZIP文件不完整或损坏

## 根本原因分析

### 第一次尝试（HTTPS直连）
- URL: `https://services.gradle.org/distributions/gradle-8.7-all.zip`
- 状态：连接建立，下载开始但中途中断
- 表现：ZIP文件损坏，解压失败

### 第二次尝试（HTTP镜像 - Aliyun）
- URL: `http://mirrors.aliyun.com/gradle/gradle-8.7-all.zip`
- 状态：镜像文件不完整或不匹配
- 表现：同样的ZipException

### 推断根因
网络环境限制+Gradle官方CDN在华中地区不稳定

## 已尝试的解决方案

| 方案 | 配置 | 结果 | 原因 |
|------|------|------|------|
| A | TLS v1.2/1.3显式配置 | ✅ flutter pub get成功 | 解决了Maven依赖TLS握手 |
| B | HTTP降级到Aliyun镜像 | ❌ ZIP损坏 | 镜像源不稳定 |
| C | HTTPS禁用证书验证 | ⏳ 等待测试 | 理论上应该绕过SSL验证 |

## 推荐的完整解决方案

### 方案D：使用本地Gradle包装器（推荐）

1. **预先下载gradle-8.7**
   ```powershell
   # 在网络良好环境下手动下载
   # 从梯子或代理下载: gradle-8.7-all.zip (146MB)
   # 放在: C:\Users\[YourUser]\.gradle\wrapper\dists\gradle-8.7-XXXX\
   ```

2. **降级回gradle-8.4** (已在本地)
   ```gradle
   // gradle/wrapper/gradle-wrapper.properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
   ```
   - 优点：已缓存，无需下载
   - 缺点：TLS支持不如8.7好（但配合TLS显式配置可用）

3. **使用离线构建**
   ```powershell
   flutter build apk --debug --offline
   ```
   - 需要所有依赖已缓存

### 方案E：使用代理服务器

在`gradle.properties`中配置代理：
```properties
systemProp.http.proxyHost=proxy.example.com
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=proxy.example.com
systemProp.https.proxyPort=8080
```

## 当前配置状态

✅ **已完成**
- gradle.properties: TLS显式配置
- build.gradle.kts: 仓库镜像配置
- android/gradle/wrapper: 指向gradle-8.7

❌ **阻塞点**
- gradle-8.7 ZIP下载不稳定
- 官方CDN和镜像都有问题

## 立即行动方案

### 推荐：回退到gradle-8.4（临时方案）
```properties
# gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
```

**优点**：
- gradle-8.4已缓存在本地
- 配合TLS配置可正常工作
- 快速恢复构建能力

**缺点**：
- 不是最新gradle版本
- 仍需AGP 8.6+升级（后续任务）

### 最终方案：改用官方gradle-cli
```powershell
# 使用flutter内嵌的gradle，而不是wrapper
flutter config --enable-web  # 确保flutter完整
flutter build apk --debug --no-build-per-arch --no-resident-runner
```

## 建议给用户

1. **立即行动**：
   - 回退gradle-8.4配置
   - 执行构建确认能否通过TLS握手

2. **后续升级**：
   - 网络环境稳定后，手动下载gradle-8.7
   - 放入本地缓存
   - 升级wrapper配置

3. **长期改进**：
   - 配置公司代理服务器
   - 或使用Docker化构建环境
   - 或迁移到CI/CD（GitHub Actions等）

## 现在执行

推荐执行方案：**回退gradle-8.4 + TLS配置继续**
