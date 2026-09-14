FROM python:3.11

# 安装 Node.js 20（Vite 7 需要 Node >=20.19）及必要工具
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates gnupg \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

# 从 uv 官方镜像复制 uv
COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /uvx /bin/

WORKDIR /app

# 先复制依赖描述文件以利用缓存
COPY package.json package-lock.json ./
COPY frontend/package.json frontend/package-lock.json ./frontend/
COPY backend/pyproject.toml backend/uv.lock ./backend/

# 安装依赖（Node + Python）
RUN npm ci \
  && npm ci --prefix frontend \
  && cd backend && uv sync --frozen

# 复制项目源码
COPY . .

# 构建前端（axios 使用相对路径 -> 与后端同源）
RUN cd frontend && npm run build

# 生产环境：由 Flask 后端同时提供 API 和前端静态资源。
# Railway 通过 $PORT 注入端口，run.py 会优先读取它。
ENV FLASK_HOST=0.0.0.0
EXPOSE 5001

CMD ["sh", "-c", "cd backend && uv run python run.py"]
