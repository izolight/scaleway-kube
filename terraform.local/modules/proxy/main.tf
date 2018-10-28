variable "base_image" {}
variable "cloudinit" {}
variable "nat" {}
variable "net" {}

resource "libvirt_volume" "proxy" {
  name = "proxy_${count.index}.qcow2"
  pool = "images"
  base_volume_id = "${var.base_image}"
  count = 2
}

resource "libvirt_domain" "proxy" {
  name = "proxy_${count.index}"
  memory = "1024"
  vcpu = 1
  count = 2

  cloudinit = "${var.cloudinit}"

  network_interface {
    hostname = "proxy-${count.index}"
    network_name = "${var.nat}"
    wait_for_lease = true
  } 

  network_interface {
    hostname = "proxy-${count.index}"
    network_name = "${var.net}"
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
    volume_id = "${libvirt_volume.proxy.*.id[count.index]}"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}
