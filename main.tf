provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_base" {
  name = "ubuntu_base"
  pool = "images"
  source = "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "proxy" {
  name = "proxy_${count.index}.qcow2"
  pool = "images"
  base_volume_id = "${libvirt_volume.ubuntu_base.id}"
  count = 2
}

resource "libvirt_volume" "master" {
  name = "master_${count.index}.qcow2"
  pool = "images"
  base_volume_id = "${libvirt_volume.ubuntu_base.id}"
  count = 3
}

resource "libvirt_network" "vm_nat" {
  name = "vm_nat"
  mode = "nat"
  addresses = ["10.0.100.0/24"]
  dhcp {
    enabled = true
  }
}

resource "libvirt_network" "vm_private" {
  name = "vm_private"
  mode = "none"
  addresses = ["10.0.200.0/24"]
  dhcp {
    enabled = true
  }
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

resource "libvirt_domain" "proxy" {
  name = "proxy_${count.index}"
  memory = "1024"
  vcpu = 1
  count = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
  [
    hostname = "proxy-${count.index}"
    network_id = "${libvirt_network.vm_nat.id}"
    wait_for_lease = true
  , 
    hostname = "proxy-${count.index}"
    network_id = "${libvirt_network.vm_private.id}"
    wait_for_lease = true
  ]
  }

  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type = "pty"
    target_port = "1"
    target_type = "virtio"
  }

  disk {
    volume_id = "${libvirt_volume.proxy.*.id[count.index]}"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

resource "libvirt_domain" "master" {
  name = "master_${count.index}"
  memory = "2048"
  vcpu = 2
  count = 3

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    hostname = "master-${count.index}"
    network_id = "${libvirt_network.vm_private.id}"
    wait_for_lease = true
  }

  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type = "pty"
    target_port = "1"
    target_type = "virtio"
  }

  disk {
    volume_id = "${libvirt_volume.master.*.id[count.index]}"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

output "ip" {
  value = "${formatlist("%v: %v", libvirt_domain.proxy.*.name, libvirt_domain.proxy.*.network_interface.0.addresses.0)}"
}
