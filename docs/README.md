# DeepQuantum 文档构建与运行指南

## 构建脚本（推荐）

`docs` 目录下提供四个脚本，可自动完成虚拟环境创建、依赖安装、源码链接与文档编译。

| 脚本 | 用途 | 环境存在时 | 环境不存在时 |
|------|------|------------|--------------|
| `quick-build.sh` | 快速编译 | 清缓存后编译（复用 venv） | 自动执行 `clean-build.sh` |
| `quick-build-serve.sh [端口]` | 快速编译并启动服务 | 清缓存后编译并启动 | 自动执行 `clean-build-serve.sh` |
| `clean-build.sh` | 完整重建 | — | 创建 venv、安装依赖、清缓存、编译 |
| `clean-build-serve.sh [端口]` | 完整重建并启动服务 | — | 同上 + 启动 HTTP 服务 |

**日常开发**：直接用 `quick-build.sh` 或 `quick-build-serve.sh`；若 `.venv` 不存在，会自动走完整重建流程。

```bash
cd docs

# 仅编译
./quick-build.sh

# 编译并启动服务（默认端口 8765）
./quick-build-serve.sh
./quick-build-serve.sh 8888   # 指定端口
```

**环境异常时**：可手动执行 `clean-build.sh` 或 `clean-build-serve.sh` 做完整重建。

构建产物位于 `docs/_build/html/`。访问：http://127.0.0.1:8765/

## 手动构建（可选）

如需手动管理环境与构建：

### 1. 创建虚拟环境并安装依赖

```bash
cd /path/to/deepquantum
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

pip install -e .
pip install sphinx myst-nb sphinx-book-theme
```

### 2. 创建文档源码链接（必做）

```bash
cd docs
./setup_links.sh
```

> **重要**：`setup_links.sh` 必须在**构建文档之前**运行。该脚本会在 `docs/source/` 下创建指向仓库根目录 `tutorials` 的符号链接；**Demos 示例**已作为源码目录置于 `docs/source/demos`，无需链接。若 `tutorials` 链接错误（如误指向 `./tutorials`），Sphinx 构建时会报 `RuntimeError: Symlink loop`。若出现此错误，重新运行 `./setup_links.sh` 即可修复。

### 3. 构建与启动

```bash
cd docs
make html
cd _build/html && python3 -m http.server 8765
```

## 常见问题

| 问题 | 原因 | 解决方法 |
|------|------|----------|
| `RuntimeError: Symlink loop from '.../tutorials/basics.ipynb'` | `docs/source/tutorials` 符号链接指向错误，形成循环引用 | 在 `docs` 目录运行 `./setup_links.sh` 重新创建正确链接 |

## 文档结构

- **首页**：项目简介（含 README）
- **Quick Start**：快速入门（中/英）
- **Tutorials**：教程（basics、photonic_basics、mbqc_basics）
- **Demos**：示例（boson_sampling、advanced_cluster_state）
- **API**：API 参考（自动生成）
