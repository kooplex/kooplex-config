Visit the [Kooplex page](https://kooplex.github.io/) for further informations!

## Prerequisites

* apt install docker.io docker-compose acl
* install kubernetes
* vim /etc/docker/daemon.json
```
{
          "exec-opts": ["native.cgroupdriver=systemd"], # for monitoring with grafana
            "log-driver": "json-file",   # don't let logs grow too large
              "log-opts": {
                          "max-size": "100m"
                            },
              "storage-driver": "overlay2",   # that was recommended at some point
      "insecure-registries":["##OTHER_KOOPLEX_INSTANCE##:5000"]  # In case of having multiple Kooplex instances, you may want reuse already built notebook images

}
```

## Installation

* clone this repository

    $ git clone https://github.com/kooplex/kooplex-config.git

* Create certificate and copy in into the `certs` directory

* copy config.jsonnet_template to config.jsonnet and modify it as necessary.

## Kooplex configuration scripts

### Jsonnet templates
All the modules are templated and it needs to be manifested into yaml format. The `build_from_jsonnet.sh` 

## IMPORTANT NOTES
* Check whether all the necessary ports are open (ufw allow etc) e.g. docker port, http port

