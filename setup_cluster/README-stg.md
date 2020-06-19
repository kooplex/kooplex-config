# The `hostPath` storage

The `hostPath` volume type is a candidate for services configuration and log folders planned to run only in the master node.

Prepare some sandbox folders and create [pods](pv-hostpath.yml).

```bash
mkdir -p /root/pv/1 /root/pv/2
kubectl apply -f pv-hostpath.yml
```

### Test

Propagate some information in the folder structure to check things work as expected

```
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv0 -- ls /test-pd
1  2
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv1 -- ls /test-pd
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv2 -- ls /test-pd
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv0 -- touch /test-pd/1/alma
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv0 -- touch /test-pd/2/korte
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv1 -- ls /test-pd
alma
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv2 -- ls /test-pd
korte
root@kooplex-test:~/ $ ls pv/1/
alma
root@kooplex-test:~/ $ touch pv/1/krumpli
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv1 -- ls /test-pd
alma     krumpli
```

# The `local` persistent volume storage

The `local` volume type is another candidate for services configuration and log folders planned to run only in the master node.

Reuse former folders and create [pods](pv-local.yml).

```bash
kubectl apply -f pv-local.yml
```

### Test

Note the same claim is shared by the two pods.

```
root@kooplex-test:~/ $ kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS    REASON   AGE
pv-sandbox   1Mi        RWO            Retain           Bound    default/pvclaim   local-storage            13m
root@kooplex-test:~/ $ kubectl get pvc
NAME      STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS    AGE
pvclaim   Bound    pv-sandbox   1Mi        RWO            local-storage   6m5s
root@kooplex-test:~/ $ kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
busybox-cn1           1/1     Running   2          157m
busybox-cn2           1/1     Running   2          158m
busybox-master        1/1     Running   2          158m
busybox-master-pv-a   1/1     Running   0          6m10s
busybox-master-pv-b   1/1     Running   0          6m10s
busybox-master-pv0    1/1     Running   1          81m
busybox-master-pv1    1/1     Running   1          81m
busybox-master-pv2    1/1     Running   1          81m

root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv-a -- ls /test-pd
1  2
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv-b -- ls /test-pd
1  2
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv-a -- touch /test-pd/T
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv-b -- ls /test-pd
1  2  T
```

# The `subPath` combined with `local` persistent volume

It is possible to dedicate a subfolder for a pod. The example [configuration](pv-subpath.yml) buils on previous folders, volume and volume claim.

### Test

```
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pvsp-1 -- ls /test-pd
alma     krumpli
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pvsp-2 -- ls /test-pd
korte
```


# Move on

Seems accross our nodes there is no need at this pont to go for NFS. [conf](pvcn.yml)

```bash
mkdit /big-data/sandbox.k8s
kubectl apply -f pvcn.yml
```

### Test

```
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-master-pv -- touch /test-pd/t
root@kooplex-test:~/ $ kubectl exec --stdin --tty busybox-cn1-pv -- ls /test-pd/
t
```


# The `nfs` storage volume

To be tested later when really needed.
