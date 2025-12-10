@echo off
cd /d "d:\princip plan\ai translation\uyghur-translation-app1"

echo ========================================
echo 恢复您的文件 - 执行以下步骤
echo ========================================

echo.
echo 1. 中止卡住的 rebase...
git rebase --abort

echo.
echo 2. 确认恢复到您的本地版本...
git checkout main

echo.
echo 3. 检查当前状态...
git status

echo.
echo 4. 显示最近的提交历史...
git log --oneline -5

echo.
echo ========================================
echo 如果上述命令成功，您的文件应该已恢复！
echo ========================================

pause
