# caldera-emu-kali
Automation of installation of Caldera and EMU plugin on Kali Linux with Packer and Vagrant

This is part of my Master Thesis project for emulating Oilrig APT on Caldera

The idea is to automate the Kali Linux virtual machine installation and avoid some of the issues encountered while installing MITRE Caldera and the EMU plugin

Everything is installed on the kali user (password kali) as the default Kali Linux provided on kali.org

It should work on Virtualbox, but I haven´t tested it yet.

The installation just needs to run:

packer build kali-linux.pkr.hcl
vagrant up kali --provider=vmware_desktop

Some useful Vagrant commands:

If you need to destroy the Vagrant VM and try again:
vagrant destroy -f

If you need to run just a certain script 
vagrant provision kali --provision-with provision-scripts

Of course, you can download the Kali VM and just run those scripts or use ansible or other automate tooling
