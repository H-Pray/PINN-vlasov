# 1D Vlasov-Poisson PINN 研究项目

本项目利用物理信息神经网络 (PINN) 求解一维 Vlasov-Poisson 系统，模拟等离子体中的经典物理现象：朗道阻尼 (Landau Damping)。

## 环境概览
环境采用了 Docker的环境，以确保旧版框架在现代硬件上的兼容性。

* 核心框架: TensorFlow 1.14.0 (GPU 版本)
* 硬件: NVIDIA RTX 4060/Intel i5-12400F
* 基础镜像: nvcr.io/nvidia/tensorflow:19.07-py3
* 封装镜像: pinn_vlasov_env:latest (已固化所有环境配置)

---

## 环境配置记录

### 1. 关键依赖版本
为解决 TensorFlow 1.14 与现代环境的冲突，已修正以下版本：
* Protobuf: 3.19.6 (解决描述符创建报错)
* pyDOE: 0.3.8 (用于拉丁超立方采样)
* FFmpeg: 已在容器内安装，用于合成 .mp4 视频

### 2. GPU 性能优化设置
针对 RTX 40 系列显卡的特殊优化：
* 环境变量: 设置 TF_CUDNN_USE_AUTOTUNE=0。跳过 cuDNN 算法寻优，将启动耗时从数分钟缩短至秒级。
* 显存管理: 开启 gpu_options.allow_growth = True，实现显存按需分配，防止系统卡死。

---

## 物理模拟参数
在 vlasovEfield.py 中，可以通过修改以下参数调节模拟：

* t_max: 调节物理模拟的总时长。观察兰道阻尼建议设为 10.0 以上。
* alpha: 初始扰动强度。
* maxiter: L-BFGS 优化器的迭代步数。
* ftol: 停止精度阈值。

---

## 产出物说明
训练完成后，项目会自动在根目录生成以下视频：
1. vlasov1D.mp4: 相空间演化图。展示电子分布函数 f 形成“相空间漩涡”的过程。
2. vlasov1D_Efield.mp4: 电场强度随时间的演化。用于验证电场振幅的指数级衰减。
3. vlasov1D_n_e_field.mp4: 电子密度波动图。展示电荷守恒与空间分布变化。

---

## 快速启动命令 (启动Docker环境)
在 Windows PowerShell 或用终端执行：
```bash
docker run --gpus all `
  --shm-size=1g `
  -v E:\PINNvlasov:/workspace `
  --name pinn_vlasov_active `
  -it nvcr.io/nvidia/tensorflow:22.12-tf1-py3