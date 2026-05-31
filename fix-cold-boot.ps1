# fix-cold-boot.ps1
# 修复 NVMe 冷启动跳自动修复的问题
# 右键以管理员身份运行

# 自动提升管理员权限
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "正在请求管理员权限..." -ForegroundColor Yellow
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 冷启动自动修复 - BCD 修复脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 显示当前状态
Write-Host "[1/4] 当前启动配置:" -ForegroundColor Green
bcdedit /enum {current}
Write-Host ""

# 应用修复
Write-Host "[2/4] 禁用自动修复..." -ForegroundColor Green
bcdedit /set {default} recoveryenabled No
if ($LASTEXITCODE -eq 0) { Write-Host "  OK: recoveryenabled = No" -ForegroundColor Green }
else { Write-Host "  失败!" -ForegroundColor Red }

Write-Host "[3/4] 设置启动状态策略..." -ForegroundColor Green
bcdedit /set {current} bootstatuspolicy ignoreallfailures
if ($LASTEXITCODE -eq 0) { Write-Host "  OK: bootstatuspolicy = ignoreallfailures" -ForegroundColor Green }
else { Write-Host "  失败!" -ForegroundColor Red }

Write-Host "[4/4] 设置启动等待时间..." -ForegroundColor Green
bcdedit /timeout 15
if ($LASTEXITCODE -eq 0) { Write-Host "  OK: timeout = 15 秒" -ForegroundColor Green }
else { Write-Host "  失败!" -ForegroundColor Red }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 验证修改结果:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
bcdedit /enum {current}

Write-Host ""
Write-Host "修复完成。请完全关机等待 5 分钟后重新开机测试。" -ForegroundColor Yellow
Write-Host "提示：Windows 大版本更新可能重置这些设置，届时需重新运行此脚本。" -ForegroundColor Yellow
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
