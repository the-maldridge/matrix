job "zot" {
  name = "zot"
  type = "service"
  datacenters = ["MATRIX-CONTROL"]

  group "zot" {
    count = 1

    network {
      mode = "bridge"
      port "http" { static = 5000 }
    }

    service {
      name = "registry"
      port = "http"
      provider = "nomad"
      tags = ["traefik.enable=true"]
    }

    volume "zot_data" {
      type = "host"
      source = "zot_data"
      read_only = false
    }

    task "zot" {
      driver = "docker"

      config {
        image = "ghcr.io/project-zot/zot-linux-amd64:v2.1.2"
        args = ["serve", "/local/config.json"]
      }

      volume_mount {
        volume = "zot_data"
        destination = "/data"
      }

      template {
        data = jsonencode({
          distSpecVersion = "1.1.1"
          storage = {
            rootDirectory = "/data"
          }
          http = {
            address = "0.0.0.0"
            port = 5000
            compat = ["docker2s2"]
          }
          extensions = {
            search = { enable = true }
            ui = { enable = true }
          }
        })
        destination = "local/config.json"
      }
    }
  }
}
