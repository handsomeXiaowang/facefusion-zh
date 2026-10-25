# 更新 FaceFusion 到新版本，并重新应用中文汉化
#
# 用法：双击 或在终端执行  powershell -ExecutionPolicy Bypass -File 更新FaceFusion.ps1
#
# 流程：
#   1. 检查工作区是否干净（避免丢失改动）
#   2. 从上游拉取新版本标签
#   3. 基于新版本创建分支 zh-local-<新版本>
#   4. 把汉化提交 cherry-pick 过去
#   5. 编译验证

$ErrorActionPreference = 'Stop'
$repo = 'D:\facefusion\facefusion'

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [!] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  [X] $msg" -ForegroundColor Red }

if (-not (Test-Path (Join-Path $repo '.git'))) {
	Write-Err "找不到 git 仓库：$repo"
	exit 1
}

Push-Location $repo
try {
	# ---------- 1. 工作区检查 ----------
	Write-Step "检查工作区"
	$dirty = git status --porcelain
	if ($dirty) {
		Write-Warn "有未提交的改动："
		$dirty | ForEach-Object { Write-Host "     $_" }
		Write-Host ""
		Write-Host "  请先提交或 stash，再运行本脚本。" -ForegroundColor Yellow
		exit 1
	}
	$branch = git branch --show-current
	Write-Ok "工作区干净，当前分支 $branch"

	# ---------- 2. 拉取上游 ----------
	Write-Step "拉取上游新版本"
	git fetch origin --tags --force 2>&1 | Out-Null
	if ($LASTEXITCODE -ne 0) {
		Write-Warn "fetch 失败（可能是网络/代理问题），改用本地已有的标签继续"
	}

	# 找最新稳定版（排除 beta / rc / alpha）
	$tags = git tag --list | Where-Object { $_ -match '^\d+\.\d+\.\d+$' }
	if (-not $tags) {
		Write-Err "没有找到版本标签"
		exit 1
	}
	$latest = $tags | Sort-Object { [version]$_ } -Descending | Select-Object -First 1
	$current = (git describe --tags --abbrev=0)
	Write-Ok "当前版本 $current  →  最新版本 $latest"

	if ($current -eq $latest) {
		Write-Ok "已经是最新版，无需更新。"
		exit 0
	}

	# ---------- 3. 从新版本建分支 ----------
	Write-Step "基于 $latest 创建分支"
	$newBranch = "zh-local-$latest"
	if (git branch --list $newBranch) {
		Write-Warn "分支 $newBranch 已存在，删除后重建"
		git branch -D $newBranch 2>&1 | Out-Null
	}
	git checkout -b $newBranch $latest 2>&1 | ForEach-Object { Write-Host "  $_" }
	Write-Ok "已切换到 $newBranch（基于 $latest）"

	# ---------- 4. 重新应用汉化 ----------
	Write-Step "重新应用中文汉化"
	$zhCommit = git log zh-local --oneline -1 --format=%H
	if (-not $zhCommit) {
		Write-Err "找不到 zh-local 分支上的汉化提交"
		exit 1
	}

	git cherry-pick $zhCommit 2>&1 | ForEach-Object { Write-Host "  $_" }

	if ($LASTEXITCODE -ne 0) {
		Write-Err "cherry-pick 出现冲突，需要手动解决："
		Write-Host ""
		git status --short | Where-Object { $_ -match '^(UU|AA|DD|AU|UA)' } | ForEach-Object {
			Write-Host "     $_" -ForegroundColor Yellow
		}
		Write-Host ""
		Write-Host "  解决方式二选一：" -ForegroundColor Yellow
		Write-Host "    A) 手动编辑冲突文件后执行：  git add -A; git cherry-pick --continue" -ForegroundColor Yellow
		Write-Host "    B) 放弃本次更新回到原状：    git cherry-pick --abort; git checkout zh-local" -ForegroundColor Yellow
		Write-Host ""
		Write-Host "  或者直接告诉 Copilot 冲突文件，我来解决。" -ForegroundColor Yellow
		exit 2
	}
	Write-Ok "汉化已重新应用到 $latest"

	# ---------- 5. 验证 ----------
	Write-Step "编译验证"
	$py = Join-Path $repo 'venv\Scripts\python.exe'
	if (Test-Path $py) {
		$files = Get-ChildItem (Join-Path $repo 'facefusion') -Recurse -Filter '*.py' |
			Where-Object { $_.FullName -notmatch '__pycache__' }
		$bad = 0
		foreach ($f in $files) {
			& $py -m py_compile $f.FullName 2>&1 | Out-Null
			if ($LASTEXITCODE -ne 0) { Write-Err $f.Name; $bad++ }
		}
		if ($bad -eq 0) { Write-Ok "$($files.Count) 个文件全部编译通过" }
		else { Write-Err "$bad 个文件编译失败"; exit 1 }
	} else {
		Write-Warn "找不到 venv，跳过编译验证"
	}

	Write-Host ""
	Write-Host "========================================" -ForegroundColor Green
	Write-Host " 更新完成：$current  ->  $latest" -ForegroundColor Green
	Write-Host " 分支：$newBranch" -ForegroundColor Green
	Write-Host " 下一步：重启 FaceFusion 使改动生效" -ForegroundColor Green
	Write-Host "========================================" -ForegroundColor Green
}
finally {
	Pop-Location
}
