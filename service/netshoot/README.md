# ■ デプロイ

```bash
kubectl apply -f $PROJECT_DIR/service/netshoot/netshoot.yaml
```

# ■ 動作確認

```bash
kubectl -n netshoot get po -o wide
# NAME                        READY   STATUS    RESTARTS   AGE   IP                NODE                                             NOMINATED NODE   READINESS GATES
# netshoot-778b8ff579-d6xgm   1/1     Running   0          35s   192.168.62.132    ip-10-80-3-184.ap-northeast-1.compute.internal   <none>           <none>
# netshoot-778b8ff579-fsnnt   1/1     Running   0          35s   192.168.152.2     mi-0cfd1f8a8f76e4a30                             <none>           <none>
# netshoot-778b8ff579-jjdn4   1/1     Running   0          35s   192.168.221.130   mi-0ec6de11e4e59b5ec                             <none>           <none>
# netshoot-778b8ff579-m8qc9   1/1     Running   0          35s   192.168.115.66    mi-0ab91e95e922bf106                             <none>           <none>
# netshoot-778b8ff579-ztg6j   1/1     Running   0          35s   192.168.142.195   ip-10-80-1-20.ap-northeast-1.compute.internal    <none>           <none>
```

HybridNodeのnetshootで動作確認

```bash
# ログイン
kubectl -n netshoot exec -ti netshoot-778b8ff579-fsnnt -- /bin/bash

# calicoのIPプールに設定したIPが割り当てられているかを確認
ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
#     inet6 ::1/128 scope host proto kernel_lo 
#        valid_lft forever preferred_lft forever
# 2: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default qlen 1000
#     link/ether 22:6d:9c:a8:d2:76 brd ff:ff:ff:ff:ff:ff link-netnsid 0
#     inet 192.168.152.2/32 scope global eth0
#        valid_lft forever preferred_lft forever
#     inet6 fe80::206d:9cff:fea8:d276/64 scope link proto kernel_ll 
#        valid_lft forever preferred_lft forever


# 他のHybridNodeのnetshootに接続できるか
ping -c 3 192.168.221.130
# PING 192.168.221.130 (192.168.221.130) 56(84) bytes of data.
# 64 bytes from 192.168.221.130: icmp_seq=1 ttl=62 time=1.80 ms
# 64 bytes from 192.168.221.130: icmp_seq=2 ttl=62 time=1.77 ms
# 64 bytes from 192.168.221.130: icmp_seq=3 ttl=62 time=1.80 ms
# ...


# ノードグループのnetshootに接続できるか
ping -c 3 192.168.142.195
# PING 192.168.142.195 (192.168.142.195) 56(84) bytes of data.
# 64 bytes from 192.168.142.195: icmp_seq=1 ttl=125 time=2.31 ms
# 64 bytes from 192.168.142.195: icmp_seq=2 ttl=125 time=1.99 ms
# 64 bytes from 192.168.142.195: icmp_seq=3 ttl=125 time=1.90 ms
# ...


# インターネットに接続できるか
ping -c 3 8.8.8.8
# PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
# 64 bytes from 8.8.8.8: icmp_seq=1 ttl=56 time=4.18 ms
# 64 bytes from 8.8.8.8: icmp_seq=2 ttl=56 time=3.53 ms
# 64 bytes from 8.8.8.8: icmp_seq=3 ttl=56 time=3.53 ms
# ...

# resolv.conf の確認
cat /etc/resolv.conf
# nameserver 172.20.0.10/16

# corednsでインターネットのドメインの名前解決ができることを確認
dig +short www.google.co.jp
# 172.217.175.35


# corednsでKubernetesのAPIエンドポイントの名前解決ができるか
dig +short xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.gr7.ap-northeast-1.eks.amazonaws.com
# 10.80.2.130
# 10.80.1.63


# Serviceの名前解決ができるか
dig +short kubernetes.default.svc.cluster.local
# 172.20.0.1


# KubernetesのAPIエンドポイントにアクセスできることを確認
curl -k "https://kubernetes.default.svc.cluster.local/livez"
# ok
curl -k "https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com/livez"
# ok

curl -I "https://www.google.co.jp"
# HTTP/2 200 
# ...

# ログアウト
exit
```

ノードグループのnetshootでも同様の動作確認

```bash
# ログイン
kubectl -n netshoot exec -ti netshoot-778b8ff579-d6xgm -- /bin/bash

# calicoのIPプールに設定したIPが割り当てられているかを確認
ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
#     inet6 ::1/128 scope host proto kernel_lo 
#        valid_lft forever preferred_lft forever
# 2: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default qlen 1000
#     link/ether ae:4c:0b:ba:cb:cc brd ff:ff:ff:ff:ff:ff link-netnsid 0
#     inet 192.168.62.132/32 scope global eth0
#        valid_lft forever preferred_lft forever
#     inet6 fe80::ac4c:bff:feba:cbcc/64 scope link proto kernel_ll 
#        valid_lft forever preferred_lft forever

# HybridNodeのnetshootに接続できるか
ping -c 3 192.168.221.130
# PING 192.168.221.130 (192.168.221.130) 56(84) bytes of data.
# 64 bytes from 192.168.221.130: icmp_seq=1 ttl=62 time=1.80 ms
# 64 bytes from 192.168.221.130: icmp_seq=2 ttl=62 time=1.77 ms
# 64 bytes from 192.168.221.130: icmp_seq=3 ttl=62 time=1.80 ms
# ...


# ノードグループのnetshootに接続できるか
ping -c 3 192.168.142.195
# PING 192.168.142.195 (192.168.142.195) 56(84) bytes of data.
# 64 bytes from 192.168.142.195: icmp_seq=1 ttl=125 time=2.31 ms
# 64 bytes from 192.168.142.195: icmp_seq=2 ttl=125 time=1.99 ms
# 64 bytes from 192.168.142.195: icmp_seq=3 ttl=125 time=1.90 ms
# ...


# インターネットに接続できるか
ping -c 3 8.8.8.8
# PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
# 64 bytes from 8.8.8.8: icmp_seq=1 ttl=56 time=4.18 ms
# 64 bytes from 8.8.8.8: icmp_seq=2 ttl=56 time=3.53 ms
# 64 bytes from 8.8.8.8: icmp_seq=3 ttl=56 time=3.53 ms
# ...

# resolv.conf の確認
cat /etc/resolv.conf
# nameserver 172.20.0.10/16

# corednsでインターネットのドメインの名前解決ができることを確認
dig +short www.google.co.jp
# 172.217.175.35


# corednsでKubernetesのAPIエンドポイントの名前解決ができるか
dig +short xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.gr7.ap-northeast-1.eks.amazonaws.com
# 10.80.2.130
# 10.80.1.63


# Serviceの名前解決ができるか
dig +short kubernetes.default.svc.cluster.local
# 172.20.0.1



# KubernetesのAPIエンドポイントにアクセスできることを確認
curl -k "https://kubernetes.default.svc.cluster.local/livez"
# ok
curl -k "https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com/livez"
# ok

# 外部にcurlできることを確認
curl -I "https://www.google.co.jp"
# HTTP/2 200 
# ...

# ログアウト
exit
```


# ■ 削除

```bash
kubectl delete -f $PROJECT_DIR/service/netshoot/netshoot.yaml
```