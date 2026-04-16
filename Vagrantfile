Vagrant.configure("2") do |config|

  # -------------------------------------------------------------
  # PLUGIN CHECK AND INSTALLATION (vbguest and reload)
  # -------------------------------------------------------------
  config.vagrant.plugins = ["vagrant-vbguest", "vagrant-reload", "vagrant-vmware-desktop"]
  
  # ============================================================================
  # BOX CONFIGURATION
  # ============================================================================
  # Set the box to use - update the path to match your Packer output boxes

  config.vm.box = "kali-linux"  
  
  config.vm.network "private_network",
      virtualbox__intnet: "intnet-attack",
      auto_config: false

  config.vm.define "kali" do |kl|
    kl.vm.hostname = "kali"
    kl.vm.boot_timeout = 300
  
    # ============================================================================
    # SSH CONFIGURATION
    # ============================================================================
 
    kl.ssh.username = "kali"
    kl.ssh.password = "kali"
    kl.ssh.insert_key = true
    kl.ssh.forward_agent = true

  
  # ============================================================================
  # SHARED FOLDERS
  # ============================================================================
  # Sync current directory with /vagrant in the VM
  # Requires open-vm-tools-desktop or virtualbox-guest-additions
  config.vm.synced_folder ".", "/vagrant", disabled: false
  
  # Optional: Disable default sync folder if not needed
  # config.vm.synced_folder ".", "/vagrant", disabled: true
  


  # ============================================================================
  # VIRTUALBOX PROVIDER CONFIGURATION
  # ============================================================================
  kl.vm.provider "virtualbox" do |vb|
    
    vb.name = "kali-linux-vm"
    vb.gui = true                           # Boot with GUI window visible
    vb.cpus = 4
    vb.memory = 4096
    
    # Display settings
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    
    # Performance tweaks
    vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
    vb.customize ["modifyvm", :id, "--boot1", "disk"]
  end
  
  # ============================================================================
  # VMWARE PROVIDER CONFIGURATION
  # ============================================================================
  kl.vm.provider "vmware_desktop" do |v|
    
    v.vmx["displayName"] = "kali-linux-vm"
    v.gui = true                            # Boot with GUI window visible
    v.cpus = 4
    v.memory = 4096
    
    # Video and display settings
    v.vmx["mks.enable3d"] = "TRUE"
    v.vmx["gui.fullScreenAtPowerOn"] = "FALSE"
    v.vmx["memsize"] = "4096"
    v.vmx["numvcpus"] = "4"
    v.vmx["videoram"] = "128"
    v.vmx["sound.present"] = "FALSE"
    
    # Primary network interface (NAT) 
    #v.vmx["ethernet0.present"] = "TRUE"
    #v.vmx["ethernet0.connectionType"] = "nat"
    #v.vmx["ethernet0.pcislotnumber"] = "33"
    #v.vmx["ethernet0.virtualDev"] = "e1000"  

    # Secondary network interface - intnet-attack LAN segment
    v.vmx["ethernet1.present"] = "TRUE"
    v.vmx["ethernet1.connectionType"] = "pvn"
    v.vmx["ethernet1.pvnID"] = "52 5d ed 5d e8 17 cd bc-96 1b 07 bb fa bd c1 20" # Place your ID here in the preferences.ini file or vmx
    #v.vmx["ethernet1.pvnidname"] = "intnet-attack"
    v.vmx["ethernet1.virtualDev"] = "e1000"
    v.vmx["ethernet1.addressType"] = "generated"
    # Disk settings
    v.vmx["scsi0.virtualDev"] = "lsisas1068"
  end
  
  # ============================================================================
  # PROVISIONING 
  # ============================================================================
 
  
  kl.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y curl wget net-tools

  SHELL

  kl.vm.provision "provision-scripts", type: "shell", privileged: false, inline: <<-SHELL

  # Provioning scripts for managing Caldera server and Kali sandcat agent

   cat << EOF > /home/kali/start_caldera.sh
#!/bin/bash

python3 -m venv PyEnv
source PyEnv/bin/activate
cd caldera
python3 server.py --insecure 
EOF

  chmod +x /home/kali/start_caldera.sh

   cat << EOF > /home/kali/start_agent.sh
#!/bin/bash

cd "caldera"
server="http://192.168.0.4:8888"
curl -s -X POST -H "file:sandcat.go" -H "platform:linux" \\$server/file/download > splunkd;
chmod +x splunkd;
./splunkd -server \\$server -group kali -v
EOF


  chmod +x /home/kali/start_agent.sh

  SHELL
 
  kl.vm.provision "provision-caldera", type: "shell", path: "scripts/provision-caldera.sh", privileged: false

  kl.vm.provision "provision-caldera-emu", type: "shell", path: "scripts/provision-caldera-emu.sh", privileged: false

  kl.vm.provision "provision-network", type: "shell", privileged: true, inline: <<-SHELL

   # Configure eth1 with static IP (if needed)
   # This ensures the IP is applied even if Vagrant's auto_config has issues
   
   echo "[+] Configuring network..."
   echo "auto eth1" >> /etc/network/interfaces
   echo "iface eth1 inet static" >> /etc/network/interfaces
   echo " address 192.168.0.4" >> /etc/network/interfaces
   echo " netmask 255.255.255.0" >> /etc/network/interfaces
   echo " gateway 192.168.0.1" >> /etc/network/interfaces

   systemctl restart networking
   ifconfig eth1

   
  SHELL

  kl.vm.provision "reload"
  
end

end
