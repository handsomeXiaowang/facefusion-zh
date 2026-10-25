@echo off
chcp 65001 >nul
title FaceFusion 3.9.1 - RX 9070 XT (DirectML)

set "ROOT=D:\facefusion\facefusion"
set "FFBIN=C:\Users\24107\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.2-full_build\bin"

rem ffmpeg 加入 PATH（winget 已装，但需在此显式指定）
set "PATH=%FFBIN%;%ROOT%\venv\Scripts;%PATH%"

rem 让模型下载走 Clash 代理（可选，仅影响下载速度）
set "HTTPS_PROXY=http://127.0.0.1:7897"
set "HTTP_PROXY=http://127.0.0.1:7897"

cd /d "%ROOT%"

echo ============================================
echo   FaceFusion 3.9.1
echo   GPU: AMD Radeon RX 9070 XT (DirectML)
echo ============================================
echo.
echo 正在启动... 浏览器将在服务就绪后自动打开
echo 关闭此窗口即可停止程序。
echo.

"venv\Scripts\python.exe" facefusion.py run --open-browser

echo.
echo 程序已退出。
pause
