@echo off
chcp 65001 >nul
title FaceFusion - 下载全部模型

set "ROOT=D:\facefusion\facefusion"
set "FFBIN=C:\Users\24107\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.2-full_build\bin"

set "PATH=%FFBIN%;%ROOT%\venv\Scripts;%PATH%"

rem 必须走代理，否则只有 50-100 KB/s 且容易校验失败
set "HTTPS_PROXY=http://127.0.0.1:7897"
set "HTTP_PROXY=http://127.0.0.1:7897"

cd /d "%ROOT%"

echo ============================================
echo   下载全部模型（含 24 个 dfm，约 16 GB）
echo   核心换脸模型已下好，此步骤为可选补充
echo ============================================
echo.

"venv\Scripts\python.exe" facefusion.py force-download

echo.
echo 下载结束，退出码 %ERRORLEVEL%
pause
