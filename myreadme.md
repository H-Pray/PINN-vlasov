# 1D Vlasov-Poisson PINN 研究项目 (RTX 4060 优化版)

本项目利用物理信息神经网络 (PINN) 求解一维 Vlasov-Poisson 系统，模拟等离子体中的经典物理现象：朗道阻尼 (Landau Damping)、free stream、fluidOscillation。

## 环境概览
为了在现代 **NVIDIA RTX 40 系列** 显卡上运行旧版 **TensorFlow 1.x** 框架，本项目采用了定制化的 Docker 开发环境，解决了 `GLIBC` 库版本过低导致的 VS Code 连接失败问题。

* **核心框架**: TensorFlow 1.15.5 (NVIDIA 优化版)
* **硬件适配**: NVIDIA RTX 4060 8GB / Intel i5-12400F
* **基础镜像**: `nvcr.io/nvidia/tensorflow:22.12-tf1-py3`
* **开发工具**: VS Code + Dev Containers 插件

---

## 关键修复记录 (Environment Fix Log)

### 1. 显卡与驱动匹配
* **问题**: 旧版镜像 (19.07) 无法识别 RTX 40 系列架构，报错 "No supported GPU(s) detected"。
* **修复**: 升级基础镜像至 `22.12-tf1-py3`，该镜像内置 CUDA 11.8，原生支持 RTX 4060 显卡并包含符合 VS Code 要求的 `GLIBC 2.28+` 环境。

### 2. NumPy 兼容性补丁
* **问题**: `NumPy 1.20+` 移除了 `np.object` 等别名，导致 TensorFlow 1.x 核心库报错 `AttributeError: module 'numpy' has no attribute 'object'`。
* **修复**: 在脚本 (`vlasovEfield.py`) 所有 `import` 语句前加入以下“补丁”代码：
    ```python
    import numpy as np
    if not hasattr(np, 'object'): np.object = object
    if not hasattr(np, 'bool'): np.bool = bool
    ```

### 3. 视频渲染依赖
* **修复**: 在容器内安装了 `ffmpeg` 库，解决了渲染 `.mp4` 模拟动画时提示 `MovieWriter (ffmpeg) not available` 的报错。

---

## 快速启动与监控指令 (Cheat Sheet)

### 首次创建容器 (First Run)
在 Windows PowerShell 中执行以下指令，挂载代码目录并启用 GPU 支持：
```bash
docker run --gpus all --shm-size=1g -v E:\PINNvlasov:/workspace --name pinn_vlasov_active -it pinn_vlasov_rtx4060
```
> 此指令仅用于**首次创建**容器。容器创建后，后续启动请使用下方的 `docker start` 指令。
### 查看所有容器
```bash
docker ps -a
```
### 删除容器
```bash
docker rm <容器ID>
```
### 清理所有停止的容器
```bash
docker container prune
```

### 日常工作流 (Daily Workflow)

#### 1. 启动已有容器并进入交互终端
启动已停止的容器
```bash
docker start pinn_vlasov_active
```
进入容器的交互式 bash
```bash
docker exec -it pinn_vlasov_active bash
```

停止容器
```bash
docker stop pinn_vlasov_active
```

---

### 在容器内运行仿真脚本

进入容器后，切换到工作目录并运行脚本：
```bash
cd /workspace

# 朗道阻尼 (Landau Damping)
python vlasovEfield.py

# 自由流 (Free Stream)
python vlasovFreeStream.py

# 流体振荡 (Fluid Oscillations)
python fluidOscillations.py

# 边界层 (Boundary Layer)
python boundaryLayer.py
```

---

### GPU 监控与容器管理

```bash
# 实时监控 GPU 状态 (在容器内或宿主机均可)
nvidia-smi

# 持续刷新 GPU 状态 (每2秒)
watch -n 2 nvidia-smi

# 查看所有容器 (包含已停止的)
docker ps -a

# 查看容器内的 TensorFlow / GPU 是否正常
python -c "import tensorflow as tf; print(tf.__version__); print(tf.config.list_physical_devices('GPU'))"
```

---

### ffmpeg 安装 (容器内，首次配置时)

```bash
apt-get update && apt-get install -y ffmpeg
```