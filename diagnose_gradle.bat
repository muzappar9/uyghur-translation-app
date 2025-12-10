@echo off
echo ========================================
echo Gradle诊断脚本
echo ========================================
echo.

echo [1/5] 测试Java版本...
java -version
echo Java返回代码: %ERRORLEVEL%
echo.

echo [2/5] 测试已解压的Gradle...
if exist "C:\Users\22879\.gradle\wrapper\dists\gradle-8.6-all\5wjnly2bdum99x99ox99zij8g\gradle-8.6\bin\gradle.bat" (
    echo ✓ Gradle批处理文件存在
    echo 测试运行 gradle --version...
    call "C:\Users\22879\.gradle\wrapper\dists\gradle-8.6-all\5wjnly2bdum99x99ox99zij8g\gradle-8.6\bin\gradle.bat" --version
    echo Gradle返回代码: %ERRORLEVEL%
) else (
    echo ✗ Gradle批处理文件不存在
)
echo.

echo [3/5] 测试项目的gradlew.bat...
cd /d "D:\princip plan\ai translation\uyghur-translation-app1\android"
if exist gradlew.bat (
    echo ✓ gradlew.bat存在
    echo 内容预览:
    type gradlew.bat | findstr /n "^" | findstr "^[1-5]:"
    echo.
    echo 测试运行 gradlew.bat --version...
    call gradlew.bat --version 2>&1
    echo gradlew返回代码: %ERRORLEVEL%
) else (
    echo ✗ gradlew.bat不存在
)
echo.

echo [4/5] 检查Gradle配置...
if exist gradle.properties (
    echo gradle.properties内容:
    type gradle.properties
)
echo.

echo [5/5] 检查环境变量...
echo GRADLE_USER_HOME=%GRADLE_USER_HOME%
echo GRADLE_OPTS=%GRADLE_OPTS%
echo JAVA_HOME=%JAVA_HOME%
echo.

echo ========================================
echo 诊断完成
echo ========================================
pause
