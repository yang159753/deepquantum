#!/bin/bash
# 启动文档服务 - 在 docs 目录下运行
# 用法: ./serve.sh [端口]

cd "$(dirname "$0")"
PORT="${1:-8765}"
echo "构建文档..."
make html
echo "启动服务 http://127.0.0.1:$PORT"
cd _build/html && python3 -m http.server "$PORT"
