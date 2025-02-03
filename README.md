# デプロイ

## ベースコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=base
make tf-apply STAGE=dev COMPONENT=base
```

## ネットワークコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=network
make tf-apply STAGE=dev COMPONENT=network
```

ルートテーブルにVPCピアリングの設定を手動でいれる


## クラスタコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=cluster
make tf-apply STAGE=dev COMPONENT=cluster

CLUSTER_NAME=$(terraform -chdir=$PROJECT_DIR/terraform/components/base output -raw cluster_name)
aws eks update-kubeconfig --name $CLUSTER_NAME
```

## ノードグループコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=node-group
make tf-apply STAGE=dev COMPONENT=node-group
```


## アドオンコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=addon
make tf-apply STAGE=dev COMPONENT=addon
```

## プラグインコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=plugin
make tf-apply STAGE=dev COMPONENT=plugin
```

### albcインストール

[README.md | albc](plugin/albc/README.md)


## ハイブリッドノードコンポーネント

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
```

### ハイブリッドアクティベーション作成

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

# {
#     "ActivationId": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
#     "ActivationCode": "XXXXXXXXXXXXXXXXXXXX"
# }
```

### ハイブリッドノードセットアップ

nodeadmインストール


```bash
curl -OL 'https://hybrid-assets.eks.amazonaws.com/releases/latest/bin/linux/amd64/nodeadm'
sudo mv nodeadm /usr/local/bin/
sudo chmod 755 /usr/local/bin/nodeadm
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
sudo apt update && sudo apt upgrade -y

CLUSTER_VERSION=1.31
sudo nodeadm install $CLUSTER_VERSION --credential-provider ssm

sudo nodeadm init -c file://nodeConfig.yaml

sudo nodeadm debug -c file://nodeConfig.yaml
```


## サービスコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=service
make tf-apply STAGE=dev COMPONENT=service
```