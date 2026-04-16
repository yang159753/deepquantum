#!/bin/bash
# 快速编译：仅清空 docs 构建缓存后重新编译（复用 venv，解决缓存问题且耗时短）
# 用法: ./quick-build.sh
# 说明: 日常开发推荐使用。若环境异常，请用 clean-build.sh 完整重建。

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"

# 计时辅助
_t0=0
_tick() { _t0=$(date +%s); }
_elapsed() {
    local t1
    t1=$(date +%s)
    echo "    ✓ 耗时: $((t1 - _t0))s"
}

cd "$SCRIPT_DIR"
if [[ ! -f Makefile ]]; then
    echo "错误: 未找到 Makefile"
    exit 1
fi

# 本地 MathJax：避免 HTML 引用 jsDelivr 导致国内 net::ERR_CONNECTION_TIMED_OUT
if [[ ! -f source/_static/mathjax-es5/tex-mml-chtml.js ]]; then
    echo "==> 本地 MathJax 未就绪，执行 setup_mathjax_static.sh（首次约下载 25MB）..."
    ./setup_mathjax_static.sh
fi

# 若环境不存在，则执行完整重建
VENV_DIR="$ROOT/.venv"
if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "未找到 .venv，执行 clean-build.sh 创建环境..."
    exec "$SCRIPT_DIR/clean-build.sh"
fi

# 激活 venv
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"
echo "使用虚拟环境: $VENV_DIR"

_total_start=$(date +%s)

echo ""
echo "==> 1. 清空 docs 构建缓存..."
_tick
rm -rf "$SCRIPT_DIR/_build"
rm -rf "$SCRIPT_DIR/source/_build" 2>/dev/null
rm -rf "$SCRIPT_DIR/.jupyter_cache" 2>/dev/null
_elapsed

echo ""
echo "==> 2. 创建文档源码链接..."
_tick
./setup_links.sh
_elapsed

echo ""
echo "==> 3. 编译文档..."
_tick
make html
_elapsed

echo ""
echo "==> 完成，输出目录: $SCRIPT_DIR/_build/html/"
echo "    总耗时: $(($(date +%s) - _total_start))s"
