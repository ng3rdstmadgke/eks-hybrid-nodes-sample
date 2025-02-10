# ノードグループにアプリを立てる

```bash
kubectl apply -f $PROJECT_DIR/service/http-app/namespace.yaml
kubectl apply -f $PROJECT_DIR/service/http-app/app-cloud.yaml
```

削除

```bash
kubectl delete -f $PROJECT_DIR/service/http-app/app-cloud.yaml
```



# ハイブリッドノードにアプリを立てる

```bash
kubectl apply -f $PROJECT_DIR/service/http-app/namespace.yaml
kubectl apply -f $PROJECT_DIR/service/http-app/app-hybrid.yaml
```

削除

```bash
kubectl delete -f $PROJECT_DIR/service/http-app/app-hybrid.yaml
```
