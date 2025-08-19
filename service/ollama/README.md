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
curl "http://localhost/api/version"
# {"version":"0.11.3"}
```

現在稼働中のモデルを確認

```bash
curl "http://localhost/api/ps" | jq "."
# {
#   "models": [
#     {
#       "name": "gpt-oss:120b",
#       "model": "gpt-oss:120b",
#       "size": 75507452160,
#       "digest": "f7f8e2f8f4e087e0e6791636dfe1a28d701d548dada674d12ef0d85ccb02a2a4",
#       "details": {
#         "parent_model": "",
#         "format": "gguf",
#         "family": "gptoss",
#         "families": [
#           "gptoss"
#         ],
#         "parameter_size": "116.8B",
#         "quantization_level": "MXFP4"
#       },
#       "expires_at": "2317-11-23T07:57:35.97001344Z",
#       "size_vram": 75507452160,
#       "context_length": 8192
#     }
#   ]
# }
```


問い合わせ

```bash
MODEL_NAME=deepseek-r1:14b-qwen-distill-q4_K_M
curl http://localhost/api/generate \
  -X POST \
  -d "{
  \"model\": \"$MODEL_NAME\",
  \"prompt\":\"AIによって私たちの暮らしはどのように変わりますか?\",
  \"stream\": true
}"
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:24.669475132Z","response":"AI","done":false}
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:26.4592643Z","response":"が","done":false}
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:26.86148744Z","response":"私","done":false}
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:27.259222378Z","response":"たちの","done":false}
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:28.253266709Z","response":"生活","done":false}
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:28.55763457Z","response":"を","done":false}
# {"model":"llama3.1:8b-instruct-q5_K_M","created_at":"2025-07-22T13:15:28.953370778Z","response":"ど","done":false}
# ...
```


# 削除

```bash
kubectl delete -f $PROJECT_DIR/service/ollama/ollama.yaml
kubectl delete -f $PROJECT_DIR/service/ollama/namespace.yaml
```