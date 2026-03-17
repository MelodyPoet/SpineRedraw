#!/usr/bin/env powershell
# Python 环境配置 - 完整检查清单

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Rider Python 3.13 环境配置完整检查清单                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$allChecks = @()

# 检查 1: IDE 配置文件
Write-Host "📋 检查 1: IDE 配置文件清理" -ForegroundColor Yellow
$ideaConfig = "C:\Users\admin\AppData\Roaming\JetBrains\Rider2025.3\options\jdk.table.xml"
if (Test-Path $ideaConfig) {
    $content = Get-Content $ideaConfig -Raw
    if ($content -notmatch "<jdk version" -or $content -match 'ProjectJdkTable">\s*</component>') {
        Write-Host "   ✅ IDE 配置文件已清理（无残留 SDK 配置）" -ForegroundColor Green
        $allChecks += $true
    } else {
        Write-Host "   ⚠️  IDE 配置文件中仍有 SDK 配置信息" -ForegroundColor Yellow
        $allChecks += $false
    }
} else {
    Write-Host "   ❌ IDE 配置文件不存在" -ForegroundColor Red
    $allChecks += $false
}

# 检查 2: 虚拟环境存在性
Write-Host ""
Write-Host "📋 检查 2: 虚拟环境存在性" -ForegroundColor Yellow
$venvPath = "F:\RedrawSpine-test\.venv"
if (Test-Path $venvPath) {
    Write-Host "   ✅ 虚拨环境文件夹存在: $venvPath" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "   ❌ 虚拨环境文件夹不存在: $venvPath" -ForegroundColor Red
    $allChecks += $false
}

# 检查 3: Python 可执行文件
Write-Host ""
Write-Host "📋 检查 3: Python 可执行文件" -ForegroundColor Yellow
$pythonExe = "$venvPath\Scripts\python.exe"
if (Test-Path $pythonExe) {
    Write-Host "   ✅ Python 可执行文件存在" -ForegroundColor Green
    $allChecks += $true
    
    # 检查 3.1: Python 版本
    Write-Host ""
    Write-Host "📋 检查 3.1: Python 版本" -ForegroundColor Yellow
    try {
        $version = & $pythonExe --version 2>&1
        if ($version -match "3\.13") {
            Write-Host "   ✅ 版本检查通过: $version" -ForegroundColor Green
            $allChecks += $true
        } else {
            Write-Host "   ⚠️  检测到非 3.13 版本: $version" -ForegroundColor Yellow
            $allChecks += $false
        }
    } catch {
        Write-Host "   ❌ 无法执行 Python: $_" -ForegroundColor Red
        $allChecks += $false
    }
} else {
    Write-Host "   ❌ Python 可执行文件不存在" -ForegroundColor Red
    $allChecks += $false
}

# 检查 4: 虚拨环境完整性
Write-Host ""
Write-Host "📋 检查 4: 虚拨环境完整性" -ForegroundColor Yellow
$libPath = "$venvPath\Lib"
$scriptsPath = "$venvPath\Scripts"
if ((Test-Path $libPath) -and (Test-Path $scriptsPath)) {
    Write-Host "   ✅ 虚拨环境结构完整" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "   ❌ 虚拨环境结构不完整" -ForegroundColor Red
    $allChecks += $false
}

# 检查 5: 项目结构
Write-Host ""
Write-Host "📋 检查 5: 项目配置文件" -ForegroundColor Yellow
$projectDir = "F:\RedrawSpine-test"
if (Test-Path "$projectDir\.idea") {
    Write-Host "   ✅ 项目 .idea 目录存在" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "   ❌ 项目 .idea 目录不存在" -ForegroundColor Red
    $allChecks += $false
}

# 检查 6: 帮助文档
Write-Host ""
Write-Host "📋 检查 6: 帮助文档文件" -ForegroundColor Yellow
$documents = @(
    @{Name = "QUICK_FIX.txt"; Path = "$projectDir\QUICK_FIX.txt"},
    @{Name = "PYTHON_CONFIG_FIX_README.md"; Path = "$projectDir\PYTHON_CONFIG_FIX_README.md"},
    @{Name = "STEP_BY_STEP_GUIDE.md"; Path = "$projectDir\STEP_BY_STEP_GUIDE.md"},
    @{Name = "fix_python_config.ps1"; Path = "$projectDir\fix_python_config.ps1"}
)

$docCheck = $true
foreach ($doc in $documents) {
    if (Test-Path $doc.Path) {
        Write-Host "   ✅ $($doc.Name)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $($doc.Name) 缺失" -ForegroundColor Yellow
        $docCheck = $false
    }
}
$allChecks += $docCheck

# 检查 7: 旧配置清理
Write-Host ""
Write-Host "📋 检查 7: 旧配置清理" -ForegroundColor Yellow
$oldProjectPath = "D:\迅雷下载\RedrawSpine-test"
if (-not (Test-Path $oldProjectPath)) {
    Write-Host "   ✅ 旧项目路径已不存在（配置无法自动恢复）" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "   ⚠️  旧项目路径仍然存在: $oldProjectPath" -ForegroundColor Yellow
    Write-Host "      这可能导致 IDE 混淆" -ForegroundColor Yellow
    $allChecks += $false
}

# 总结
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                     检查总结                              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$passCount = ($allChecks | Where-Object {$_ -eq $true} | Measure-Object).Count
$totalCount = $allChecks.Count
$passPercentage = [math]::Round(($passCount / $totalCount) * 100, 0)

Write-Host "通过检查: $passCount / $totalCount ($passPercentage%)" -ForegroundColor $(if ($passPercentage -ge 80) {"Green"} else {"Yellow"})
Write-Host ""

# 状态判断
if ($passPercentage -eq 100) {
    Write-Host "🎉 完美！所有检查都通过了！" -ForegroundColor Green
    Write-Host ""
    Write-Host "后续步骤:" -ForegroundColor Cyan
    Write-Host "1. 重启 Rider IDE"
    Write-Host "2. 在 Settings → Python Interpreter 中手动选择虚拨环境"
    Write-Host "3. 确认路径: F:\RedrawSpine-test\.venv\Scripts\python.exe"
    Write-Host ""
} elseif ($passPercentage -ge 80) {
    Write-Host "✅ 大部分检查通过。" -ForegroundColor Green
    Write-Host ""
    Write-Host "请注意上面标记为 ⚠️ 的项目。" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "❌ 存在多个问题需要解决。" -ForegroundColor Red
    Write-Host ""
    Write-Host "请参考 PYTHON_CONFIG_FIX_README.md 中的故障排除部分。" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host "检查完成于: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

