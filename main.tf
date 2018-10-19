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

module "proxy" {
  source = "./modules/proxy"
  base_image = "${libvirt_volume.ubuntu_base.id}"
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"
  nat = "vm_nat"
  net = "vm_private"
}
/*
module "master" {
  source = "./modules/master"
  base_image = "${libvirt_volume.ubuntu_base.id}"
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"
  net = "vm_private"
} */
