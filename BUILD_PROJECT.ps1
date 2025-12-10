# 项目构建脚本
# 在 PowerShell 中运行此脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Uyghur Translator 构建脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Set-Location "d:\princip plan\ai translation\uyghur-translation-app1"

# 1. 清理旧构建
Write-Host "`n[1/5] 清理旧构建..." -ForegroundColor Yellow
flutter clean
Write-Host "  完成" -ForegroundColor Green

# 2. 获取依赖
Write-Host "`n[2/5] 获取依赖 (isar_community 等)..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "  错误: flutter pub get 失败!" -ForegroundColor Red
    exit 1
}
Write-Host "  完成" -ForegroundColor Green

# 3. 运行代码生成器
Write-Host "`n[3/5] 运行 build_runner 生成 Isar 代码..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "  错误: build_runner 失败!" -ForegroundColor Red
    exit 1
}
Write-Host "  完成" -ForegroundColor Green

# 4. 分析代码
Write-Host "`n[4/5] 分析代码..." -ForegroundColor Yellow
flutter analyze
Write-Host "  分析完成" -ForegroundColor Green

# 5. 运行测试
Write-Host "`n[5/5] 测试构建 (Android APK)..." -ForegroundColor Yellow
flutter build apk --debug
if ($LASTEXITCODE -ne 0) {
    Write-Host "  警告: APK 构建失败，请检查错误" -ForegroundColor Yellow
} else {
    Write-Host "  APK 构建成功!" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   构建流程完成" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n下一步:"
Write-Host "  1. 运行 'flutter run' 测试应用"
Write-Host "  2. 运行 '.\PUSH_TO_GITHUB.ps1' 推送到 GitHub"
