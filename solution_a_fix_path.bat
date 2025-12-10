@echo off
echo ========================================
echo 方案A: 移动项目到无空格路径
echo ========================================
echo.

set "OLD_PATH=D:\princip plan\ai translation\uyghur-translation-app1"
set "NEW_PATH=D:\flutter_projects\uyghur-translation-app1"

echo 当前路径: %OLD_PATH%
echo 新路径: %NEW_PATH%
echo.

echo 这将:
echo 1. 创建新目录
echo 2. 复制整个项目
echo 3. 清理缓存
echo 4. 重新构建
echo.

choice /C YN /M "确认执行吗"
if errorlevel 2 goto :end

echo.
echo [1/5] 创建新目录...
mkdir "%NEW_PATH%" 2>nul

echo [2/5] 复制项目文件...
xcopy "%OLD_PATH%" "%NEW_PATH%" /E /I /H /Y

echo [3/5] 进入新项目目录...
cd /d "%NEW_PATH%"

echo [4/5] 清理Flutter缓存...
call flutter clean

echo [5/5] 删除Gradle缓存...
rmdir /s /q android\.gradle 2>nul
rmdir /s /q android\build 2>nul

echo.
echo ========================================
echo 项目已移动到: %NEW_PATH%
echo 现在请在新路径运行: flutter build apk --release
echo ========================================

:end
pause
