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

## sshコンフィグを設定

キーペアを `~/.ssh/キーペア名.pem` に配置します。

```bash
KEY_PAIR_NAME=$(terraform -chdir=$PROJECT_DIR/terraform/components/hybrid-nodes output -raw key_pair_name)
cp ${KEY_PAIR_NAME}.pem ~/.ssh/${KEY_PAIR_NAME}.pem
chmod 600 ~/.ssh/${KEY_PAIR_NAME}.pem
```

`~/.ssh/config` に `tmp/config` の内容を追記

```bash
echo "" >> ~/.ssh/config
cat $PROJECT_DIR/tmp/config >> ~/.ssh/config
cat ~/.ssh/config
```

## ハイブリッドノードセットアップ

```bash
cd $PROJECT_DIR/ansible
TARGET_HOST=hybrid-nodes-sample-dev-node01
STAGE=dev

# -i <インベントリファイル>: インベントリファイルを設定
# -l <対象ホスト名>: デプロイ対象ホスト名を指定
# -v: 詳細なログを表示
# --tags <カンマ区切りのタグ>: playbookのロールに設定したタグ
ansible-playbook -v -i inventory_${STAGE}.yml -l $TARGET_HOST playbook.yml
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

# ■ 動作確認

## netshoot内

k9s で netshoot の shell にログイン

### DNSの確認

```bash
curl "http://google.co.jp"
```

### pingの確認

```bash
# それぞれの netshoot の IP に ping を飛ばせるかを確認
ping 192.168.xxx.xxx
```


### resolve.confの確認

```bash
cat /etc/resolv.conf
# nameserver 172.20.0.10/16
```

### albの疎通確認

```bash
curl "http://hybrid-nodes-sample-dev-httpapp-xxxxxxxxx.ap-northeast-1.elb.amazonaws.com/"
```


# ■ 削除

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
