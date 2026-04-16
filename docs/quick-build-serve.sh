#!/bin/bash
# 快速编译并启动服务：仅清空 docs 构建缓存后重新编译（复用 venv）
# 用法: ./quick-build-serve.sh [端口]
# 示例: ./quick-build-serve.sh       # 默认 8765
#       ./quick-build-serve.sh 8888
# 说明: 日常开发推荐使用。若环境异常，请用 clean-build-serve.sh 完整重建。

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

PORT="${1:-8765}"

cd "$SCRIPT_DIR"
if [[ ! -f Makefile ]]; then
    echo "错误: 未找到 Makefile"
    exit 1
fi

# 若环境不存在，则执行完整重建
VENV_DIR="$ROOT/.venv"
if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
    echo "未找到 .venv，执行 clean-build-serve.sh 创建环境..."
    exec "$SCRIPT_DIR/clean-build-serve.sh" "$PORT"
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
echo "==> 4. 启动服务 http://127.0.0.1:$PORT"
echo "    总耗时: $(($(date +%s) - _total_start))s"
echo "    按 Ctrl+C 停止服务"
echo ""
cd _build/html && python3 -m http.server "$PORT"
