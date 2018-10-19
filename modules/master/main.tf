variable "base_image" {}
variable "cloudinit" {}
variable "net" {}

resource "libvirt_volume" "master" {
  name = "master_${count.index}.qcow2"
  pool = "images"
  base_volume_id = "${var.base_image}"
  count = 3
}

resource "libvirt_domain" "master" {
  name = "master_${count.index}"
  memory = "2048"
  vcpu = 2
  count = 3

  cloudinit = "${var.cloudinit}"

  network_interface {
    hostname = "master-${count.index}"
    addresses = ["10.0.200.2${count.index}"]
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
    volume_id = "${libvirt_volume.master.*.id[count.index]}"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}
