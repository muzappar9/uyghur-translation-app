# GitHub 推送脚本
# 在 PowerShell 中运行此脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   GitHub 项目推送脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 切换到项目目录
Set-Location "d:\princip plan\ai translation\uyghur-translation-app1"

# 1. 确保 .env 文件不被提交（包含 API 密钥）
Write-Host "`n[1/5] 检查 .gitignore..." -ForegroundColor Yellow
$gitignoreContent = Get-Content .gitignore -ErrorAction SilentlyContinue
if ($gitignoreContent -notcontains ".env") {
    Add-Content .gitignore "`n# Environment files`n.env`n.env.local`n.env.*.local"
    Write-Host "  已添加 .env 到 .gitignore" -ForegroundColor Green
} else {
    Write-Host "  .env 已在 .gitignore 中" -ForegroundColor Green
}

# 2. 查看状态
Write-Host "`n[2/5] 当前 Git 状态:" -ForegroundColor Yellow
git status --short

# 3. 添加所有文件
Write-Host "`n[3/5] 添加所有文件..." -ForegroundColor Yellow
git add -A
Write-Host "  完成" -ForegroundColor Green

# 4. 提交
Write-Host "`n[4/5] 创建提交..." -ForegroundColor Yellow
$commitMsg = "Add HELP_REQUEST.md and project updates - Isar integration documentation"
git commit -m $commitMsg
Write-Host "  完成" -ForegroundColor Green

# 5. 推送
Write-Host "`n[5/5] 推送到 GitHub..." -ForegroundColor Yellow
Write-Host "  尝试使用 HTTPS..." -ForegroundColor Cyan

# 先尝试拉取最新更改
git pull origin main --rebase --allow-unrelated-histories

# 强制推送
git push origin main --force

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   推送完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n仓库地址: https://github.com/muzappar9/uyghur-translation-app"
