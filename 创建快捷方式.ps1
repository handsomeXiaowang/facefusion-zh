# 在开始菜单创建 FaceFusion 快捷方式（启动托盘）
#
# 用法：powershell -ExecutionPolicy Bypass -File 创建快捷方式.ps1
# 需要先完成 FaceFusion 的安装，见 README.md

$ErrorActionPreference = 'Stop'

$ws = New-Object -ComObject WScript.Shell
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$lnkPath = Join-Path $startMenu 'FaceFusion.lnk'

$ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$tray = 'D:\facefusion\FaceFusion托盘.ps1'
$icon = 'D:\facefusion\facefusion\facefusion.ico'

if (-not (Test-Path $tray)) {
	Write-Host "[X] 找不到托盘脚本: $tray" -ForegroundColor Red
	Write-Host "    请先按 README.md 完成安装。" -ForegroundColor Yellow
	exit 1
}
if (-not (Test-Path $icon)) {
	Write-Host "[!] 找不到图标: $icon（快捷方式将无图标）" -ForegroundColor Yellow
}

$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = $ps
$lnk.Arguments = "-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$tray`""
$lnk.WorkingDirectory = 'D:\facefusion'
if (Test-Path $icon) { $lnk.IconLocation = "$icon,0" }
$lnk.Description = 'FaceFusion 3.9.1 - 系统托盘启动'
$lnk.WindowStyle = 7
$lnk.Save()

Write-Host "[OK] 快捷方式已创建" -ForegroundColor Green
Write-Host "     $lnkPath" -ForegroundColor Green
Write-Host ""
Write-Host "     目标 : $ps" -ForegroundColor Gray
Write-Host "     图标 : $icon" -ForegroundColor Gray
Write-Host ""
Write-Host "从开始菜单搜索 FaceFusion 即可启动。" -ForegroundColor Cyan
