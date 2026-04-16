#!/bin/bash
# 完整重建：创建虚拟环境、清空所有缓存、编译文档（耗时较长）
# 用法: ./clean-build.sh
# 说明: 仅环境异常时使用。日常开发推荐 ./quick-build.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

# 计时辅助：记录开始时间，结束时调用 _elapsed 显示耗时
_t0=0
_tick() { _t0=$(date +%s); }
_elapsed() {
    local t1
    t1=$(date +%s)
    echo "    ✓ 耗时: $((t1 - _t0))s"
}

# 确保在 docs 目录
cd "$SCRIPT_DIR"
if [[ ! -f Makefile ]]; then
    echo "错误: 未找到 Makefile，请确保在 docs 目录下运行此脚本"
    exit 1
fi

if [[ ! -f source/_static/mathjax-es5/tex-mml-chtml.js ]]; then
    echo "==> 本地 MathJax 未就绪，执行 setup_mathjax_static.sh（首次约下载 25MB）..."
    ./setup_mathjax_static.sh
fi

_total_start=$(date +%s)

echo "==> 1. 创建/重建虚拟环境..."
_tick
VENV_DIR="$ROOT/.venv"
rm -rf "$VENV_DIR"
python3 -m venv "$VENV_DIR"
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"
_elapsed
echo "    虚拟环境: $VENV_DIR"

echo ""
echo "==> 2. 安装 docs 所需依赖（仅文档构建，不含 dev extras）..."
_tick
pip install -q -U pip
cd "$ROOT" && pip install -q -e . && pip install -q sphinx myst-nb sphinx-book-theme
cd "$SCRIPT_DIR"
_elapsed

echo ""
echo "==> 3. 清空缓存..."
_tick
rm -rf "$SCRIPT_DIR/_build"
rm -rf "$SCRIPT_DIR/source/_build" 2>/dev/null
rm -rf "$SCRIPT_DIR/.jupyter_cache" 2>/dev/null
rm -rf "$ROOT/build" "$ROOT/dist" 2>/dev/null
find "$ROOT" -type d -name "*.egg-info" 2>/dev/null | xargs rm -rf 2>/dev/null || true
# 仅清理 docs 内的 __pycache__（不进入符号链接指向的外部目录）
find -P "$SCRIPT_DIR" -type d -name "__pycache__" 2>/dev/null | xargs rm -rf 2>/dev/null || true
_elapsed

echo ""
echo "==> 4. 创建文档源码链接..."
_tick
./setup_links.sh
_elapsed

echo ""
echo "==> 5. 编译文档..."
_tick
make html
_elapsed

echo ""
echo "==> 完成，输出目录: $SCRIPT_DIR/_build/html/"
echo "    总耗时: $(($(date +%s) - _total_start))s"
