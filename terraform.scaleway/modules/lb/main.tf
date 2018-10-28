variable "image" {}

variable "type" {}

variable "domain" {}

resource "scaleway_ip" "lb" {
    count = 2
}

resource "scaleway_server" "lb" {
    image   = "${var.image}"
    type    = "${var.type}"
    boot_type = "local"
    name    = "lb"
    enable_ipv6 = true
    public_ip = "${element(scaleway_ip.lb.*.ip, count.index)}"

    tags = ["lb"]
}

resource "digitalocean_record" "lb_main" {
    domain      = "${var.domain}"
    type        = "CNAME"
    name        = "lb"
    value       = "${scaleway_server.lb.*.id[count.index]}.pub.cloud.scaleway.com."
    ttl         = "3600"
}

resource "digitalocean_record" "lb_int" {
    domain      = "${var.domain}"
    type        = "CNAME"
    name        = "lb.int"
    value       = "${scaleway_server.lb.*.id[count.index]}.priv.cloud.scaleway.com."
    ttl         = "3600"
}
