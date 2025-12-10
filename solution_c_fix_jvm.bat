@echo off
echo ========================================
echo 方案C: 修复JVM参数
echo ========================================
echo.

cd /d "D:\princip plan\ai translation\uyghur-translation-app1\android"

echo 备份当前gradle.properties...
copy gradle.properties gradle.properties.backup_%date:~0,4%%date:~5,2%%date:~8,2%.bak

echo.
echo 创建优化的gradle.properties...
(
echo # Gradle配置
echo org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
echo org.gradle.parallel=true
echo org.gradle.caching=true
echo org.gradle.configureondemand=true
echo.
echo # Android配置
echo android.useAndroidX=true
echo android.enableJetifier=true
echo.
echo # Kotlin配置
echo kotlin.code.style=official
echo.
echo # 网络配置 - 移除systemProp前缀
echo https.protocols=TLSv1.2,TLSv1.3
) > gradle.properties

echo.
echo gradle.properties已更新
echo.
type gradle.properties

echo.
echo 现在尝试构建...
cd ..
call flutter clean
call flutter build apk --release

pause
