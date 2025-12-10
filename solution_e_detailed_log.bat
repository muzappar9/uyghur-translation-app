@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo 方案E: 详细日志诊断
echo ========================================
echo.

set "LOG_FILE=gradle_debug_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

cd /d "D:\princip plan\ai translation\uyghur-translation-app1\android"

echo 日志文件: %LOG_FILE%
echo.

echo [1/3] 收集系统信息... | tee "%LOG_FILE%"
echo ========== 系统信息 ========== >> "%LOG_FILE%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo ========== Java信息 ========== >> "%LOG_FILE%"
java -version 2>&1 >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo ========== 环境变量 ========== >> "%LOG_FILE%"
echo JAVA_HOME=%JAVA_HOME% >> "%LOG_FILE%"
echo GRADLE_USER_HOME=%GRADLE_USER_HOME% >> "%LOG_FILE%"
echo GRADLE_OPTS=%GRADLE_OPTS% >> "%LOG_FILE%"
echo PATH=%PATH% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo [2/3] 测试gradlew.bat并捕获所有输出...
echo ========== gradlew.bat测试 ========== >> "%LOG_FILE%"
call gradlew.bat --version --debug --stacktrace >> "%LOG_FILE%" 2>&1
set GRADLEW_EXIT=%ERRORLEVEL%
echo gradlew.bat退出代码: %GRADLEW_EXIT% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo [3/3] 尝试构建并记录详细日志...
echo ========== 构建尝试 ========== >> "%LOG_FILE%"
call gradlew.bat assembleRelease --debug --stacktrace --info >> "%LOG_FILE%" 2>&1
set BUILD_EXIT=%ERRORLEVEL%
echo 构建退出代码: %BUILD_EXIT% >> "%LOG_FILE%"

echo.
echo ========================================
echo 诊断完成!
echo.
echo 日志已保存到: %LOG_FILE%
echo 请将此文件发给技术专家分析
echo.
echo 关键退出代码:
echo   - gradlew --version: %GRADLEW_EXIT%
echo   - 构建: %BUILD_EXIT%
echo ========================================
echo.
echo 按任意键打开日志文件...
pause
notepad "%LOG_FILE%"
