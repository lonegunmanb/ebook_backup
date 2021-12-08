terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.146.0"
    }
  }
}

provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = "ebook-vpc"
  cidr_block = "10.0.0.0/16"
}

resource "alicloud_vswitch" "subnet" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  zone_id    = var.zone
}

resource "alicloud_security_group" "group" {
  vpc_id = alicloud_vpc.vpc.id
  name   = "ebook"
}

resource "alicloud_security_group_rule" "ebook_port" {
  ip_protocol       = "tcp"
  security_group_id = alicloud_security_group.group.id
  type              = "ingress"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${var.port}/${var.port}"
  cidr_ip           = "0.0.0.0/0"
}

resource "random_password" "pass" {
  length  = 20
  special = true
}

resource "alicloud_eci_container_group" "example" {
  container_group_name = "ebookserver"
  cpu                  = 0.25
  memory               = 0.5
  restart_policy       = "Never"
  security_group_id    = alicloud_security_group.group.id
  vswitch_id           = alicloud_vswitch.subnet.id

  containers {
    image             = var.image
    name              = "ebook"
    cpu               = 0.25
    memory            = 0.5
    image_pull_policy = "Always"
    args              = ["--password=${bcrypt(random_password.pass.result)}", "--port=${var.port}"]
    ports {
      port     = 8080
      protocol = "TCP"
    }
  }
}

resource "alicloud_eip_association" "ebook" {
  allocation_id = alicloud_eip.ebook.id
  instance_id   = alicloud_eci_container_group.example.id
}

resource "alicloud_eip" "ebook" {
  internet_charge_type = "PayByTraffic"
  bandwidth            = "100"
}