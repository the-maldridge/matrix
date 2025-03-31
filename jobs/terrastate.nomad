job "terrastate" {
  type        = "service"
  datacenters = ["MATRIX-CONTROL"]

  group "terrastate" {
    count = 1

    network {
      mode = "bridge"
      port "http" { to = 8080 }
    }

    service {
      name     = "terrastate"
      port     = "http"
      provider = "nomad"
      tags     = ["traefik.enable=true"]
    }

    volume "terrastate_data" {
      type      = "host"
      source    = "terrastate_data"
      read_only = false
    }

    task "terrastate" {
      driver = "docker"

      config {
        image = "ghcr.io/the-maldridge/terrastate:v1.2.1"
        init  = true
      }

      env {
        TS_AUTH          = "htpasswd"
        TS_BITCASK_PATH  = "/data"
        TS_HTGROUP_FILE  = "/secrets/.htgroup"
        TS_HTPASSWD_FILE = "/secrets/.htpasswd"
        TS_STORE         = "bitcask"
      }

      volume_mount {
        volume      = "terrastate_data"
        destination = "/data"
        read_only   = false
      }

      template {
        data        = <<EOF
{{ with nomadVar "nomad/jobs/terrastate" }}
maldridge:{{ .maldridge_passwd }}
_terraform:{{ .terraform_passwd }}
{{ end }}
EOF
        destination = "${NOMAD_SECRETS_DIR}/.htpasswd"
      }

      template {
        data        = <<EOF
terrastate-tls: maldridge,_terraform
terrastate-routeros: maldridge
terrastate-nomad: maldridge
EOF
        destination = "${NOMAD_SECRETS_DIR}/.htgroup"
      }
    }
  }
}
