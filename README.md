Create a custom RHEL/CentOS 7 kickstart boot image
===

Build Docker image
---
```
docker build -t create_ks_bootiso .
docker images | awk '/none/{print $3}' | xargs -r docker rmi
```

Download th CD / DVD images
---

* [Download RHEL 7](https://access.redhat.com/downloads)

* [Download CentOS 7](https://www.centos.org/download/)


Create custom boot image
---

Example:
```
docker run --privileged -v $(pwd):/opt/work -t create_ks_bootiso \
    customiso \
    --isolinuxcfg isolinux.cfg \
    --kickstart ks.cfg \
    --output-bootiso custom-boot.iso \
    CentOS-7-x86_64-DVD-1511.iso
docker ps -a -q|xargs -r docker rm
```

Check validity of your Kickstart file
---

Example:
```
docker run -v $(pwd):/opt/work -t create_ks_bootiso \
    ksvalidator --version RHEL7 /opt/work/ks.cfg
```

Encrypting passwords for rootpw
---

Example:
```
docker run -i -t create_ks_bootiso rootpw --sha512
```
