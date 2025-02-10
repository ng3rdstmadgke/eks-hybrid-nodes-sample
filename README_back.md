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

## albcインストール

[README.md | albc](plugin/albc/README.md)


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

# ■ ハイブリッドルーターコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=hybrid-router
make tf-apply STAGE=dev COMPONENT=hybrid-router
```
## ssh設定

```config
Host beex-eks-network-router
  HostName 10.80.1.141
  User ubuntu
  IdentityFile ~/.ssh/beex-midorikawa.pem

Host beex-remote-network-router
  HostName 10.53.11.208
  User ubuntu
  IdentityFile ~/.ssh/beex-midorikawa.pem
```

## EKSネットワーク側のルーター
### ホストの設定

```bash
ssh beex-eks-network-router
```

```bash
sudo su -

# IPフォワーディング
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# vxlan作成
REMOTE_IP=10.53.11.208
ip link add vxlan0 type vxlan id 100 dev ens5 remote $REMOTE_IP dstport 4789
ip addr add 172.30.0.1/16 dev vxlan0
ip link set vxlan0 up

# ルーティング設定
CALICO_NETWORK_IP_POOL=172.30.93.0/24
REMOTE_NETWORK_ROUTER_HOST=172.30.0.2
ip route add $CALICO_NETWORK_IP_POOL via $REMOTE_NETWORK_ROUTER_HOST dev vxlan0

# 確認
ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
#     inet6 ::1/128 scope host noprefixroute
#        valid_lft forever preferred_lft forever
# 2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
#     link/ether 06:4e:d3:cd:a7:03 brd ff:ff:ff:ff:ff:ff
#     altname enp0s5
#     inet 10.80.1.141/24 metric 100 brd 10.80.1.255 scope global dynamic ens5
#        valid_lft 2095sec preferred_lft 2095sec
#     inet6 fe80::44e:d3ff:fecd:a703/64 scope link
#        valid_lft forever preferred_lft forever
# 5: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UNKNOWN group default qlen 1000
#     link/ether 9e:72:8a:2b:ec:b4 brd ff:ff:ff:ff:ff:ff
#     inet 172.30.0.1/16 scope global vxlan0
#        valid_lft forever preferred_lft forever
#     inet6 fe80::bc25:7dff:fedd:e4fd/64 scope link
#        valid_lft forever preferred_lft forever

ip route
# default via 10.80.1.1 dev ens5 proto dhcp src 10.80.1.141 metric 100
# 10.80.0.2 via 10.80.1.1 dev ens5 proto dhcp src 10.80.1.141 metric 100
# 10.80.1.0/24 dev ens5 proto kernel scope link src 10.80.1.141 metric 100
# 10.80.1.1 dev ens5 proto dhcp scope link src 10.80.1.141 metric 100
# 172.30.0.0/16 dev vxlan0 proto kernel scope link src 172.30.0.1
# 172.30.93.0/24 via 172.30.0.2 dev vxlan0
```

削除

```bash
ip route del $CALICO_NETWORK_IP_POOL
ip link del vxlan0
```

### サブネットのルートテーブル

| 送信先 | ターゲット |
| --- | --- |
| 0.0.0.0/0 | NATゲートウェイ |
| 10.0.0.0/8 | トランジットゲートウェイ |
| 10.80.0.0/16 | local |
| 172.30.0.0/16 | EKSネットワーク側のルーターインスタンス |


## リモートネットワーク側のルーター

### ホストの設定

```bash
ssh beex-remote-network-router
```

```bash
sudo su -

# IPフォワーディング
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# vxlan作成
REMOTE_IP=10.80.1.141
ip link add vxlan0 type vxlan id 100 dev ens5 remote $REMOTE_IP dstport 4789
ip addr add 172.30.0.2/16 dev vxlan0
ip link set vxlan0 up

# ルーティング設定
CALICO_NETWORK_IP_POOL=172.30.93.0/24
HYBRID_NODE_HOST=10.53.11.86
ip route add $CALICO_NETWORK_IP_POOL via $HYBRID_NODE_HOST

# 確認
ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
#     inet6 ::1/128 scope host noprefixroute
#        valid_lft forever preferred_lft forever
# 2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
#     link/ether 06:ea:a3:c4:9d:b5 brd ff:ff:ff:ff:ff:ff
#     altname enp0s5
#     inet 10.53.11.208/24 metric 100 brd 10.53.11.255 scope global dynamic ens5
#        valid_lft 2343sec preferred_lft 2343sec
#     inet6 fe80::4ea:a3ff:fec4:9db5/64 scope link
#        valid_lft forever preferred_lft forever
# 4: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UNKNOWN group default qlen 1000
#     link/ether 42:2d:3e:f3:ca:fc brd ff:ff:ff:ff:ff:ff
#     inet 172.30.0.2/16 scope global vxlan0
#        valid_lft forever preferred_lft forever
#     inet6 fe80::2489:6cff:fe72:c84f/64 scope link
#        valid_lft forever preferred_lft forever


ip route
# default via 10.53.11.1 dev ens5 proto dhcp src 10.53.11.208 metric 100
# 10.53.0.2 via 10.53.11.1 dev ens5 proto dhcp src 10.53.11.208 metric 100
# 10.53.11.0/24 dev ens5 proto kernel scope link src 10.53.11.208 metric 100
# 10.53.11.1 dev ens5 proto dhcp scope link src 10.53.11.208 metric 100
# 172.30.0.0/16 dev vxlan0 proto kernel scope link src 172.30.0.2
# 172.30.93.0/24 via 10.53.11.86 dev ens5
```

削除

```bash
ip route del $CALICO_NETWORK_IP_POOL
ip link del vxlan0
```

### サブネットのルートテーブル

| 送信先 | ターゲット |
| --- | --- |
| 0.0.0.0/0 | NATゲートウェイ |
| 10.0.0.0/8 | トランジットゲートウェイ |
| 10.53.0.0/16 | local |
| 172.30.0.0/16 | ハイブリッドノードのインスタンス (※ 不要かも) |


## 疎通確認

### EKSネットワークルーターから

```bash
# ハイブリッドノードへの疎通確認
ping 10.53.11.86  # ハイブリッドノードのIP

# リモートネットワークへの疎通確認
ping 10.53.11.141  # リモートネットワークルーターのIP

# VXLANの疎通確認
ping 172.30.0.2

# リモートPodネットワークへの疎通確認 (帰りのルートがないので届いていればOK)
ping 172.30.93.133  # ハイブリッドノード上のpodのIP
```

```bash
tcpdump -tn -i any icmp
```

### リモートネットワークルーターから

```bash
# ハイブリッドノードへの疎通確認
ping 10.53.11.86  # ハイブリッドノードのIP

# EKSネットワークへの疎通確認
ping 10.80.1.141  # EKSネットワークルーター

# VXLANの疎通確認
ping 172.30.0.1

# リモートPodネットワークへの疎通確認
ping 172.30.93.133  # ハイブリッドノード上のpodのIP
```

```bash
tcpdump -tn -i any icmp
```


# ■ サービスコンポーネント

```bash
make tf-plan STAGE=dev COMPONENT=service
make tf-apply STAGE=dev COMPONENT=service
```

- [http-app](./service/http-app/README.md)
- [netshoot](./service/netshoot/README.md)