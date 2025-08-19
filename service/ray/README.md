- [RayCluster Quickstart | Ray](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/raycluster-quick-start.html)
- [kuberayのhelmチャート一覧 | GitHub](https://github.com/ray-project/kuberay/tree/master/helm-chart)

# ■ Ray Clusterの構築

## リポジトリ追加

```bash
# リポジトリの追加
helm repo add kuberay https://ray-project.github.io/kuberay-helm/
helm repo update

# インストール可能なチャートの確認
helm search repo  kuberay
# NAME                            CHART VERSION   APP VERSION     DESCRIPTION                                       
# kuberay/kuberay-apiserver       1.4.0                           A Helm chart for kuberay-apiserver                
# kuberay/kuberay-operator        1.4.0                           A Helm chart for deploying the Kuberay operator...
# kuberay/ray-cluster             1.4.0                           A Helm chart for Kubernetes  
```


## KubeRay Operator をインストール


```bash
RAY_OPERATOR_VERSION=1.4.0

# CRDとkuberay-operatorをインストール
helm upgrade -i kuberay-operator kuberay/kuberay-operator \
  --namespace kuberay-operator \
  --create-namespace \
  --version $RAY_OPERATOR_VERSION

# 確認
kubectl get pods -n kuberay-operator
# NAME                                READY   STATUS    RESTARTS   AGE
# kuberay-operator-7fbdbf8c89-pt8bk   1/1     Running   0          27s
```


## RayCluster をインストール

```bash
RAY_PYTHON_VERSION=py312
RAY_CLUSTER_NS=ray-cluster-$RAY_PYTHON_VERSION
RAY_CLUSTER_VERSION=1.4.0

# rayclusterをインストール
# https://github.com/ray-project/kuberay/tree/master/helm-chart/ray-cluster
helm upgrade -i raycluster kuberay/ray-cluster \
  --namespace $RAY_CLUSTER_NS \
  --create-namespace \
  --version $RAY_CLUSTER_VERSION \
  -f $PROJECT_DIR/service/ray/conf/values.yaml

# RayClusterの確認
kubectl get rayclusters -n $RAY_CLUSTER_NS
# NAME                 DESIRED WORKERS   AVAILABLE WORKERS   CPUS   MEMORY   GPUS   STATUS   AGE
# raycluster-kuberay   1                 1                   2      3G       0      ready    90s

# RayClusterのPodを確認
kubectl get pods -n $RAY_CLUSTER_NS --selector=ray.io/cluster=raycluster-kuberay
# NAME                                          READY   STATUS    RESTARTS   AGE
# raycluster-kuberay-head-k775q                 1/1     Running   0          8m46s
# raycluster-kuberay-workergroup-worker-kwlt5   1/1     Running   0          8m46s
```

## NodePortを確認

### RayClusterのヘッドノードのNodePort確認する

RayClusterのHeadノードが公開しているポートとその働き

- **10001(client)**: 外部クライアントが Ray Cluster に接続するためのエントリーポイント
- **8265(dashboard)**: Ray Dashboard のウェブインターフェースにアクセスするためのポート
- **8000(serve)**: Ray Serve を使用してデプロイされたアプリケーションへの HTTP リクエストを受け付けるポート
- **8080(metrics)**: Prometheus などのモニタリングツールが Ray のメトリクスを収集するためのエンドポイント
- **6379(gcs-server)**: Ray の内部コンポーネント間でのメタデータの共有や通信に使用されるポート


```bash
kubectl get svc raycluster-kuberay-head-svc -n $RAY_CLUSTER_NS -o yaml | yq -r '.spec.ports[] | "\(.targetPort)(\(.name)): node_port = \(.nodePort)"'
# 10001(client): node_port = 30268
# 8265(dashboard): node_port = 31254
# 6379(gcs-server): node_port = 32619
# 8080(metrics): node_port = 31259
# 8000(serve): node_port = 32713
```

# ■ 動作確認


## 接続確認


```bash
cd $PROJECT_DIR/service/ray/connection_sample

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_nlb_dns_name)

export RAY_CLIENT_ADDR="ray://${RAY_NLB_HOSTNAME}:10001"
# export RAY_CLIENT_ADDR="ray://ray-hnb-dev.baseport.net:10001"

echo $RAY_CLIENT_ADDR

poetry install

poetry run python job.py
# 2025-05-26 18:00:24,098 INFO client_builder.py:244 -- Passing the following kwargs to ray.init() on the server: log_to_driver
# SIGTERM handler is not set because current thread is not the main thread.
# 2025-05-26 18:00:25,881 WARNING utils.py:1591 -- Python patch version mismatch: The cluster was started with:
#     Ray: 2.41.0
#     Python: 3.12.8
# This process on Ray Client was started with:
#     Ray: 2.41.0
#     Python: 3.12.3
#
# {'CPU': 2.0,
#  'GPU': 2.0,
#  'accelerator_type:T4': 2.0,
#  'memory': 3000000000.0,
#  'node:192.168.171.153': 1.0,
#  'node:192.168.171.154': 1.0,
#  'node:__internal_head__': 1.0,
#  'object_store_memory': 754345574.0}
# [10, 10, 10, 10, 10]
```

# CPUジョブの実行

```bash
cd $PROJECT_DIR/service/ray/cpu_sample

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_nlb_dns_name)

export RAY_CLIENT_ADDR="ray://${RAY_NLB_HOSTNAME}:10001"
# export RAY_CLIENT_ADDR="ray://ray-hnb-dev.baseport.net:10001"

echo $RAY_CLIENT_ADDR

poetry install

poetry run python job.py
# 2025-06-17 14:47:53,558 INFO client_builder.py:244 -- Passing the following kwargs to ray.init() on the server: log_to_driver
# SIGTERM handler is not set because current thread is not the main thread.
# 2025-06-17 14:47:56,781 WARNING utils.py:1591 -- Python patch version mismatch: The cluster was started with:
#     Ray: 2.41.0
#     Python: 3.12.8
# This process on Ray Client was started with:
#     Ray: 2.41.0
#     Python: 3.12.3
# 
# Progress: 0%
# Progress: 1%
# Progress: 5%
# Progress: 10%
# ...
# Progress: 100%
# Estimated value of π is: 3.14196016
```

# GPUジョブの実行

```bash
cd $PROJECT_DIR/service/ray/gpu_sample

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_nlb_dns_name)

export RAY_CLIENT_ADDR="ray://${RAY_NLB_HOSTNAME}:10001"
# export RAY_CLIENT_ADDR="ray://ray-hnb-dev.baseport.net:10001"

echo $RAY_CLIENT_ADDR

poetry install

poetry run python job.py
# 2025-06-17 14:52:16,196 INFO client_builder.py:244 -- Passing the following kwargs to ray.init() on the server: log_to_driver
# SIGTERM handler is not set because current thread is not the main thread.
# 2025-06-17 14:52:22,307 WARNING utils.py:1591 -- Python patch version mismatch: The cluster was started with:
#     Ray: 2.41.0
#     Python: 3.12.8
# This process on Ray Client was started with:
#     Ray: 2.41.0
#     Python: 3.12.3
# 
# Multiplication of 20480x20480 matrices took 3.3994 seconds on GPU
# Multiplication of 20480x20480 matrices took 4.6124 seconds on GPU
```