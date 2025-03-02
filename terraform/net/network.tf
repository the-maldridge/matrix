resource "routeros_interface_bridge" "br0" {
  name           = "br0"
  vlan_filtering = true
  frame_types    = "admit-only-vlan-tagged"
}

resource "routeros_interface_vlan" "vlan" {
  for_each = {
    lan0  = { id = 10, description = "Local Network" }
    wan0  = { id = 20, description = "Upstream Networks" }
    peer0 = { id = 101, description = "Peer Networks" }
  }

  interface = routeros_interface_bridge.br0.name
  name      = each.key
  comment   = each.value.description
  vlan_id   = each.value.id
}

resource "routeros_interface_bridge_vlan" "br_vlan" {
  bridge   = routeros_interface_bridge.br0.name
  vlan_ids = [for s in sort(formatlist("%03d", [for vlan in routeros_interface_vlan.vlan : vlan.vlan_id])) : tonumber(s)]
  tagged   = [routeros_interface_bridge.br0.name]
  comment  = "Bridge Networks"
}

resource "routeros_ip_address" "local" {
  address   = "192.168.32.1/24"
  interface = routeros_interface_vlan.vlan["lan0"].name
}

resource "routeros_ip_address" "peer" {
  address   = "169.254.255.2/24"
  interface = routeros_interface_vlan.vlan["peer0"].name
}
