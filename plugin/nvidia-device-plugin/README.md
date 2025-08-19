# nvidia k8s-device-plugin インストール

[NVIDIA/k8s-device-plugin | GitHub](https://github.com/NVIDIA/k8s-device-plugin)

## Helmリポジトリの追加と更新

```bash
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update

helm search repo nvdp
# NAME                            CHART VERSION   APP VERSION     DESCRIPTION
# nvdp/gpu-feature-discovery      0.17.1          0.17.1          A Helm chart for gpu-feature-discovery on Kuber...
# nvdp/nvidia-device-plugin       0.17.1          0.17.1          A Helm chart for the nvidia-device-plugin on Ku...

CHART_VERSION=0.17.1

helm upgrade -i nvdp nvdp/nvidia-device-plugin \
  --namespace nvidia-device-plugin \
  --create-namespace \
  --version $CHART_VERSION \
  -f $PROJECT_DIR/plugin/nvidia-device-plugin/conf/values.yaml
```



# 動作確認

affinity の values をデプロイ対象のノード名に変更

```bash
kubectl apply -f $PROJECT_DIR/plugin/nvidia-device-plugin/sample/app.yaml

kubectl get po -l app=gpu-test
# NAME                       READY   STATUS    RESTARTS   AGE
# gpu-test-85d677cc8-hvllc   1/1     Running   0          6m36s

kubectl logs deployment/gpu-test
# 
# ==========
# == CUDA ==
# ==========
# 
# CUDA Version 12.8.1
# 
# Container image Copyright (c) 2016-2023, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# 
# This container image and its contents are governed by the NVIDIA Deep Learning Container License.
# By pulling and using the container, you accept the terms and conditions of this license:
# https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license
# 
# A copy of this license is made available in this container at /NGC-DL-CONTAINER-LICENSE for your convenience.
# 
# Tue Aug 19 12:42:38 2025       
# +-----------------------------------------------------------------------------------------+
# | NVIDIA-SMI 580.65.06              Driver Version: 580.65.06      CUDA Version: 13.0     |
# +-----------------------------------------+------------------------+----------------------+
# | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
# | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
# |                                         |                        |               MIG M. |
# |=========================================+========================+======================|
# |   0  Tesla T4                       Off |   00000000:00:1E.0 Off |                    0 |
# | N/A   28C    P8             14W /   70W |       0MiB /  15360MiB |      0%      Default |
# |                                         |                        |                  N/A |
# +-----------------------------------------+------------------------+----------------------+
# 
# +-----------------------------------------------------------------------------------------+
# | Processes:                                                                              |
# |  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
# |        ID   ID                                                               Usage      |
# |=========================================================================================|
# |  No running processes found                                                             |
# +-----------------------------------------------------------------------------------------+

kubectl delete -f $PROJECT_DIR/plugin/nvidia-device-plugin/sample/app.yaml
```