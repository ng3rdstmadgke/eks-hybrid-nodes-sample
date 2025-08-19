デプロイガイド
---

# ■ EKSクラスタ構築

## base コンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=base
make tf-apply STAGE=dev COMPONENT=base
```

## network コンポーネント

`$PROJECT_DIR/terraform/components/network/tfvars/dev.tfvars`

```ini:tfvars
transit_gateway_id = "tgw-xxxxxxxxxxxxxxxxx"
```

```bash
make tf-plan STAGE=dev COMPONENT=network
make tf-apply STAGE=dev COMPONENT=network
```

## cluster コンポーネント

`$PROJECT_DIR/terraform/components/cluster/tfvars/dev.tfvars`

```ini:tfvars
# IAMアクセスエントリで管理者として登録するユーザーを登録
access_entries = [
  "arn:aws:iam::674582907715:user/keita.midorikawa"
]
```

```bash
make tf-plan STAGE=dev COMPONENT=cluster
make tf-apply STAGE=dev COMPONENT=cluster

CLUSTER_NAME=$(terraform -chdir=$PROJECT_DIR/terraform/components/base output -raw cluster_name)
aws eks update-kubeconfig --name $CLUSTER_NAME
```

### calicoインストール

[calico インストール](../plugin/calico/README.md)


## node-group コンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=node-group
make tf-apply STAGE=dev COMPONENT=node-group
```


## addon コンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=addon
make tf-apply STAGE=dev COMPONENT=addon
```

## plugin コンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=plugin
make tf-apply STAGE=dev COMPONENT=plugin
```

### nvidia-device-pluginインストール

[nvidia k8s-device-plugin インストール](../plugin/nvidia/README.md)

# ■ ハイブリッドノードの追加

[ハイブリッドノード追加ガイド](./append_hybrid_node_guide.md)


# ■ サービスのデプロイ

## service コンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=service
make tf-apply STAGE=dev COMPONENT=service
```

- [ray](../service/ray/README.md)
- [ollama](../service/ollama/README.md)

## load-balancer コンポーネント

### 共通ALBのためのACMを作成

- ドメイン: `*.hnb-dev.baseport.net`

### terraformのデプロイ

`$PROJECT_DIR/terraform/components/load-balancer/tfvars/dev.tfvars`

```ini:tfvars
# RayクライアントのNLBの設定
ray_nlb_port_map = {
  py312-client    = {lb_port = 10001, node_port = 30919},
}

alb_certificate_arn = "arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# HTTPS用のALBの設定
alb_targets = {
  ray-py312-dashboard = {
    ips               = [
      "10.90.1.52",
      "10.90.2.161",
      "10.90.3.111",
    ]
    port              = 31373,
    domain            = "ray-py312.hnb-dev.baseport.net",
    health_check_path = "/api/version",
  },
  ollama = {
    ips               = [
      "10.90.1.52",
      "10.90.2.161",
      "10.90.3.111",
    ]
    port              = 30001,
    domain            = "ollama.hnb-dev.baseport.net",
    health_check_path = "/api/version",
  },
}
```

```bash
make tf-plan STAGE=dev COMPONENT=load-balancer
make tf-apply STAGE=dev COMPONENT=load-balancer
```

### Route53にレコードを登録

terraformで作成したnlbとalbをDNSに登録します。

- Ray NLB
  - レコード名: `ray-hnb-dev.baseport.net`
  - タイプ: `CNAME`
  - 値: `terraform の output (ray_nlb_dns_name)`
- Common ALB
  - レコード名: `*.hnb-dev.baseport.net`
  - タイプ: `CNAME`
  - 値: `terraform の output (common_alb_dns_name)`

### LBの疎通確認

- Rayクライアント
  - `ray://ray-hnb-dev.baseport.net:10001`
- Rayダッシュボード
  - `https://ray-py312.hnb-dev.baseport.net`
- Ollama
  - `https://ollama.hnb-dev.baseport.net`


### 動作確認


- [ray](../service/ray/README.md)
- [ollama](../service/ollama/README.md)



# ■ ハイブリッドノードの削除

- [ハイブリッドノード削除ガイド](./delete_hybrid_node_guide.md)



# ■ クラスタの削除

```bash
make tf-destroy STAGE=dev COMPONENT=load-balancer && \
make tf-destroy STAGE=dev COMPONENT=service && \
make tf-destroy STAGE=dev COMPONENT=hybrid-nodes && \
make tf-destroy STAGE=dev COMPONENT=plugin && \
make tf-destroy STAGE=dev COMPONENT=addon && \
make tf-destroy STAGE=dev COMPONENT=node-group && \
make tf-destroy STAGE=dev COMPONENT=cluster && \
make tf-destroy STAGE=dev COMPONENT=network && \
make tf-destroy STAGE=dev COMPONENT=base
```
