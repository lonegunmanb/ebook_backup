output "public_ip" {
  value = alicloud_eip.ebook.ip_address
}

output "password" {
  sensitive = true
  value     = random_password.pass.result
}