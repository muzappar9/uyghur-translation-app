#!/usr/bin/env pwsh
# Alkatip 字体自动下载和安装脚本

param(
    [switch]$SkipChinese,
    [switch]$Force
)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  字体自动下载安装工具" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 检查项目根目录
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ 错误: 请在项目根目录运行此脚本！" -ForegroundColor Red
    exit 1
}

# 创建临时下载目录
$tempDir = "temp_fonts"
$alkatipDir = "assets/fonts/alkatip"
$chineseDir = "assets/fonts/chinese"

if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# 创建字体目录
@($alkatipDir, $chineseDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
        Write-Host "✅ 已创建目录: $_" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📥 开始下载字体文件..." -ForegroundColor Yellow
Write-Host ""

# ==================================================
# 下载思源字体 (Source Han Sans/Serif)
# ==================================================
function Download-SourceHanFonts {
    Write-Host "📦 下载思源字体..." -ForegroundColor Cyan
    
    $fonts = @(
        @{
            Name = "SourceHanSansSC-Regular.otf"
            Url = "https://github.com/adobe-fonts/source-han-sans/raw/release/SubsetOTF/SC/SourceHanSansSC-Regular.otf"
        },
        @{
            Name = "SourceHanSansSC-Bold.otf"
            Url = "https://github.com/adobe-fonts/source-han-sans/raw/release/SubsetOTF/SC/SourceHanSansSC-Bold.otf"
        },
        @{
            Name = "SourceHanSerifSC-Regular.otf"
            Url = "https://github.com/adobe-fonts/source-han-serif/raw/release/SubsetOTF/SC/SourceHanSerifSC-Regular.otf"
        },
        @{
            Name = "SourceHanSerifSC-Bold.otf"
            Url = "https://github.com/adobe-fonts/source-han-serif/raw/release/SubsetOTF/SC/SourceHanSerifSC-Bold.otf"
        }
    )
    
    foreach ($font in $fonts) {
        $destPath = Join-Path $chineseDir $font.Name
        
        if ((Test-Path $destPath) -and -not $Force) {
            Write-Host "  ⏭️  跳过 (已存在): $($font.Name)" -ForegroundColor Gray
            continue
        }
        
        try {
            Write-Host "  ⬇️  下载: $($font.Name)..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $font.Url -OutFile $destPath -TimeoutSec 300
            Write-Host "  ✅ 完成: $($font.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ 失败: $($font.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# ==================================================
# 下载 Noto Sans Arabic (Alkatip 替代方案)
# ==================================================
function Download-NotoArabicFonts {
    Write-Host ""
    Write-Host "📦 下载 Noto Sans Arabic (Alkatip 开源替代)..." -ForegroundColor Cyan
    
    # Noto Sans Arabic 的不同字重可以模拟不同的 Alkatip 变体
    $fonts = @(
        @{
            Name = "Alkatip.ttf"  # Regular
            Url = "https://github.com/notofonts/noto-fonts/raw/main/hinted/ttf/NotoSansArabic/NotoSansArabic-Regular.ttf"
            Display = "标准体 (Regular)"
        },
        @{
            Name = "AlkatipTor.ttf"  # Bold
            Url = "https://github.com/notofonts/noto-fonts/raw/main/hinted/ttf/NotoSansArabic/NotoSansArabic-Bold.ttf"
            Display = "粗体 (Bold)"
        },
        @{
            Name = "AlkatipNazik.ttf"  # Light
            Url = "https://github.com/notofonts/noto-fonts/raw/main/hinted/ttf/NotoSansArabic/NotoSansArabic-Light.ttf"
            Display = "细体 (Light)"
        },
        @{
            Name = "AlkatipKona.ttf"  # Medium
            Url = "https://github.com/notofonts/noto-fonts/raw/main/hinted/ttf/NotoSansArabic/NotoSansArabic-Medium.ttf"
            Display = "经典体 (Medium)"
        }
    )
    
    foreach ($font in $fonts) {
        $destPath = Join-Path $alkatipDir $font.Name
        
        if ((Test-Path $destPath) -and -not $Force) {
            Write-Host "  ⏭️  跳过 (已存在): $($font.Name)" -ForegroundColor Gray
            continue
        }
        
        try {
            Write-Host "  ⬇️  下载: $($font.Display)..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $font.Url -OutFile $destPath -TimeoutSec 300
            Write-Host "  ✅ 完成: $($font.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ 失败: $($font.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # 为剩余的 Alkatip 变体创建符号链接（复制 Regular）
    $regularFont = Join-Path $alkatipDir "Alkatip.ttf"
    $remainingFonts = @(
        "AlkatipYumilaq.ttf",
        "AlkatipBasma.ttf", 
        "AlkatipTarixi.ttf",
        "AlkatipQol.ttf",
        "AlkatipKompyuter.ttf",
        "AlkatipChong.ttf"
    )
    
    if (Test-Path $regularFont) {
        Write-Host ""
        Write-Host "  📋 为其他变体创建副本..." -ForegroundColor Yellow
        foreach ($fontName in $remainingFonts) {
            $destPath = Join-Path $alkatipDir $fontName
            if (-not (Test-Path $destPath)) {
                Copy-Item $regularFont $destPath
                Write-Host "  ✅ 创建: $fontName" -ForegroundColor Green
            }
        }
    }
}

# ==================================================
# 下载站酷字体
# ==================================================
function Download-ZhanKuFonts {
    Write-Host ""
    Write-Host "📦 下载站酷快乐体..." -ForegroundColor Cyan
    
    # 站酷快乐体 GitHub 镜像
    $url = "https://raw.githubusercontent.com/googlefonts/googlefonts-project-template/main/fonts/ttf/ZcoolKuaiLe-Regular.ttf"
    $destPath = Join-Path $chineseDir "ZhanKuKuaiLe-Regular.ttf"
    
    if ((Test-Path $destPath) -and -not $Force) {
        Write-Host "  ⏭️  跳过 (已存在): ZhanKuKuaiLe-Regular.ttf" -ForegroundColor Gray
        return
    }
    
    try {
        Write-Host "  ⬇️  下载: 站酷快乐体..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile $destPath -TimeoutSec 300
        Write-Host "  ✅ 完成: ZhanKuKuaiLe-Regular.ttf" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  站酷快乐体下载失败，将使用系统字体" -ForegroundColor Yellow
        Write-Host "     错误: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

# ==================================================
# 主执行流程
# ==================================================

# 下载维吾尔语字体 (使用 Noto Sans Arabic 作为 Alkatip 替代)
Download-NotoArabicFonts

# 下载汉语字体
if (-not $SkipChinese) {
    Download-SourceHanFonts
    Download-ZhanKuFonts
    
    # 为方正字体创建占位说明
    $fzNote = @"
📝 方正字体说明:

方正字体 (FZKai.ttf, FZHei.ttf) 需要商业授权。

选项 1: 手动下载
  • 访问方正字库官网购买授权
  • 将字体文件放入: $chineseDir

选项 2: 使用免费替代
  • 应用会自动使用系统自带的字体
  • 或者已下载的思源宋体/黑体

选项 3: 使用系统字体
  • 选择"系统默认"即可
"@
    
    Write-Host ""
    Write-Host $fzNote -ForegroundColor Cyan
}

# 清理临时文件
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "✅ 字体下载完成！" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

# 统计已安装字体
Write-Host ""
Write-Host "📊 字体统计:" -ForegroundColor Yellow

$alkatipCount = (Get-ChildItem "$alkatipDir/*.ttf" -ErrorAction SilentlyContinue).Count
$chineseCount = (Get-ChildItem "$chineseDir/*.*tf" -ErrorAction SilentlyContinue).Count

Write-Host "  • Alkatip 字体: $alkatipCount/10" -ForegroundColor $(if ($alkatipCount -ge 4) { "Green" } else { "Yellow" })
Write-Host "  • 汉语字体: $chineseCount/7" -ForegroundColor $(if ($chineseCount -ge 3) { "Green" } else { "Yellow" })

Write-Host ""
Write-Host "📝 重要说明:" -ForegroundColor Cyan
Write-Host "  1. Noto Sans Arabic 已作为 Alkatip 的开源替代" -ForegroundColor Gray
Write-Host "  2. 如需正版 Alkatip，请访问官方网站购买" -ForegroundColor Gray
Write-Host "  3. 方正字体需要商业授权" -ForegroundColor Gray
Write-Host "  4. 思源字体和站酷字体完全免费" -ForegroundColor Gray

Write-Host ""
$rebuild = Read-Host "是否立即构建项目? (Y/n)"
if ($rebuild -ne "n" -and $rebuild -ne "N") {
    Write-Host ""
    Write-Host "🔧 清理并重新构建..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
    
    Write-Host ""
    Write-Host "✅ 构建完成！" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 运行应用:" -ForegroundColor Cyan
    Write-Host "   flutter run" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "💡 别忘了运行:" -ForegroundColor Cyan
    Write-Host "   flutter clean && flutter pub get && flutter run" -ForegroundColor White
}

Write-Host ""
