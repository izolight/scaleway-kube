variable "lb_type" {
  default = "START1-XS"
}

variable "master_type" {
  default = "START1-S"
}

variable "node_type" {
  default = "START1-M"
}

variable "domain" {}

variable "architectures" {
  default = {
    C1   = "arm"
    C2S  = "x86_64"
    C2M  = "x86_64"
    C2L  = "x86_64"
    START1-XS = "x64_64" 
    START1-S = "x64_64" 
    START1-M = "x64_64" 
    START1-L = "x64_64" 
  }
}

data "scaleway_image" "ubuntu" {
    architecture    = "${lookup(var.architectures, var.commercial_type)}"
    name            = "Ubuntu Xenial"
}

provider "scaleway" {
    region  = "par1"
}

provider "digitalocean" {}

module "lb" {
    source  = "./modules/lb"

    domain  = "${var.domain}"
    type    = "${var.lb_type}"
    image   = "${data.scaleway_image.ubuntu.id}"
}

module "master" {
    source  = "./modules/master"

    domain  = "${var.domain}"
    type    = "${var.master_type}"
    image   = "${data.scaleway_image.ubuntu.id}"
}

#module "node" {
#    source  = "./modules/node"
#
#    domain  = "${var.domain}"
#    type    = "${var.node_type}"
#    image   = "${data.scaleway_image.ubuntu.id}"   
#}
