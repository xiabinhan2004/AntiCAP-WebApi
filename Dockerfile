FROM python:3.10-slim

WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# 配置apt源和超时设置
RUN echo 'Acquire::http::Timeout "10";' > /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::ftp::Timeout "10";' >> /etc/apt/apt.conf.d/99timeout && \
    echo 'Acquire::Retries "3";' >> /etc/apt/apt.conf.d/99timeout

# 分步安装系统依赖，增加错误处理
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 尝试安装编译相关依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 安装OpenGL相关依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/* || true

# 复制并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir --timeout 60 -r requirements.txt

# 复制应用代码
COPY main.py .
COPY static/ ./static/

# 创建非root用户
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

EXPOSE 6688
CMD ["python", "main.py"]