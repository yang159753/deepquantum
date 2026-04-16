#!/bin/bash
# 文档编译脚本 - 在 docs 目录下运行
# 用法: ./build.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 检查并安装文档构建依赖
check_deps() {
    if ! python3 -c "import sphinx; import myst_nb; import sphinx_book_theme" 2>/dev/null; then
        echo "==> 安装文档构建依赖 (sphinx, myst-nb, sphinx-book-theme)..."
        pip install sphinx myst-nb sphinx-book-theme
    fi
}

echo "==> 检查环境依赖..."
check_deps

echo "==> 创建文档源码链接..."
./setup_links.sh

echo "==> 编译文档..."
make html

echo "==> 完成，输出目录: $SCRIPT_DIR/_build/html/"
