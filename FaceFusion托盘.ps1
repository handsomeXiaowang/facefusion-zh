# FaceFusion 系统托盘启动器
# 右键菜单：打开网页 / 退出；双击图标 = 打开网页

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$global:Root   = 'D:\facefusion\facefusion'
$global:IconPath = Join-Path $global:Root 'facefusion.ico'
$global:Url    = 'http://127.0.0.1:7860'
$global:ServerProc = $null
$global:StartedByUs = $false

function Test-ServerRunning {
	try {
		$client = New-Object System.Net.Sockets.TcpClient
		$client.Connect('127.0.0.1', 7860)
		$client.Close()
		return $true
	} catch {
		return $false
	}
}

function Start-FaceFusionServer {
	if (Test-ServerRunning) {
		$global:StartedByUs = $false
		return
	}

	$env:PATH = 'C:\Users\24107\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.2-full_build\bin;' + (Join-Path $global:Root 'venv\Scripts') + ';' + $env:PATH
	$env:HTTPS_PROXY = 'http://127.0.0.1:7897'
	$env:HTTP_PROXY  = 'http://127.0.0.1:7897'

	$global:ServerProc = Start-Process -FilePath (Join-Path $global:Root 'venv\Scripts\python.exe') `
		-ArgumentList 'facefusion.py', 'run' `
		-WorkingDirectory $global:Root `
		-WindowStyle Hidden `
		-PassThru
	$global:StartedByUs = $true
}

function Open-WebPage {
	Start-Process $global:Url
}

function Stop-FaceFusionServer {
	if ($global:StartedByUs -and $global:ServerProc -and -not $global:ServerProc.HasExited) {
		taskkill /PID $global:ServerProc.Id /T /F 2>&1 | Out-Null
	}
}

# ---------- 启动服务 ----------
Start-FaceFusionServer

# ---------- 托盘图标 ----------
$global:Icon = New-Object System.Drawing.Icon($global:IconPath)
$global:NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$global:NotifyIcon.Icon = $global:Icon
$global:NotifyIcon.Text = 'FaceFusion 3.9.1'
$global:NotifyIcon.Visible = $true

# ---------- 右键菜单 ----------
$menu = New-Object System.Windows.Forms.ContextMenuStrip

$openItem = New-Object System.Windows.Forms.ToolStripMenuItem('打开网页')
$openItem.Add_Click({ Open-WebPage })
[void]$menu.Items.Add($openItem)

[void]$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))

$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem('退出')
$exitItem.Add_Click({
	$global:NotifyIcon.Visible = $false
	Stop-FaceFusionServer
	$global:NotifyIcon.Dispose()
	$global:Icon.Dispose()
	[System.Windows.Forms.Application]::Exit()
})
[void]$menu.Items.Add($exitItem)

$global:NotifyIcon.ContextMenuStrip = $menu

# 左键单击打开网页（右键弹菜单）
$global:NotifyIcon.Add_Click({
	if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
		Open-WebPage
	}
})

# 服务起来后自动开一次浏览器
if ($global:StartedByUs) {
	for ($i = 0; $i -lt 40; $i++) {
		if (Test-ServerRunning) { break }
		Start-Sleep -Milliseconds 500
	}
	if (Test-ServerRunning) { Open-WebPage }
}

# ---------- 消息循环 ----------
[System.Windows.Forms.Application]::Run()
