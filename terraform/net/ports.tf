locals {
  ports = {
    wan  = ["ether1"]
    lan  = formatlist("ether%s", [6, 7, 8, 9, 10])
    peer = formatlist("ether%s", [2, 3, 4, 5])
  }
}

resource "routeros_interface_bridge_port" "physical" {
  for_each = transpose(local.ports)

  bridge    = routeros_interface_bridge.br0.name
  interface = each.key
  pvid      = routeros_interface_vlan.vlan[format("%s0", one(each.value))].vlan_id
}
