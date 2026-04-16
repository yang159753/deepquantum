#!/bin/bash
# 在 docs/source 下创建 tutorials 符号链接（demos 已作为源码置于 docs/source/demos）
# 用法: 从 docs 目录运行 ./setup_links.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCS_SRC="${SCRIPT_DIR}/source"
ROOT="$(dirname "$SCRIPT_DIR")"

cd "$DOCS_SRC"

# tutorials: 链接整个目录（必须使用绝对路径 $ROOT/tutorials，否则会形成 Symlink loop 导致 Sphinx 构建失败）
rm -f tutorials 2>/dev/null
ln -sf "$ROOT/tutorials" tutorials
echo "✓ tutorials -> $ROOT/tutorials"

# 移除旧版 cases 符号链接
rm -f cases 2>/dev/null

# demos 为 docs/source/demos 内联源码，不再创建符号链接
