ハイブリッドノード追加ガイド
---

# ■ hybrid_nodesコンポーネントのデプロイ

## hybrid_nodesコンポーネントのtfvarsファイルの編集

`$PROJECT_DIR/terraform/components/hybrid_nodes/tfvars/dev.tfvars`

```ini:tfvars
# ハイブリッドノードにsshするためのキーペアを指定
key_pair_name = "beex-midorikawa"
```

## hybrid_nodesコンポーネントのデプロイ


```bash
make tf-plan STAGE=dev COMPONENT=hybrid-nodes
make tf-apply STAGE=dev COMPONENT=hybrid-nodes
```


# ■ オンプレノードの設定

## 秘密鍵を `~/.ssh/` 配下に配置

tfvarsファイルで指定したキーペアの秘密鍵を `~/.ssh/キーペア名.pem` に配置し、permissionを `600` に設定します。

```bash
chmod 600 ~/.ssh/キーペア名.pem
```

## `~/.ssh/config` に設定を追記

hybrid-nodes コンポーネントの terraformを実行すると `tmp/config` に ssh の設定ファイルが出力されます。

```bash
cat $PROJECT_DIR/tmp/config
# Host hybrid-nodes-sample-dev-node01
#   HostName 10.90.1.52
#   User ubuntu
#   IdentityFile ~/.ssh/xxxxxxxxxxxxxxx.pem
# Host hybrid-nodes-sample-dev-node02
#   HostName 10.90.2.161
#   User ubuntu
#   IdentityFile ~/.ssh/xxxxxxxxxxxxxxx.pem
# Host hybrid-nodes-sample-dev-node03
#   HostName 10.90.3.111
#   User ubuntu
#   IdentityFile ~/.ssh/xxxxxxxxxxxxxxx.pem
```

内容を `~/.ssh/config` に追記します。

```bash
vim ~/.ssh/config
```

# ■ オンプレノードのプロビジョニング

## ansible実行

```bash
cd $PROJECT_DIR/ansible
CLUSTER_NAME=$(terraform -chdir=$PROJECT_DIR/terraform/components/base output -raw cluster_name)

# -i <インベントリファイル>: インベントリファイルを設定
# -l <対象ホスト名>: デプロイ対象ホスト名を指定
# -v: 詳細なログを表示
# --tags <カンマ区切りのタグ>: playbookのロールに設定したタグ

# g4dn (nvidia gpu) ノード
ansible-playbook -v -i inventory_dev.yml -l $CLUSTER_NAME-node01 --tags gpu playbook.yml

# g4dn (nvidia gpu) ノード
ansible-playbook -v -i inventory_dev.yml -l $CLUSTER_NAME-node02 --tags gpu playbook.yml

# t3 (gpuなし) ノード
ansible-playbook -v -i inventory_dev.yml -l $CLUSTER_NAME-node03 --tags standard playbook.yml
```

GPUノードにラベルを設定

```bash
# ノードを確認
hybrid-nodes dev
# 10.90.1.121 hybrid-nodes-sample-dev-node01 mi-01d36f0fe6a21b30a
# 10.90.2.253 hybrid-nodes-sample-dev-node02 mi-048e5dab057d86c35
# 10.90.3.180 hybrid-nodes-sample-dev-node03 mi-0e29a10bbce6dd90f

kubectl label nodes mi-01d36f0fe6a21b30a nvidia.com/gpu.present=true
kubectl label nodes mi-0e29a10bbce6dd90f nvidia.com/gpu.present=true
```


# ■ 動作確認

## ネットワーク動作確認

[README.md - netshoot](../service/netshoot/README.md)


## NVIDIA GPU の動作確認

[README.md - nvidia](../plugin/nvidia-device-plugin/README.md)