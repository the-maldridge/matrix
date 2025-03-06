resource "routeros_ip_pool" "pool" {
  name    = "pool"
  ranges  = ["192.168.32.2-192.168.32.240"]
  comment = "LAN Default IP Pool"
}

resource "routeros_ip_dhcp_server" "server" {
  interface          = routeros_interface_vlan.vlan["lan0"].name
  name               = "LAN"
  address_pool       = routeros_ip_pool.pool.name
  comment            = "LAN Default DHCP Server"
  conflict_detection = true
  lease_time         = "1h"
}

resource "routeros_ip_dhcp_server_network" "network" {
  address    = "192.168.32.0/24"
  comment    = "Options for LAN"
  gateway    = "192.168.32.1"
  domain     = "matrix.michaelwashere.net"
  dns_server = ["192.168.32.1"]
}

##############################
# Static Host Configurations #
##############################

variable "static_hosts" {
  type = map(object({
    mac   = string
    addr  = string
    cname = optional(set(string), [])
  }))
  description = "Map of static hosts"
  default     = {}
}

resource "routeros_ip_dhcp_server_lease" "lease" {
  for_each = var.static_hosts

  address     = each.value.addr
  mac_address = each.value.mac
  comment     = each.key
  server      = routeros_ip_dhcp_server.server.name
}

resource "routeros_ip_dns_record" "static_hosts" {
  for_each = var.static_hosts

  name    = format("%s.%s", each.key, "matrix.michaelwashere.net")
  address = each.value.addr
  type    = "A"
}

resource "routeros_ip_dns_record" "static_cnames" {
  for_each = merge([for host, data in var.static_hosts : { for cname in data.cname : cname => host } if length(data.cname) > 0]...)

  name  = format("%s.%s", each.key, "matrix.michaelwashere.net")
  type  = "CNAME"
  cname = format("%s.%s", each.value, "matrix.michaelwashere.net")
}

resource "routeros_ip_dns_record" "self" {
  for_each = toset([
    "edge",
    "net-available",
  ])

  name    = format("%s.%s", each.key, "matrix.michaelwashere.net")
  address = split("/", routeros_ip_address.local.address)[0]
  type    = "A"
}
