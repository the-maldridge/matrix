job "vmlogs" {
  name = "vmlogs"
  type = "service"
  datacenters = ["MATRIX-CONTROL"]

  group "vmlogs" {
    count = 1

    network {
      mode = "bridge"
      port "http" { to = 9428 }
      port "syslog" { to = 514 }
    }

    service {
      name = "logs"
      port = "http"
      provider = "nomad"
      tags = ["traefik.enable=true"]
    }

    volume "vmlogs_data" {
      type = "host"
      source = "vmlogs_data"
      read_only = "false"
    }

    task "vmlogs" {
      driver = "docker"

      config {
        image = "docker.io/victoriametrics/victoria-logs:v1.15.0-victorialogs"
        args = [
          "-storageDataPath=/data",
          "-syslog.listenAddr.tcp=:514",
          "-syslog.listenAddr.udp=:514",
        ]
      }

      volume_mount {
        volume = "vmlogs_data"
        destination = "/data"
      }
    }
  }
}
