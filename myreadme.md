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

### 🚀 启动开发环境
在 Windows PowerShell 中执行以下指令，挂载代码目录并启用 GPU 支持：
```bash
docker run --gpus all --shm-size=1g -v E:\PINNvlasov:/workspace --name pinn_vlasov_active -it nvcr.io/nvidia/tensorflow:22.12-tf1-py3