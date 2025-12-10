@echo off
echo ========================================
echo 方案B: 使用系统Gradle构建
echo ========================================
echo.

cd /d "D:\princip plan\ai translation\uyghur-translation-app1\android"

echo [1/4] 检查系统Gradle...
if exist "C:\Users\22879\.gradle\wrapper\dists\gradle-8.6-all\5wjnly2bdum99x99ox99zij8g\gradle-8.6\bin\gradle.bat" (
    echo ✓ 找到系统Gradle
    set "GRADLE_CMD=C:\Users\22879\.gradle\wrapper\dists\gradle-8.6-all\5wjnly2bdum99x99ox99zij8g\gradle-8.6\bin\gradle.bat"
) else (
    echo ✗ 未找到解压的Gradle
    echo 请确保Gradle已完全解压
    pause
    exit /b 1
)

echo.
echo [2/4] 设置环境变量...
set "GRADLE_HOME=C:\Users\22879\.gradle\wrapper\dists\gradle-8.6-all\5wjnly2bdum99x99ox99zij8g\gradle-8.6"
set "PATH=%GRADLE_HOME%\bin;%PATH%"

echo.
echo [3/4] 测试Gradle...
call "%GRADLE_CMD%" --version
if errorlevel 1 (
    echo ✗ Gradle测试失败
    pause
    exit /b 1
)

echo.
echo [4/4] 使用系统Gradle构建APK...
echo 这可能需要几分钟...
call "%GRADLE_CMD%" assembleRelease --full-stacktrace --info

echo.
echo ========================================
if errorlevel 1 (
    echo ✗ 构建失败
) else (
    echo ✓ 构建成功!
    echo APK位置: app\build\outputs\apk\release\
)
echo ========================================
pause
