variable "image" {}

variable "type" {}

variable "domain" {}

resource "scaleway_server" "nodes" {
    count   = "3"
    image   = "${var.image}"
    type    = "${var.type}"
    name    = "node-${count.index}"
    boot_type = "local"
    dynamic_ip_required = true
    enable_ipv6 = true

    tags = ["node"]
    
    volume = {
        type = "l_ssd"
        size_in_gb = 50
    }
}

resource "digitalocean_record" "nodes" {
    count       = "3"
    domain      = "${var.domain}"
    type        = "CNAME"
    name        = "node-${count.index}"
    value       = "${scaleway_server.nodes.*.id[count.index]}.pub.cloud.scaleway.com."
    ttl         = "3600"
}

resource "digitalocean_record" "nodes_int" {
    count       = "3"
    domain      = "${var.domain}"
    type        = "CNAME"
    name        = "node-${count.index}.int"
    value       = "${scaleway_server.nodes.*.id[count.index]}.priv.cloud.scaleway.com."
    ttl         = "3600"
}
