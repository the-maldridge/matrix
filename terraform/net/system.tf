resource "routeros_system_identity" "identity" {
  name = "vcluster-edge"
}

resource "routeros_ip_dns" "dns" {
  allow_remote_requests = true
  servers               = ["169.254.254.1"]
}

resource "routeros_ip_service" "disabled" {
  for_each = {
    api-ssl = 8729
    api     = 8278
    ftp     = 21
    telnet  = 21
    winbox  = 8291
    www     = 80
  }

  numbers  = each.key
  port     = each.value
  disabled = true
}
