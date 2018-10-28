variable "image" {}

variable "type" {}

variable "domain" {}

resource "scaleway_ip" "lb" {
    count = 1
    server = "${scaleway_server.lb.*.id[0]}"
}

resource "scaleway_server" "lb" {
    count = 2
    image   = "${var.image}"
    type    = "${var.type}"
    boot_type = "local"
    name    = "lb"
    enable_ipv6 = true

    tags = ["lb"]
}

resource "digitalocean_record" "lb_main" {
    domain      = "${var.domain}"
    type        = "A"
    name        = "lb"
    value       = "${scaleway_ip.lb.ip}"
    ttl         = "3600"
}

resource "digitalocean_record" "lb_int" {
    count	= "2"
    domain      = "${var.domain}"
    type        = "CNAME"
    name        = "lb-${count.index}.int"
    value       = "${scaleway_server.lb.*.id[count.index]}.priv.cloud.scaleway.com."
    ttl         = "3600"
}

resource "digitalocean_record" "lb" {
    count	= "2"
    domain      = "${var.domain}"
    type        = "CNAME"
    name        = "lb-${count.index}"
    value       = "${scaleway_server.lb.*.id[count.index]}.pub.cloud.scaleway.com."
    ttl         = "3600"
}
