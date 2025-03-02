resource "routeros_routing_bgp_connection" "internal" {
  for_each = {
    core = "169.254.255.1"
  }

  as   = 64579
  name = each.key

  connect        = true
  listen         = true
  nexthop_choice = "force-self"

  cluster_id = "169.254.255.1"
  router_id  = "169.254.255.2"

  hold_time      = "30s"
  keepalive_time = "10s"

  local {
    role    = "ibgp"
    address = "169.254.255.2"
  }

  remote {
    address = each.value
  }

  output {
    default_originate = "if-installed"
    redistribute      = "connected"
  }
}
