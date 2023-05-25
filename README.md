# packer-kubernetes-debian

packer-kubernetes-debian is a set of configuration files used to build an automated Debian 12 virtual machine images using [Packer](https://www.packer.io/).

This repository was forked from https://github.com/eaksel/packer-Debian11 and heavily modified:
1. Uses Debian cloud images instead of an installation iso file
1. Uses cloud-init instead of ansible

The image is created with everything required to use the provided VM as a Kubernetes node. 

## Prerequisites

* [Packer](https://www.packer.io/downloads.html)
  * <https://www.packer.io/intro/getting-started/install.html>
* A working Qemu installation with the kvm accellerator.

## How to use Packer

Commands to create an automated VM image:

To create a Debian VM image use the following command:

```bash
packer build debian.pkr.hcl
```

## Customizing

By default the vm is based on daily cloud images from Debian. The latest daily image is configured. This can be changed in the variables section in `debian.pkr.hcl`.

The Kubernetes version installed for `kubectl`, `kubeadm`, and `kubelet` is also configurable in the variable section in `debian.pkr.hcl`.


## Default credentials

There are no default credentials for the default `debian` user. Use cloud-init to provide an ssh authorized key to be able to log in.


