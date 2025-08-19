import ray
import numpy as np
import time
import os

# Ray Cluster に接続
address = os.getenv("RAY_CLIENT_ADDR")  # 例: "ray://raycluster-kuberay-head-svc:10001"
ray.init(address=address, runtime_env={"pip": ["cupy-cuda12x"]})

@ray.remote(num_cpus=2, num_gpus=1, memory=4 * 1024 * 1024 * 1024)  # 2 CPU, 1 GPU, 4GB メモリ
def gpu_matrix_multiply(size):
    import cupy as cp  # GPU 上の NumPy 相当ライブラリ（CUDA が必要）

    # 行列を生成
    a = cp.random.rand(size, size).astype(cp.float32)
    b = cp.random.rand(size, size).astype(cp.float32)

    # 行列積
    start = time.time()
    c = cp.dot(a, b)
    cp.cuda.Device(0).synchronize()  # GPU の非同期実行を待つ
    end = time.time()

    return f"Multiplication of {size}x{size} matrices took {end - start:.4f} seconds on GPU"

# 並列で複数ジョブを起動
futures = [gpu_matrix_multiply.remote(20480) for _ in range(2)]
results = ray.get(futures)

for result in results:
    print(result)