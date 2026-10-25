# facefusion-zh

FaceFusion 3.9.1 的**中文汉化**与**Windows 启动增强**，只包含改动本身，不含原项目代码。

> 原项目：https://github.com/facefusion/facefusion
> 本仓库**不是 fork**，只存放我的修改。

## 内容

| 文件 | 作用 |
|---|---|
| `zh-local.patch` | 汉化补丁（46 个文件，+691 −63） |
| `FaceFusion托盘.ps1` | 系统托盘图标：**左键单击**打开网页，右键菜单「打开网页 / 退出」 |
| `启动FaceFusion.bat` | 双击启动，自动配环境并开浏览器 |
| `下载全部模型.bat` | 补下全部模型（含 24 个 dfm，约 16 GB） |
| `更新FaceFusion.ps1` | 升级 FaceFusion 后自动重新应用汉化 |
| `创建快捷方式.ps1` | 在开始菜单创建托盘启动快捷方式 |

## 汉化包含什么

- 界面全部中文化（约 340 条字符串，12 个 `locales.py`）
- 所有下拉/复选框**选项**汉化（383 个选项中的 347 个）
- 处理器名：`face_swapper` → 换脸、`lip_syncer` → 口型同步 等
- 157 个 deep_swapper 名人模型中文名
- 模型名附带用途说明，例如 `Real-ESRGAN 4倍（推荐）`

**后端逻辑和命令行仍接收原始英文标识符**，只有界面层显示中文。

## 安装

```powershell
# 1. 克隆原项目
git clone https://github.com/facefusion/facefusion.git
cd facefusion
git checkout 3.9.1

# 2. 应用汉化补丁
git apply path\to\zh-local.patch

# 3. 装依赖（Windows + A 卡用 directml）
python -m venv venv
.\venv\Scripts\activate
python install.py directml --skip-conda

# 4. 下载模型
python facefusion.py force-download

# 5. 把本仓库的 4 个脚本拷到 facefusion 仓库外层，双击启动
# 6. 创建开始菜单快捷方式（指向托盘）
powershell -ExecutionPolicy Bypass -File 创建快捷方式.ps1
```

> **注意**：补丁基于 **3.9.1**。若上游版本更新导致 `git apply` 冲突，
> 改用 `patch -p1 --fuzz=5 < zh-local.patch`，或把冲突文件交给 AI 处理。

## 依赖

- Windows 10/11
- Python 3.10–3.12
- ffmpeg（`winget install Gyan.FFmpeg`）
- AMD 显卡用 `directml` 后端，NVIDIA 用 `cuda`

## 更新流程

FaceFusion 出新版时，运行 `更新FaceFusion.ps1`：

1. 检查工作区干净
2. 拉取上游最新稳定版标签
3. 基于新版建分支 `zh-local-<版本>`
4. cherry-pick 汉化提交
5. 编译验证

若发生冲突会列出冲突文件并中止，不会破坏现有代码。

## 免责声明

换脸工具，请确保对源人脸与目标素材拥有相应权利，
仅用于合法、合乎伦理的用途。
