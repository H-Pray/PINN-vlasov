# 使用 NVIDIA 维护的 TF1 兼容镜像，支持 RTX 40 系列显卡
FROM nvcr.io/nvidia/tensorflow:22.12-tf1-py3

# 设置工作目录
WORKDIR /workspace

# 更新系统并安装 VS Code 服务端可能需要的库
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装requirements
# COPY requirements.txt .
# RUN pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 默认启动命令
CMD ["bash"]