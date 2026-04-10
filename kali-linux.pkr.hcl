packer {
  required_version = ">= 1.8.0"
  required_plugins {
    virtualbox = {
      version = ">=1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
  }
}

variable "iso_url" {
  type        = string
  description = "Kali Linux ISO URL"
  default     = "isos/kali-linux-2026.1-installer-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum of the Kali Linux ISO"
  default     = "sha256:271477ad6ea2676c7346576971b9acc2d32fabd9c2bbaf0e6302397626149306"
}

variable "vm_name" {
  type    = string
  default = "kali-linux-base"
}

variable "cpus" {
  type    = number
  default = 4
}

variable "memory" {
  type    = number
  default = 4096
}

variable "disk_size" {
  type    = number
  default = 30720
}

variable "username" {
  type    = string
  default = "kali"
}

variable "password" {
  type      = string
  default   = "kali"
  sensitive = true
}

source "virtualbox-iso" "kali-linux" {
  guest_os_type = "Debian_64"
  iso_url       = var.iso_url
  iso_checksum  = var.iso_checksum
  
  vm_name   = var.vm_name
  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size
  
  headless = false
  
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "20m"
  
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "install ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer/locale=en_US.UTF-8 ",
    "kbd-chooser/method=us ",
    "keyboard-configuration/xkb-keymap=us ",
    "netcfg/get_hostname=kali ",
    "netcfg/get_domain=localdomain ",
    "fb=false ",
    "debconf/frontend=noninteractive ",
    "console-setup/ask_detect=false ",
    "auto=true ",
    "priority=critical ",
    "<enter>"
  ]
  
  http_directory = "http"
  
  shutdown_command = "echo '${var.password}' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"
  
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--vram", "128"],
    ["modifyvm", "{{.Name}}", "--clipboard", "bidirectional"],
    ["modifyvm", "{{.Name}}", "--audio", "none"]
  ]
  
  skip_export          = false
  guest_additions_mode = "upload"
  guest_additions_path = "/tmp/VBoxGuestAdditions.iso"
}

source "vmware-iso" "kali-linux" {
  guest_os_type = "debian8-64"
  iso_url       = var.iso_url
  iso_checksum  = var.iso_checksum
  
  vm_name   = var.vm_name
  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size
  
  headless = false
  
  communicator = "ssh"
  ssh_username = var.username
  ssh_password = var.password
  ssh_timeout  = "20m"
  ssh_port     = 22
  
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "install ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer/locale=en_US.UTF-8 ",
    "kbd-chooser/method=us ",
    "keyboard-configuration/xkb-keymap=us ",
    "netcfg/get_hostname=kali ",
    "netcfg/get_domain=localdomain ",
    "fb=false ",
    "debconf/frontend=noninteractive ",
    "console-setup/ask_detect=false ",
    "auto=true ",
    "priority=critical ",
    "<enter>"
  ]
  
  http_directory = "http"
  
  shutdown_command = "echo '${var.password}' | sudo -S shutdown -P now"
  shutdown_timeout = "5m"
  
  network_adapter_type = "e1000"
  disk_adapter_type    = "lsisas1068"
  sound                = false
  usb                  = false
}

build {
  sources = [
  #  "source.virtualbox-iso.kali-linux",
    "source.vmware-iso.kali-linux"
  ]
  
  # Update system packages
  provisioner "shell" {
    inline = [
      "echo '${var.password}' | sudo -S apt-get update",
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential linux-headers-$(uname -r)"
    ]
  }
  
  # Install VirtualBox/VMware tools
  provisioner "shell" {
    inline = [
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y virtualbox-guest-utils virtualbox-guest-x11",
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y open-vm-tools-desktop open-vm-tools"
    ]
  }
  
  # Install SSH server and enable it
  provisioner "shell" {
    inline = [
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server",
      "echo '${var.password}' | sudo -S systemctl enable ssh"
    ]
  }
  
  # Configure sudo without password for provisioning
  provisioner "shell" {
    inline = [
      "echo '${var.password}' | sudo -S bash -c 'echo \"${var.username} ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers.d/${var.username}'",
      "echo '${var.password}' | sudo -S chmod 440 /etc/sudoers.d/${var.username}"
    ]
  }

  # Add Vagrant SSH key support for kali user
  provisioner "shell" {
    inline = [
      "mkdir -p /home/${var.username}/.ssh",
      "curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub >> /home/${var.username}/.ssh/authorized_keys",
      "chmod 700 /home/${var.username}/.ssh",
      "chmod 600 /home/${var.username}/.ssh/authorized_keys",
      "echo '${var.password}' | sudo -S chown -R ${var.username}:${var.username} /home/${var.username}/.ssh"
    ]
  }

  # Install Kali desktop tools
  provisioner "shell" {
    inline = [
      # Update and install XFCE (this will likely pull in lightdm automatically)
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get update",
      "echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y kali-desktop-xfce xfce4 xfce4-terminal xfce4-goodies",
      
      # If you specifically want SDDM, use the --force flag to override the existing lightdm link
      #"echo '${var.password}' | sudo -S DEBIAN_FRONTEND=noninteractive apt-get install -y sddm",
      #"echo '${var.password}' | sudo -S systemctl enable --force sddm"
    ]
  }
  
  # Cleanup
  provisioner "shell" {
    inline = [
      "echo '${var.password}' | sudo -S apt-get clean",
      "echo '${var.password}' | sudo -S apt-get autoclean",
      "echo '${var.password}' | sudo -S apt-get autoremove -y",
      "echo '${var.password}' | sudo -S rm -rf /tmp/* /var/tmp/*",
      "echo '${var.password}' | sudo -S rm -f /etc/ssh/ssh_host_*",
      "echo '${var.password}' | sudo -S ssh-keygen -A"
    ]
  }
  
  # Post-Processor Settings for Vagrant - VirtualBox
  post-processor "vagrant" {
    provider_override   = "virtualbox"
    output              = "kali-linux-virtualbox.box"
    keep_input_artifact = false
    only                = ["virtualbox-iso.kali-linux"]
  }
  
  # Post-Processor Settings for Vagrant - VMware
  post-processor "vagrant" {
    provider_override   = "vmware"
    output              = "kali-linux-vmware.box"
    keep_input_artifact = false
    only                = ["vmware-iso.kali-linux"]
  }
}
