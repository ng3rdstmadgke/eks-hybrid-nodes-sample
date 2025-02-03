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


## サービスコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=service
make tf-apply STAGE=dev COMPONENT=service
```