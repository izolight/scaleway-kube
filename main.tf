provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_base" {
  name = "ubuntu_base"
  pool = "images"
  #source = "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
  source = "/home/gabor/Downloads/ubuntu-18.04-server-cloudimg-amd64.img"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "images"
  user_data = <<EOF
  #cloud-config
  users:
    - name: root
      ssh_authorized_keys:
        - 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrdYWNgSIGvsLJ1vlK1fEweBipAVv7JBGu0O+o6zhpE'
  EOF
}

resource "libvirt_network" "vm_nat" {
  name = "vm_nat"
  mode = "nat"
  addresses = ["10.0.100.0/24"]
}

resource "libvirt_network" "vm_private" {
  name = "vm_private"
  mode = "none"
  addresses = ["10.0.200.0/24"]
}

module "proxy" {
  source = "./modules/proxy"
  base_image = "${libvirt_volume.ubuntu_base.id}"
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"
  nat = "${libvirt_network.vm_nat.id}"
  net = "${libvirt_network.vm_private.id}"
}
/*
module "master" {
  source = "./modules/master"
  base_image = "${libvirt_volume.ubuntu_base.id}"
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"
  net = "${libvirt_network.vm_private.id}"
} */
