@echo off
echo ========================================
echo 方案D: 重新生成Gradle Wrapper
echo ========================================
echo.

cd /d "D:\princip plan\ai translation\uyghur-translation-app1\android"

echo [1/6] 删除旧的wrapper文件...
del /q gradlew.bat 2>nul
del /q gradlew 2>nul
rmdir /s /q gradle\wrapper 2>nul
echo ✓ 旧wrapper已删除

echo.
echo [2/6] 设置系统Gradle...
set "GRADLE_HOME=C:\Users\22879\.gradle\wrapper\dists\gradle-8.6-all\5wjnly2bdum99x99ox99zij8g\gradle-8.6"
set "PATH=%GRADLE_HOME%\bin;%PATH%"

echo.
echo [3/6] 测试系统Gradle...
call gradle.bat --version
if errorlevel 1 (
    echo ✗ 系统Gradle不可用
    pause
    exit /b 1
)

echo.
echo [4/6] 生成新的wrapper (Gradle 8.6)...
call gradle.bat wrapper --gradle-version 8.6 --distribution-type all

echo.
echo [5/6] 测试新的gradlew...
call gradlew.bat --version

echo.
echo [6/6] 尝试构建...
cd ..
call flutter clean
call flutter build apk --release

echo.
echo ========================================
echo 如果仍然失败，请查看上面的错误信息
echo ========================================
pause
