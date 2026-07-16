#!/bin/bash

vagrant box remove kali-linux
rm -f kali-linux-vmvware.box
packer build kali-linux.pkr.hcl
vagrant box add kali-linux kali-linux-vmware.box
