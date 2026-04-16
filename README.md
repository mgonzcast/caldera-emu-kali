# caldera-emu-kali
Automation of Caldera and EMU plugin installation on Kali Linux using Packer and Vagrant

This is part of my Master Thesis project for emulating Oilrig APT on Caldera

The idea is to automate the Kali Linux virtual machine installation and avoid some of the issues encountered while installing MITRE Caldera and the EMU plugin

Everything is installed on the kali user (password kali) as the default Kali Linux VM provided on kali.org

It should work on Virtualbox, but I haven´t tested it yet.

The installation just needs to run:
```
packer build kali-linux.pkr.hcl
vagrant box add kali-linux kali-linux-virtualbox.box
vagrant box add kali-linux kali-linux-vmware.box
#Vmware
vagrant up kali --provider=vmware_desktop
#virtualbox
vagrant up kali --provider=virtualbox
```

Unfortunately Vagrant doesn´t support to generate two machines with Vmware provider being one of them, so you need to remove one:
```
vagrant destroy kali -f
```

If you need to run just a certain script 
```
vagrant provision kali --provision-with provision-scripts
```

Of course, you can download the Kali VM and just run those scripts or use ansible or other automate tooling

The installation creates two network interfaces, in the case of Vmware Workstation, I create a NAT and a LAN Segment called intnet-attack. 

In VMware, you need to use an pvnID for the LAN Segment you have created, so you have to check on your preferences.ini file or the vmx configuration file of other Virtual machine to find out the pvnID. I haven´t found a way, as in Virtualbox, to use a name instead.
