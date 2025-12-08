#!/usr/bin/env pwsh
# Alkatip 字体安装脚本 - Windows PowerShell

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Alkatip 字体安装向导" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 检查项目根目录
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "错误: 请在项目根目录运行此脚本！" -ForegroundColor Red
    exit 1
}

# 创建字体文件夹
Write-Host "📁 创建字体文件夹..." -ForegroundColor Yellow
$alkatipDir = "assets/fonts/alkatip"
$chineseDir = "assets/fonts/chinese"

if (-not (Test-Path $alkatipDir)) {
    New-Item -ItemType Directory -Path $alkatipDir -Force | Out-Null
    Write-Host "✅ 已创建: $alkatipDir" -ForegroundColor Green
} else {
    Write-Host "✅ 文件夹已存在: $alkatipDir" -ForegroundColor Green
}

if (-not (Test-Path $chineseDir)) {
    New-Item -ItemType Directory -Path $chineseDir -Force | Out-Null
    Write-Host "✅ 已创建: $chineseDir" -ForegroundColor Green
} else {
    Write-Host "✅ 文件夹已存在: $chineseDir" -ForegroundColor Green
}

Write-Host ""

# 检查字体文件
Write-Host "🔍 检查字体文件..." -ForegroundColor Yellow

$alkatipFonts = @(
    "Alkatip.ttf",
    "AlkatipKona.ttf",
    "AlkatipTor.ttf",
    "AlkatipYumilaq.ttf",
    "AlkatipNazik.ttf",
    "AlkatipBasma.ttf",
    "AlkatipTarixi.ttf",
    "AlkatipQol.ttf",
    "AlkatipKompyuter.ttf",
    "AlkatipChong.ttf"
)

$chineseFonts = @(
    "SourceHanSansSC-Regular.otf",
    "SourceHanSansSC-Bold.otf",
    "SourceHanSerifSC-Regular.otf",
    "SourceHanSerifSC-Bold.otf",
    "ZhanKuKuaiLe-Regular.ttf",
    "FZKai.ttf",
    "FZHei.ttf"
)

$alkatipMissing = @()
$chineseMissing = @()

Write-Host ""
Write-Host "Alkatip 字体:" -ForegroundColor Cyan
foreach ($font in $alkatipFonts) {
    $path = Join-Path $alkatipDir $font
    if (Test-Path $path) {
        Write-Host "  ✅ $font" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $font (缺失)" -ForegroundColor Red
        $alkatipMissing += $font
    }
}

Write-Host ""
Write-Host "汉语字体:" -ForegroundColor Cyan
foreach ($font in $chineseFonts) {
    $path = Join-Path $chineseDir $font
    if (Test-Path $path) {
        Write-Host "  ✅ $font" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $font (缺失)" -ForegroundColor Yellow
        $chineseMissing += $font
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "检查结果:" -ForegroundColor Cyan
Write-Host "  Alkatip 字体: $($alkatipFonts.Count - $alkatipMissing.Count)/$($alkatipFonts.Count)" -ForegroundColor $(if ($alkatipMissing.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "  汉语字体: $($chineseFonts.Count - $chineseMissing.Count)/$($chineseFonts.Count)" -ForegroundColor $(if ($chineseMissing.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "==================================" -ForegroundColor Cyan

if ($alkatipMissing.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  缺少以下 Alkatip 字体文件:" -ForegroundColor Yellow
    foreach ($font in $alkatipMissing) {
        Write-Host "   • $font" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "📥 请将字体文件放置到: $alkatipDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 提示:" -ForegroundColor Cyan
    Write-Host "   1. 从 Alkatip 官方获取字体文件" -ForegroundColor Gray
    Write-Host "   2. 或使用 Noto Sans Arabic 作为临时替代" -ForegroundColor Gray
    Write-Host "   3. 确保文件名完全匹配（区分大小写）" -ForegroundColor Gray
}

if ($chineseMissing.Count -gt 0) {
    Write-Host ""
    Write-Host "ℹ️  缺少以下汉语字体文件（可选）:" -ForegroundColor Cyan
    foreach ($font in $chineseMissing) {
        Write-Host "   • $font" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "📥 下载地址:" -ForegroundColor Cyan
    Write-Host "   • 思源字体: https://github.com/adobe-fonts" -ForegroundColor Gray
    Write-Host "   • 站酷字体: https://www.zcool.com.cn/special/zcoolfonts/" -ForegroundColor Gray
}

# 清理和构建
Write-Host ""
$rebuild = Read-Host "是否重新构建项目? (y/N)"
if ($rebuild -eq "y" -or $rebuild -eq "Y") {
    Write-Host ""
    Write-Host "🧹 清理项目..." -ForegroundColor Yellow
    flutter clean
    
    Write-Host "📦 获取依赖..." -ForegroundColor Yellow
    flutter pub get
    
    Write-Host "✅ 完成！" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 运行应用: flutter run" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "✅ 检查完成！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下次运行前记得执行:" -ForegroundColor Cyan
    Write-Host "  flutter clean && flutter pub get" -ForegroundColor Gray
}

Write-Host ""
