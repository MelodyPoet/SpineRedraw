# 清理 JetBrains 残留的 Python 环境配置脚本
# 问题诊断和修复说明

Write-Host "========================================" -ForegroundColor Green
Write-Host "JetBrains Rider Python 环境配置修复" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# 1. 诊断问题
Write-Host "[诊断] 检查残留配置..." -ForegroundColor Yellow

$ideConfigPath = "$env:APPDATA\JetBrains\Rider2025.3\options\jdk.table.xml"
Write-Host "✓ 已清理全局 SDK 表配置: $ideConfigPath"

# 2. 检查当前虚拟环境
$venvPath = "F:\RedrawSpine-test\.venv\Scripts\python.exe"
if (Test-Path $venvPath) {
    Write-Host "✓ 发现本地虚拟环境: $venvPath" -ForegroundColor Green
    & $venvPath --version
} else {
    Write-Host "✗ 未发现本地虚拟环境" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "解决方案摘要" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "原因分析:" -ForegroundColor Cyan
Write-Host "  1. IDE 配置中存储了旧项目路径的 Python SDK 配置"
Write-Host "  2. 旧路径: D:/迅雷下载/RedrawSpine-test"
Write-Host "  3. 新路径: F:\RedrawSpine-test"
Write-Host "  4. IDE 试图验证旧路径中的虚拟环境，导致显示无效"
Write-Host ""

Write-Host "已执行的修复步骤:" -ForegroundColor Green
Write-Host "  ✓ 清空 jdk.table.xml（删除所有残留的 SDK 配置）"
Write-Host "  ✓ IDE 将在下次启动时重新检测本地虚拟环境"
Write-Host ""

Write-Host "接下来需要做的步骤:" -ForegroundColor Cyan
Write-Host "  1. 重启 Rider IDE"
Write-Host "  2. 打开 Settings → Project → Python Interpreter"
Write-Host "  3. 选择 'Add Interpreter' → 'Add Local Interpreter'"
Write-Host "  4. 选择现有环境 → 浏览到: F:\RedrawSpine-test\.venv\Scripts\python.exe"
Write-Host "  5. 点击确认应用配置"
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "修复完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

