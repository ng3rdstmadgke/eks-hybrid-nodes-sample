- [projectcalico/calico | GitHub](https://github.com/projectcalico/calico/tree/v3.29.4)
  - [charts/tigera-operator/values.yaml](https://github.com/projectcalico/calico/blob/v3.29.0/charts/tigera-operator/values.yaml)
- [About Calico - TIGERA ](https://docs.tigera.io/calico/3.29/about/)
  - [Installing on Amazon EKS](https://docs.tigera.io/calico/3.29/getting-started/kubernetes/managed-public-cloud/eks)
  - [Helm installation reference](https://docs.tigera.io/calico/3.29/reference/installation/helm_customization)
- [ハイブリッドノードに Calico をインストールする | AWS](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/hybrid-nodes-cni.html#_calico_considerations)  
  - [CNI のバージョン互換性 | AWS](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/hybrid-nodes-cni.html#_cni_version_compatibility)  
    EKS Hybrid Nodes でサポートされる Calico のバージョンは `v3.29.x`  


# Calicoインストール

https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/eks

```bash
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update projectcalico

# インストール可能なチャートのバージョンをチェック
helm search repo projectcalico --versions | grep -F -e "v3.29." -e "NAME" | head -n3
# NAME                            CHART VERSION   APP VERSION     DESCRIPTION                            
# projectcalico/tigera-operator   v3.29.4         v3.29.4         Installs the Tigera operator for Calico
# projectcalico/tigera-operator   v3.29.3         v3.29.3         Installs the Tigera operator for Calico

CALICO_VERSION=3.29.4

helm upgrade -i calico projectcalico/tigera-operator \
    --version $CALICO_VERSION \
    --namespace kube-system \
    -f $PROJECT_DIR/plugin/calico/conf/values.yaml
```