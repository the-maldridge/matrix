job "netinst" {
  name        = "netinst"
  datacenters = ["MATRIX-CONTROL"]
  type        = "service"

  group "pxe" {
    count = 1

    network {
      mode = "host"
    }

    task "pxe" {
      driver = "docker"

      config {
        image        = "registry.matrix.michaelwashere.net:5000/netinst/pxe:1"
        force_pull   = true
        network_mode = "host"
        cap_add      = ["NET_ADMIN", "NET_RAW"]
      }
    }
  }

  group "shoelaces" {
    count = 1
    network {
      mode = "bridge"
      port "http" { static = 8081 }
    }

    service {
      name     = "shoelaces"
      port     = "http"
      provider = "nomad"
      tags     = ["traefik.enable=true"]
    }

    task "shoelaces" {
      driver = "docker"

      config {
        image      = "registry.matrix.michaelwashere.net:5000/netinst/shoelaces:1"
        force_pull = true
        args       = ["-bind-addr=0.0.0.0:8081", "-base-url=${NOMAD_IP_http}:8081"]
      }
    }
  }
}
