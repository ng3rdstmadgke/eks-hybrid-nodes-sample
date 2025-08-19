# デプロイ

```bash
kubectl apply -f $PROJECT_DIR/service/ollama/namespace.yaml

# ollamaのデプロイ
kubectl apply -f $PROJECT_DIR/service/ollama/ollama.yaml
```


# 動作確認


ollamaサーバーのポートフォワーディング

```bash
kubectl port-forward -n ollama service/ollama-svc 80
```

ヘルスチェック

```bash
BASE_URL=http://localhost
#BASE_URL=https://ollama.hnb-dev.baseport.net

curl "$BASE_URL/api/version"
# {"version":"0.11.3"}
```

現在稼働中のモデルを確認

```bash
BASE_URL=http://localhost
#BASE_URL=https://ollama.hnb-dev.baseport.net

curl "$BASE_URL/api/ps" | jq "."
# {
#   "models": [
#     {
#       "name": "deepseek-r1:14b-qwen-distill-q4_K_M",
#       "model": "deepseek-r1:14b-qwen-distill-q4_K_M",
#       "size": 10384885760,
#       "digest": "c333b7232bdb521236694ffbb5f5a6b11cc45d98e9142c73123b670fca400b09",
#       "details": {
#         "parent_model": "",
#         "format": "gguf",
#         "family": "qwen2",
#         "families": [
#           "qwen2"
#         ],
#         "parameter_size": "14.8B",
#         "quantization_level": "Q4_K_M"
#       },
#       "expires_at": "2317-11-29T13:13:34.241254993Z",
#       "size_vram": 10384885760,
#       "context_length": 4096
#     }
#   ]
# }
```


問い合わせ

```bash
MODEL_NAME=deepseek-r1:14b-qwen-distill-q4_K_M
BASE_URL=http://localhost
#BASE_URL=https://ollama.hnb-dev.baseport.net

curl "$BASE_URL/api/generate" \
  -X POST \
  -d "{
  \"model\": \"$MODEL_NAME\",
  \"prompt\":\"AIによって私たちの暮らしはどのように変わりますか?\",
  \"stream\": true
}"
# {"model":"deepseek-r1:14b-qwen-distill-q4_K_M","created_at":"2025-08-19T13:55:48.7529183Z","response":"\u003cthink\u003e","done":false}
# {"model":"deepseek-r1:14b-qwen-distill-q4_K_M","created_at":"2025-08-19T13:55:48.807918377Z","response":"\n\n","done":false}
# {"model":"deepseek-r1:14b-qwen-distill-q4_K_M","created_at":"2025-08-19T13:55:48.86355734Z","response":"\u003c/think\u003e","done":false}
# {"model":"deepseek-r1:14b-qwen-distill-q4_K_M","created_at":"2025-08-19T13:55:48.920929462Z","response":"\n\n","done":false}
# {"model":"deepseek-r1:14b-qwen-distill-q4_K_M","created_at":"2025-08-19T13:55:48.977829092Z","response":"AI","done":false}
# {"model":"deepseek-r1:14b-qwen-distill-q4_K_M","created_at":"2025-08-19T13:55:49.033611772Z","response":"（","done":false}
# ...
```


# 削除

```bash
kubectl delete -f $PROJECT_DIR/service/ollama/ollama.yaml
kubectl delete -f $PROJECT_DIR/service/ollama/namespace.yaml
```