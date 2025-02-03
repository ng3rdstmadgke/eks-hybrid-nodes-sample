# ノードグループにアプリを立てる

```bash
kubectl apply -f $PROJECT_DIR/service/http-app/namespace.yaml
kubectl apply -f $PROJECT_DIR/service/http-app/app-cloud.yaml
kubectl apply -f $PROJECT_DIR/service/http-app/tmp/ingress-cloud.yaml
```



# ハイブリッドノードにアプリを立てる

```bash
kubectl apply -f $PROJECT_DIR/service/http-app/namespace.yaml
kubectl apply -f $PROJECT_DIR/service/http-app/app-hybrid.yaml
kubectl apply -f $PROJECT_DIR/service/http-app/tmp/ingress-hybrid.yaml
```
