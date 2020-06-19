# The `hostPath` storage

The `hostPath` volume type is a candidate for services configuration and log folders planned to run only in the master node.

Prepare some sandbox folders and create [pods](pv-hostpath.yml)
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
