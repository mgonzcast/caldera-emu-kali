vagrant box remove kali-linux
del kali-linux-vmvware.box
packer build kali-linux.pkr.hcl
#vagrant box add kali-linux kali-linux-virtualbox.box
vagrant box add kali-linux kali-linux-vmware.box
#Vmware
vagrant up kali --provider=vmware_desktop
#virtualbox
#vagrant up kali --provider=virtualbox