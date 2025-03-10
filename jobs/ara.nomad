job "ara" {
  name = "ara"
  type = "service"
  datacenters = ["MATRIX-CONTROL"]

  group "ara" {
    count = 1

    network {
      mode = "bridge"
      port "http" { to = 8000 }
    }

    service {
      name = "ara"
      port = "http"
      provider = "nomad"
      tags = ["traefik.enable=true"]
    }

    volume "ara_data" {
      type = "host"
      source = "ara_data"
      read_only = false
    }

    task "ara" {
      driver = "docker"

      config {
        image = "docker.io/recordsansible/ara-api:latest"
      }

      env {
        ARA_ALLOWED_HOSTS = "['ara.matrix.michaelwashere.net']"
      }

      volume_mount {
        volume = "ara_data"
        destination = "/opt/ara"
      }
    }
  }
}
