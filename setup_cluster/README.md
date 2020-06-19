# Resources

Kubernetes is set up on a three node cluster kooplex-test, kooplex-cn1 and kooplex-cn2. All running ubuntu 18.04.4

The node kooplex-test has public network enabled, kooplex-cn1 and kooplex-cn2 are not public. Apt installation is via proxy.

The version number of the docker engine installed is 19.03.6.

## Installation howtos

Steps mainly follow:
* https://kubernetes.io/docs/tasks/tools/install-kubectl/
* https://www.nakivo.com/blog/install-kubernetes-ubuntu/

## Prerequisities

These commands are run in root context at kooplex-test to be the master node.

```bash
apt update && apt install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-bionic main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update & apt install -y kubectl kubeadm kubelet

systemctl enable docker.service
swapoff -a
echo "vm.swappiness=0" | tee --append /etc/sysctl.conf
sysctl -p
```

**FIXME:** cgroup settings are not yet done. _Add the string after the existing Environment string_ in `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
```Environment=”cgroup-driver=systemd/cgroup-driver=cgroupfs”```

## Master node setup

Refresh to the latest required images and initialize the cluster.

```bash
kubeadm config images pull
kubeadm init --apiserver-advertise-address=192.168.13.203  --pod-network-cidr=10.44.0.0/16

mkdir ~/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user=kooplex@complex.elte.hu
```

### Test
```
root@kooplex-test:~/ $ kubectl get nodes --show-labels
NAME           STATUS     ROLES    AGE   VERSION   LABELS
kooplex-test   NotReady   master   47s   v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-test,kubernetes.io/os=linux,node-role.kubernetes.io/master=
root@kooplex-test:~/ $ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-7g2cm               0/1     Pending   0          36s
kube-system   coredns-66bff467f8-g9qkj               0/1     Pending   0          36s
kube-system   etcd-kooplex-test                      1/1     Running   0          44s
kube-system   kube-apiserver-kooplex-test            1/1     Running   0          44s
kube-system   kube-controller-manager-kooplex-test   1/1     Running   0          44s
kube-system   kube-proxy-fnqvg                       1/1     Running   0          36s
kube-system   kube-scheduler-kooplex-test            1/1     Running   0          44s
```

## Overlay network setup

We install flannel.
```bash
curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > flannel.yml-orig
```

The content was modified:
* unrelated architecture definitions for the DaemonSet is removed
* the pod-network adress modified to what we gave at init
* for the subnet the network interface name differ for the mater and the worker node thus extra argument is passed to `flanneld`-

The final version of the configuration: [flannel.yml](flannel.yml)

```bash
kubectl apply -f flannel.yml
```

### Test

Check:
* two new interfaces are set up: flannel.1 and cni0 with proper network addresses.
* the master node becomes ready.

```
root@kooplex-test:~/ $ ip link show flannel.1
4493: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/ether 7e:24:55:48:b1:5c brd ff:ff:ff:ff:ff:ff
root@kooplex-test:~/ $ ip link show cni0 
4494: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether ee:f5:ba:21:d8:16 brd ff:ff:ff:ff:ff:ff
root@kooplex-test:~/ $ ip addr show flannel.1 
4493: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default 
    link/ether 7e:24:55:48:b1:5c brd ff:ff:ff:ff:ff:ff
    inet 10.44.0.0/32 scope global flannel.1
       valid_lft forever preferred_lft forever
    inet6 fe80::7c24:55ff:fe48:b15c/64 scope link 
       valid_lft forever preferred_lft forever
root@kooplex-test:~/ $ ip addr show cni0 
4494: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default qlen 1000
    link/ether ee:f5:ba:21:d8:16 brd ff:ff:ff:ff:ff:ff
    inet 10.44.0.1/24 brd 10.44.0.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::ecf5:baff:fe21:d816/64 scope link 
       valid_lft forever preferred_lft forever
root@kooplex-test:~/ $ kubectl get nodes --show-labels
NAME           STATUS   ROLES    AGE     VERSION   LABELS
kooplex-test   Ready    master   3m50s   v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-test,kubernetes.io/os=linux,node-role.kubernetes.io/master=
root@kooplex-test:~/ $ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-7g2cm               1/1     Running   0          3m37s
kube-system   coredns-66bff467f8-g9qkj               1/1     Running   0          3m37s
kube-system   etcd-kooplex-test                      1/1     Running   0          3m45s
kube-system   kube-apiserver-kooplex-test            1/1     Running   0          3m45s
kube-system   kube-controller-manager-kooplex-test   1/1     Running   0          3m45s
kube-system   kube-flannel-ds-amd64-master-smhfq     1/1     Running   0          98s
kube-system   kube-proxy-fnqvg                       1/1     Running   0          3m37s
kube-system   kube-scheduler-kooplex-test            1/1     Running   0          3m45s
```

## Prepare images for the worker nodes

Worker nodes do not have network connection to docker image repositories. So we tag and push images to local vanessa repo.

```bask
docker pull busybox
docker tag quay.io/coreos/flannel:v0.12.0-amd64 localhost:5000/quay.io/coreos/flannel:v0.12.0-amd64
docker tag k8s.gcr.io/kube-proxy:v1.18.4 localhost:5000/k8s.gcr.io/kube-proxy:v1.18.4
docker tag k8s.gcr.io/pause:3.2 localhost:5000/k8s.gcr.io/pause:3.2
docker tag kooplex-test:5000/busybox:latest localhost:5000/kooplex-test:5000/busybox:latest
docker push localhost:5000/quay.io/coreos/flannel:v0.12.0-amd64
docker push localhost:5000/k8s.gcr.io/kube-proxy:v1.18.4
docker push localhost:5000/k8s.gcr.io/pause:3.2
docker push localhost:5000/kooplex-test:5000/busybox:latest
```

After that on both worker nodes manuall docker pull images and tag them according to the original image name. _Note:_ this step may be unnecessary if `flannel.yml` image is reflecting our img repo.


## Let worker nodes join the cluster

In case we forgot the keys and tokens: `kubeadm token create`. Ant then run on each worker node.

```bash
kubeadm join 192.168.13.203:6443 --token XXXX    --discovery-token-ca-cert-hash sha256:XXXX
```

### Test

At this point the worker will not be ready, because it is missing a label to select the propes DaemonSet for it.

```
root@kooplex-test:~/ $ kubectl get nodes --show-labels
NAME           STATUS     ROLES    AGE     VERSION   LABELS
kooplex-cn1    NotReady   <none>   61s     v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-cn1,kubernetes.io/os=linux
kooplex-test   Ready      master   7m49s   v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-test,kubernetes.io/os=linux,node-role.kubernetes.io/master=
```

We have to add label to worker node

```bash
kubectl  label node kooplex-cn1 node-role.kubernetes.io/worker= 
kubectl  label node kooplex-cn2 node-role.kubernetes.io/worker= 
```

### Test

```
root@kooplex-test:~/ $ kubectl get nodes --show-labels
NAME           STATUS   ROLES    AGE    VERSION   LABELS
kooplex-cn1    Ready    worker   179m   v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-cn1,kubernetes.io/os=linux,node-role.kubernetes.io/worker=
kooplex-cn2    Ready    worker   21m    v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-cn2,kubernetes.io/os=linux,node-role.kubernetes.io/worker=
kooplex-test   Ready    master   3h6m   v1.18.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kooplex-test,kubernetes.io/os=linux,node-role.kubernetes.io/master=
root@kooplex-test:~/ $ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-66bff467f8-7g2cm               1/1     Running   0          3h6m
kube-system   coredns-66bff467f8-g9qkj               1/1     Running   0          3h6m
kube-system   etcd-kooplex-test                      1/1     Running   0          3h6m
kube-system   kube-apiserver-kooplex-test            1/1     Running   0          3h6m
kube-system   kube-controller-manager-kooplex-test   1/1     Running   0          3h6m
kube-system   kube-flannel-ds-amd64-cn-2tqdl         1/1     Running   0          155m
kube-system   kube-flannel-ds-amd64-cn-lgkmc         1/1     Running   0          21m
kube-system   kube-flannel-ds-amd64-master-8ndzh     1/1     Running   0          164m
kube-system   kube-proxy-fnqvg                       1/1     Running   0          3h6m
kube-system   kube-proxy-g5gml                       1/1     Running   0          139m
kube-system   kube-proxy-zxcw6                       1/1     Running   0          22m
kube-system   kube-scheduler-kooplex-test            1/1     Running   0          3h6m
```

At this point any worker node can ping the master 10.44.0.1, but not the other way around because cni0 interface is not present in worker nodes yet.
```
root@kooplex-cn1:~# ping 10.44.0.1
PING 10.44.0.1 (10.44.0.1) 56(84) bytes of data.
64 bytes from 10.44.0.1: icmp_seq=1 ttl=64 time=0.424 ms
64 bytes from 10.44.0.1: icmp_seq=2 ttl=64 time=0.538 ms
^C
--- 10.44.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1005ms
rtt min/avg/max/mdev = 0.424/0.481/0.538/0.057 ms
```

## Let master node schedule pods

```bash
kubectl taint node kooplex-test node-role.kubernetes.io/master:NoSchedule-
```

### Test dataplane

Start some trivial pods to see if they comminicate: [busybox.yml](busybox.yml).

```bash
kubectl apply -f busybox.yaml
```

Right after this `cni0` interfaces are created at worker nodes.

If you `docker exec` any of the pod containers they answer ping by IP address.

```
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master -- /bin/sh
/ # ping 10.44.2.1
PING 10.44.2.1 (10.44.2.1): 56 data bytes
64 bytes from 10.44.2.1: seq=0 ttl=63 time=0.655 ms
64 bytes from 10.44.2.1: seq=1 ttl=63 time=0.658 ms
^C
--- 10.44.2.1 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.655/0.656/0.658 ms
```

### Test

Check pods, services and enpoints are created:

```
root@kooplex-test:~/ $ kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
bbs-cn1      ClusterIP   10.100.114.108   <none>        80/TCP    11m
bbs-cn2      ClusterIP   10.96.17.144     <none>        80/TCP    105s
bbs-master   ClusterIP   10.96.53.96      <none>        80/TCP    105s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   20h
root@kooplex-test:~/ $ kubectl get ep
NAME         ENDPOINTS             AGE
bbs-cn1      10.44.1.5:8080        11m
bbs-cn2      10.44.2.4:8080        110s
bbs-master   10.44.0.7:8080        110s
kubernetes   192.168.13.203:6443   20h
root@kooplex-test:~/ $ kubectl get pods
NAME             READY   STATUS    RESTARTS   AGE
busybox-cn1      1/1     Running   0          21s
busybox-cn2      1/1     Running   0          116s
busybox-master   1/1     Running   0          116s
```

Use `nc` to test dataplane connectivity. Two terminals used:

* Listen

```
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-cn1 -- sh
/ # nc -l -p 8080
hali
^Cpunt!
```

* Send

```
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master -- sh
/ # echo hali | nc bbs-cn1 80
^Cpunt!
```

*Note:* the message in listen terminal appears after you send it in the other terminal. Busybox `nc` does not terminate after EOF we hit ctrl-C.

*Note:* `nslookup` in busybox is somewhat buggy, every now and then forward DNS resolution do not yield an IP address and always fails. Other applications, however, resolve as expected (`ping`, `nc`).

## DNS troubleshooting

In case verbose logging is required for the DNS service, issue the following configurator command and insert a line `log` above the errors line.

```bash
kubectl -n kube-system edit configmap coredns
```

## Persistent storage

See [README-stg.md](README-stg.md) for details.
