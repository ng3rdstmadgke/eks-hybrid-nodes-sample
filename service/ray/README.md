- [RayCluster Quickstart | Ray](https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/raycluster-quick-start.html)
- [kuberayのhelmチャート一覧 | GitHub](https://github.com/ray-project/kuberay/tree/master/helm-chart)

# 環境変数定義

```bash
export STAGE=dev
```

# Ray Clusterの構築

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

## LBを構築する

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

### varsファイルを作成

`terraform/components/load-balancer/tfvars/$STAGE.tfvars`

```ini
# NOTE: RayClusterのNLBのターゲットIP(ハイブリッドノードのIP)
ray_nlb_target_ips = [
  "10.90.1.121",
  "10.90.2.253",
  "10.90.3.180",
]

# NOTE: RayClusterのNLBの各ターゲットのポート
#       lb_port: NLBが受けるポート (任意)
#       node_port: ターゲットが受けるポート (RayClusterのヘッドノードのNodePortを指定)
ray_nlb_port_map = {
  py312-client    = {lb_port = 10001, node_port = 30898},
  py312-dashboard = {lb_port = 10002, node_port = 32175},
}

```

### LBコンポーネントのデプロイ

```bash
make tf-plan STAGE=$STAGE COMPONENT=load-balancer
make tf-apply STAGE=$STAGE COMPONENT=load-balancer
```


# Rayジョブをヘッドポッドで実行する


```bash
export HEAD_POD=$(kubectl get pods -n $RAY_CLUSTER_NS --selector=ray.io/node-type=head -o custom-columns=POD:metadata.name --no-headers)
echo $HEAD_POD
# raycluster-kuberay-head-k775q

kubectl exec -it $HEAD_POD -n $RAY_CLUSTER_NS -- python -c "import ray; ray.init(); print(ray.cluster_resources())"
# 2025-03-25 00:58:21,490 INFO worker.py:1514 -- Using address 127.0.0.1:6379 set in the environment variable RAY_ADDRESS
# 2025-03-25 00:58:21,491 INFO worker.py:1654 -- Connecting to existing Ray cluster at address: 192.168.205.131:6379...
# 2025-03-25 00:58:21,507 INFO worker.py:1832 -- Connected to Ray cluster. View the dashboard at 192.168.205.131:8265 
# {'node:__internal_head__': 1.0, 'memory': 3000000000.0, 'CPU': 2.0, 'object_store_memory': 781970227.0, 'node:192.168.205.131': 1.0, 'node:192.168.205.132': 1.0}
```

# rayジョブ submission SDKを利用してRayClusterにRayジョブを投げ込む

```bash
cd $PROJECT_DIR/service/ray/connection_sample

# poetry init
# poetry add ray[default]==2.41.0
# poetry self add poetry-plugin-shell
poetry install

# https://github.com/python-poetry/poetry-plugin-shell
poetry self add poetry-plugin-shell
poetry shell

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_cluster_nlb_dns_name)
RAY_NLB_DASHBOARD_PORT=10002
echo "$RAY_NLB_HOSTNAME:$RAY_NLB_DASHBOARD_PORT"

ray job submit --address http://$RAY_NLB_HOSTNAME:$RAY_NLB_DASHBOARD_PORT -- python -c "import ray; ray.init(); print(ray.cluster_resources())"
# Job submission server address: http://localhost:8265
#
# -------------------------------------------------------
# Job 'raysubmit_jCswZ6CAYfYWbtYK' submitted successfully
# -------------------------------------------------------
#
# Next steps
#   Query the logs of the job:
#     ray job logs raysubmit_jCswZ6CAYfYWbtYK
#   Query the status of the job:
#     ray job status raysubmit_jCswZ6CAYfYWbtYK
#   Request the job to be stopped:
#     ray job stop raysubmit_jCswZ6CAYfYWbtYK
#
# Tailing logs until the job exits (disable with --no-wait):
# 2025-03-25 02:08:29,952 INFO job_manager.py:530 -- Runtime env is setting up.
# 2025-03-25 02:08:31,368 INFO worker.py:1514 -- Using address 192.168.205.131:6379 set in the environment variable RAY_ADDRESS
# 2025-03-25 02:08:31,368 INFO worker.py:1654 -- Connecting to existing Ray cluster at address: 192.168.205.131:6379...
# 2025-03-25 02:08:31,381 INFO worker.py:1832 -- Connected to Ray cluster. View the dashboard at 192.168.205.131:8265 
# {'CPU': 2.0, 'memory': 3000000000.0, 'node:192.168.205.131': 1.0, 'object_store_memory': 781970227.0, 'node:__internal_head__': 1.0, 'node:192.168.205.132': 1.0}
#
# ------------------------------------------
# Job 'raysubmit_jCswZ6CAYfYWbtYK' succeeded
# ------------------------------------------

exit
```


# スクリプトから実行


```bash
cd $PROJECT_DIR/service/ray/connection_sample

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_cluster_nlb_dns_name)
RAY_NLB_CLIENT_PORT=10001

export RAY_CLIENT_ADDR="ray://${RAY_NLB_HOSTNAME}:${RAY_NLB_CLIENT_PORT}"
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

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_cluster_nlb_dns_name)
RAY_NLB_CLIENT_PORT=10001
export RAY_CLIENT_ADDR="ray://${RAY_NLB_HOSTNAME}:${RAY_NLB_CLIENT_PORT}"
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

RAY_NLB_HOSTNAME=$(cd $PROJECT_DIR/terraform/components/load-balancer/; terraform output -raw ray_cluster_nlb_dns_name)
RAY_NLB_CLIENT_PORT=10001
export RAY_CLIENT_ADDR="ray://${RAY_NLB_HOSTNAME}:${RAY_NLB_CLIENT_PORT}"
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