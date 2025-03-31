job "proxy" {
  name        = "proxy"
  datacenters = ["MATRIX-CONTROL"]
  type        = "system"

  group "traefik" {
    network {
      mode = "bridge"
      port "http" { static = 80 }
      port "metrics" { static = 8080 }
    }

    service {
      port     = "http"
      provider = "nomad"
      tags = [
        "traefik.http.routers.dashboard.rule=Host(`proxy.matrix.michaelwashere.net`)",
        "traefik.http.routers.dashboard.service=api@internal",
      ]
    }

    task "traefik" {
      driver = "docker"

      identity {
        env         = true
        change_mode = "restart"
      }

      config {
        image = "traefik:v3.3.4"

        args = [
          "--accesslog=false",
          "--api.dashboard",
          "--entrypoints.http.address=:80",
          "--metrics.prometheus",
          "--ping=true",
          "--providers.nomad.refreshInterval=30s",
          "--providers.nomad.endpoint.address=unix://${NOMAD_SECRETS_DIR}/api.sock",
          "--providers.nomad.defaultRule=Host(`{{ .Name }}.matrix.michaelwashere.net`)",
          "--providers.file.filename=/local/config.yaml",
        ]
      }

      template {
        data = yamlencode({
          http = {
            services = {
              nomad = {
                loadBalancer = {
                  servers = [
                    { url = "http://172.26.64.1:4646" },
                  ]
                }
              }
            }
            routers = {
              nomad = {
                rule    = "Host(`nomad.matrix.michaelwashere.net`)"
                service = "nomad"
              }
            }
          }
        })
        destination = "local/config.yaml"
      }
    }
  }
}
