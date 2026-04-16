# 文档前端服务：使用本地已构建的 docs/_build/html，无需在镜像内联网构建
# 使用前请在项目根目录执行: make -C docs html
FROM nginx:alpine

# 从构建上下文复制已构建好的静态站点（需先执行 make -C docs html）
COPY ./_build/html /usr/share/nginx/html

# 使用自定义 nginx 配置（支持 Sphinx 目录链接与静态缓存）

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
