ハイブリッドノード削除ガイド
---

- 参考
  - [ハイブリッドノードを削除する | AWS](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/hybrid-nodes-remove.html)


# ■ Kubernetesクラスタからノードを削除

```bash
# 削除対象のノードを確認
hybrid-nodes dev
# 10.90.1.52 hybrid-nodes-sample-dev-node01 mi-0f3592e0203050e34
# 10.90.2.161 hybrid-nodes-sample-dev-node02 mi-055eefbb0543d9677
# 10.90.3.111 hybrid-nodes-sample-dev-node03 mi-00b6df4305092e188

NODE_NAME=mi-0f3592e0203050e34
TARGET_HOST=hybrid-nodes-sample-dev-node01

# 削除対象のノードをドレイン
kubectl drain --ignore-daemonsets $NODE_NAME

# ハイブリッドノードのアーティファクトを停止・アンインストール
# ※ AWS SSM マネージドインスタンスとしての登録も解除されます
cd $PROJECT_DIR/ansible
ansible-playbook -v \
  -i inventory_dev.yml \
  -l $TARGET_HOST \
  playbook_uninstall.yml

# Kubernetesクラスタからノードを削除
kubectl delete node $NODE_NAME
```