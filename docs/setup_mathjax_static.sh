#!/usr/bin/env bash
# 将 MathJax 3 es5 整包解压到 docs/source/_static/mathjax-es5，避免依赖 jsDelivr 导致国内超时。
# 用法：在 docs 目录执行  ./setup_mathjax_static.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATIC="${SCRIPT_DIR}/source/_static"
TARGET="${STATIC}/mathjax-es5"
MATHJAX_VER="${MATHJAX_VER:-3.2.2}"
TMP="${SCRIPT_DIR}/.mathjax_extract_$$"

mkdir -p "${STATIC}"
rm -rf "${TARGET}"
mkdir -p "${TMP}"
cd "${TMP}"

echo "Downloading mathjax@${MATHJAX_VER} from registry.npmjs.org ..."
curl -fsSL "https://registry.npmjs.org/mathjax/-/mathjax-${MATHJAX_VER}.tgz" | tar -xz

if [[ ! -d "package/es5" ]]; then
  echo "error: package/es5 not found in tarball"
  exit 1
fi

mv "package/es5" "${TARGET}"
cd "${SCRIPT_DIR}"
rm -rf "${TMP}"

echo "Done: ${TARGET}/tex-mml-chtml.js"
echo "Rebuild HTML; Sphinx will use mathjax_path relative to _static when this directory exists."
