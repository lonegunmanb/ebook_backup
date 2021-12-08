variable "image" {
  type = string
}

variable "region" {
  default = "cn-beijing"
}

variable "zone" {
  type    = string
  default = "cn-beijing-c"
}

variable "port" {
  type    = number
  default = 8080
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}