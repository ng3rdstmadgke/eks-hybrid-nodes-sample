# ■ ベースコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=base
make tf-apply STAGE=dev COMPONENT=base
```

# ■ ネットワークコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=network
make tf-apply STAGE=dev COMPONENT=network
```

# ■ クラスタコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=cluster
make tf-apply STAGE=dev COMPONENT=cluster

CLUSTER_NAME=$(terraform -chdir=$PROJECT_DIR/terraform/components/base output -raw cluster_name)
aws eks update-kubeconfig --name $CLUSTER_NAME
```

## calicoインストール

https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/eks

```bash
# クラスタネットワークにCalicoを利用するには aws-node DaemonSet を削除しなければならない
kubectl delete daemonset -n kube-system aws-node

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/calico-vxlan.yaml

# AWSインスタンスの通信元/通信先チェックを無効化する
# https://docs.tigera.io/calico/latest/reference/resources/felixconfig#aws-integration
kubectl -n kube-system set env daemonset/calico-node FELIX_AWSSRCDSTCHECK=DoNothing
```

# ■ ノードグループコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=node-group
make tf-apply STAGE=dev COMPONENT=node-group
```


# ■ アドオンコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=addon
make tf-apply STAGE=dev COMPONENT=addon
```

# ■ プラグインコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=plugin
make tf-apply STAGE=dev COMPONENT=plugin
```


# ■ ハイブリッドノードコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=hybrid-nodes
make tf-apply STAGE=dev COMPONENT=hybrid-nodes
```

`~/.ssh/config`

```~/.ssh/config
Host beex-hybrid-node-01
  HostName 10.53.11.120
  User ubuntu
  IdentityFile ~/.ssh/beex-midorikawa.pem

Host beex-hybrid-node-02
  HostName 10.53.11.120
  User ubuntu
  IdentityFile ~/.ssh/beex-midorikawa.pem
```

## ハイブリッドアクティベーション作成

```bash
CLUSTER_ARN=$(terraform -chdir=$PROJECT_DIR/terraform/components/cluster output -raw cluster_arn)
HYBRID_NODE_ROLE_ARN=$(terraform -chdir=$PROJECT_DIR/terraform/components/hybrid-nodes output -raw hybrid_node_role)

aws ssm create-activation \
     --region ap-northeast-1 \
     --default-instance-name eks-hybrid-nodes \
     --description "Activation for EKS hybrid nodes" \
     --iam-role $HYBRID_NODE_ROLE_ARN \
     --tags Key=EKSClusterARN,Value=$CLUSTER_ARN \
     --registration-limit 1

# ■ {
# ■     "ActivationId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
# ■     "ActivationCode": "XXXXXXXXXXXXXXXXXXXX"
# ■ }
```

## ハイブリッドノードセットアップ

OSセットアップ

```bash
sudo su -

# ■ パッケージアップデート
apt update && apt upgrade -y

# ■ IPフォワーディング
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p  # 適用
sysctl -a  # 確認
```

nodeadmインストール


```bash
curl -OL 'https://hybrid-assets.eks.amazonaws.com/releases/latest/bin/linux/amd64/nodeadm'
mv nodeadm /usr/local/bin/
chmod 755 /usr/local/bin/nodeadm
```

設定ファイル作成

```bash
CLUSTER_NAME=hybrid-nodes-sample-dev
ACTIVATION_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
ACTIVATION_CODE=XXXXXXXXXXXXXXXXXXXX

cat <<EOF > nodeConfig.yaml
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: $CLUSTER_NAME
    region: ap-northeast-1
  hybrid:
    ssm:
      activationId: "$ACTIVATION_ID"
      activationCode: "$ACTIVATION_CODE"
EOF
```

初期化

```bash
CLUSTER_VERSION=1.31
sudo nodeadm install $CLUSTER_VERSION --credential-provider ssm

sudo nodeadm init -c file://nodeConfig.yaml

sudo nodeadm debug -c file://nodeConfig.yaml
```

# ■ サービスコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=service
make tf-apply STAGE=dev COMPONENT=service
```

- [http-app](./service/http-app/README.md)
- [netshoot](./service/netshoot/README.md)

# ■ ロードバランサーコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=load-balancer
make tf-apply STAGE=dev COMPONENT=load-balancer
```