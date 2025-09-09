# 基础镜像
FROM oven/bun:1 as builder

# 设置工作目录
WORKDIR /app

# 复制 package.json 文件
COPY package.json bun.lock* ./
COPY frontend/package.json ./frontend/
COPY backend/package.json ./backend/

# 安装依赖
RUN bun install

# 复制源代码
COPY . .

# 构建前端
RUN bun run build:frontend

# 构建后端
RUN bun run build:backend

# 生产镜像
FROM oven/bun:1-slim

# 安装系统依赖
RUN apt-get update && \
    apt-get install -y \
    cups \
    libcups2 \
    cups-client \
    && rm -rf /var/lib/apt/lists/*

# 创建应用目录
WORKDIR /app

# 创建非 root 用户
RUN groupadd -r cloudcups && useradd -r -g cloudcups cloudcups

# 复制构建产物
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/frontend/dist ./static
COPY --from=builder /app/backend/package.json ./
COPY --from=builder /app/backend/server-production.ts ./

# 创建日志目录
RUN mkdir -p logs && chown cloudcups:cloudcups logs

# 暴露端口
EXPOSE 3000

# 切换到非 root 用户
USER cloudcups

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# 启动应用
CMD ["bun", "run", "server-production.ts"]
