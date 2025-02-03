```bash
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update

helm upgrade --install calico projectcalico/tigera-operator \
  --version "3.29.1" \
  --namespace kube-system \
  -f $PROJECT_DIR/plugin/calico/tmp/values.yaml
```