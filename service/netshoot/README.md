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
# 
# --- 192.168.221.130 ping statistics ---
# 3 packets transmitted, 3 received, 0% packet loss, time 2004ms
# rtt min/avg/max/mdev = 1.774/1.790/1.801/0.011 ms


# ノードグループのnetshootに接続できるか
ping -c 3 192.168.142.195
# PING 192.168.142.195 (192.168.142.195) 56(84) bytes of data.
# 64 bytes from 192.168.142.195: icmp_seq=1 ttl=125 time=2.31 ms
# 64 bytes from 192.168.142.195: icmp_seq=2 ttl=125 time=1.99 ms
# 64 bytes from 192.168.142.195: icmp_seq=3 ttl=125 time=1.90 ms
# 
# --- 192.168.142.195 ping statistics ---
# 3 packets transmitted, 3 received, 0% packet loss, time 2002ms
# rtt min/avg/max/mdev = 1.901/2.065/2.308/0.175 ms


# インターネットに接続できるか
ping -c 3 8.8.8.8
# PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
# 64 bytes from 8.8.8.8: icmp_seq=1 ttl=56 time=4.18 ms
# 64 bytes from 8.8.8.8: icmp_seq=2 ttl=56 time=3.53 ms
# 64 bytes from 8.8.8.8: icmp_seq=3 ttl=56 time=3.53 ms
# 
# --- 8.8.8.8 ping statistics ---
# 3 packets transmitted, 3 received, 0% packet loss, time 2003ms
# rtt min/avg/max/mdev = 3.530/3.747/4.183/0.307 ms


# corednsで名前解決ができることを確認
dig www.google.co.jp
# ; <<>> DiG 9.18.25 <<>> www.google.co.jp
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59909
# ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
# 
# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 1232
# ; COOKIE: 03aea5d4f1b5a00b (echoed)
# ;; QUESTION SECTION:
# ;www.google.co.jp.              IN      A
# 
# ;; ANSWER SECTION:
# www.google.co.jp.       30      IN      A       142.251.42.195
# 
# ;; Query time: 3 msec
# ;; SERVER: 172.20.0.10#53(172.20.0.10) (UDP)
# ;; WHEN: Thu Mar 27 14:54:02 UTC 2025
# ;; MSG SIZE  rcvd: 89


# KubernetesのAPIエンドポイントの名前解決ができるか
dig XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com
# ; <<>> DiG 9.18.25 <<>> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39529
# ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
# 
# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 1232
# ; COOKIE: d23b37f8b19eb9a5 (echoed)
# ;; QUESTION SECTION:
# ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com. IN A
# 
# ;; ANSWER SECTION:
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com. 30 IN A 10.80.3.31
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com. 30 IN A 10.80.2.245
# 
# ;; Query time: 4 msec
# ;; SERVER: 172.20.0.10#53(172.20.0.10) (UDP)
# ;; WHEN: Thu Mar 27 14:58:52 UTC 2025
# ;; MSG SIZE  rcvd: 280


# Serviceの名前解決ができるか
dig kubernetes.default.svc.cluster.local
# ; <<>> DiG 9.18.25 <<>> kubernetes.default.svc.cluster.local
# ;; global options: +cmd
# ;; Got answer:
# ;; WARNING: .local is reserved for Multicast DNS
# ;; You are currently testing what happens when an mDNS query is leaked to DNS
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54065
# ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
# ;; WARNING: recursion requested but not available
# 
# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 1232
# ; COOKIE: a200a53ad5c58c13 (echoed)
# ;; QUESTION SECTION:
# ;kubernetes.default.svc.cluster.local. IN A
# 
# ;; ANSWER SECTION:
# kubernetes.default.svc.cluster.local. 5 IN A    172.20.0.1
# 
# ;; Query time: 3 msec
# ;; SERVER: 172.20.0.10#53(172.20.0.10) (UDP)
# ;; WHEN: Thu Mar 27 15:04:00 UTC 2025
# ;; MSG SIZE  rcvd: 129


# KubernetesのAPIエンドポイントにアクセスできることを確認
curl -k "https://kubernetes.default.svc.cluster.local/livez"
# ok
curl -k "https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com/livez"
# ok

curl -I "https://www.google.co.jp"
# HTTP/2 200 
# content-type: text/html; charset=Shift_JIS
# content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-YgHLQvj4OUkbI0s2ENXTWA' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
# accept-ch: Sec-CH-Prefers-Color-Scheme
# p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
# date: Thu, 27 Mar 2025 15:25:40 GMT
# server: gws
# x-xss-protection: 0
# x-frame-options: SAMEORIGIN
# expires: Thu, 27 Mar 2025 15:25:40 GMT
# cache-control: private
# set-cookie: AEC=AVcja2e5eiGt4q4l_67eHQMPbePBMHrGn7Ptnmwk49UnzcqEHDfNtnq62Q; expires=Tue, 23-Sep-2025 15:25:40 GMT; path=/; domain=.google.co.jp; Secure; HttpOnly; SameSite=lax
# set-cookie: NID=522=RdT19GP9MqOGbLGzYt1JDHCCl879fOFbHNbo8UEpDHlDloDtvST-Q7CJwGsONX5wqF6etfq2N4qJoxN3z5uDzSyS0TuK0jp7Sa416hGViJUw_SO6trgvLu88BIhpKsCdFUzSi-1_YOvUGST1y2w6MGNeuu38i__H5O8jy4Q2sh_0WVTQ7Q8TDoxXUcYdTMnBosyBVuNxSR_kqLM; expires=Fri, 26-Sep-2025 15:25:40 GMT; path=/; domain=.google.co.jp; HttpOnly
# alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

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
# 
# --- 192.168.221.130 ping statistics ---
# 3 packets transmitted, 3 received, 0% packet loss, time 2004ms
# rtt min/avg/max/mdev = 1.774/1.790/1.801/0.011 ms


# ノードグループのnetshootに接続できるか
ping -c 3 192.168.142.195
# PING 192.168.142.195 (192.168.142.195) 56(84) bytes of data.
# 64 bytes from 192.168.142.195: icmp_seq=1 ttl=125 time=2.31 ms
# 64 bytes from 192.168.142.195: icmp_seq=2 ttl=125 time=1.99 ms
# 64 bytes from 192.168.142.195: icmp_seq=3 ttl=125 time=1.90 ms
# 
# --- 192.168.142.195 ping statistics ---
# 3 packets transmitted, 3 received, 0% packet loss, time 2002ms
# rtt min/avg/max/mdev = 1.901/2.065/2.308/0.175 ms


# インターネットに接続できるか
ping -c 3 8.8.8.8
# PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
# 64 bytes from 8.8.8.8: icmp_seq=1 ttl=56 time=4.18 ms
# 64 bytes from 8.8.8.8: icmp_seq=2 ttl=56 time=3.53 ms
# 64 bytes from 8.8.8.8: icmp_seq=3 ttl=56 time=3.53 ms
# 
# --- 8.8.8.8 ping statistics ---
# 3 packets transmitted, 3 received, 0% packet loss, time 2003ms
# rtt min/avg/max/mdev = 3.530/3.747/4.183/0.307 ms


# corednsで名前解決ができることを確認
dig www.google.co.jp
# ; <<>> DiG 9.18.25 <<>> www.google.co.jp
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 59909
# ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
# 
# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 1232
# ; COOKIE: 03aea5d4f1b5a00b (echoed)
# ;; QUESTION SECTION:
# ;www.google.co.jp.              IN      A
# 
# ;; ANSWER SECTION:
# www.google.co.jp.       30      IN      A       142.251.42.195
# 
# ;; Query time: 3 msec
# ;; SERVER: 172.20.0.10#53(172.20.0.10) (UDP)
# ;; WHEN: Thu Mar 27 14:54:02 UTC 2025
# ;; MSG SIZE  rcvd: 89


# KubernetesのAPIエンドポイントの名前解決ができるか
dig XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com
# ; <<>> DiG 9.18.25 <<>> XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 39529
# ;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
# 
# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 1232
# ; COOKIE: d23b37f8b19eb9a5 (echoed)
# ;; QUESTION SECTION:
# ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com. IN A
# 
# ;; ANSWER SECTION:
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com. 30 IN A 10.80.3.31
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com. 30 IN A 10.80.2.245
# 
# ;; Query time: 4 msec
# ;; SERVER: 172.20.0.10#53(172.20.0.10) (UDP)
# ;; WHEN: Thu Mar 27 14:58:52 UTC 2025
# ;; MSG SIZE  rcvd: 280


# Serviceの名前解決ができるか
dig kubernetes.default.svc.cluster.local
# ; <<>> DiG 9.18.25 <<>> kubernetes.default.svc.cluster.local
# ;; global options: +cmd
# ;; Got answer:
# ;; WARNING: .local is reserved for Multicast DNS
# ;; You are currently testing what happens when an mDNS query is leaked to DNS
# ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54065
# ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
# ;; WARNING: recursion requested but not available
# 
# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 1232
# ; COOKIE: a200a53ad5c58c13 (echoed)
# ;; QUESTION SECTION:
# ;kubernetes.default.svc.cluster.local. IN A
# 
# ;; ANSWER SECTION:
# kubernetes.default.svc.cluster.local. 5 IN A    172.20.0.1
# 
# ;; Query time: 3 msec
# ;; SERVER: 172.20.0.10#53(172.20.0.10) (UDP)
# ;; WHEN: Thu Mar 27 15:04:00 UTC 2025
# ;; MSG SIZE  rcvd: 129


# KubernetesのAPIエンドポイントにアクセスできることを確認
curl -k "https://kubernetes.default.svc.cluster.local/livez"
# ok
curl -k "https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.sl7.ap-northeast-1.eks.amazonaws.com/livez"
# ok

# 外部にcurlできることを確認
curl -I "https://www.google.co.jp"
# HTTP/2 200 
# content-type: text/html; charset=Shift_JIS
# content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-s8KJmW6vVZvUiMitVpDxKQ' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
# accept-ch: Sec-CH-Prefers-Color-Scheme
# p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
# date: Thu, 27 Mar 2025 15:22:20 GMT
# server: gws
# x-xss-protection: 0
# x-frame-options: SAMEORIGIN
# expires: Thu, 27 Mar 2025 15:22:20 GMT
# cache-control: private
# set-cookie: AEC=AVcja2e2pOxteSluROyLXQHXp4sfJ0-t3MZSuFM4NHvrEnPlv6Spvd3jxQ; expires=Tue, 23-Sep-2025 15:22:20 GMT; path=/; domain=.google.co.jp; Secure; HttpOnly; SameSite=lax
# set-cookie: NID=522=46N0n8Pd69cEMeD-u_ilObOU22ZHLDltCHgwMLAOzEB81wW6NecJJj1f0BNi53h54hm8cyxrR1vvg_apgJN2lvFwwu46DrDIKhqMDLgQ7JDcJwphTPbh8iv9QDpnuZ-uu-Dm5oljCzsTE0Oh19lKsWw_2Ob-BT7hwGC4tqtwR7NY65MuBxdqgSeBYQDEehVtqWTlKy3YJXybzQ; expires=Fri, 26-Sep-2025 15:22:20 GMT; path=/; domain=.google.co.jp; HttpOnly
# alt-svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000

# ログアウト
exit
```


# ■ 削除

```bash
kubectl delete -f $PROJECT_DIR/service/netshoot/netshoot.yaml
```