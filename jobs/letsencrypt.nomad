job "cert-renew" {
  datacenters = ["MATRIX-CONTROL", "MATRIX"]
  type = "batch"

  periodic {
    crons = ["@weekly"]
  }

  group "terraform" {
    count = 1

    network { mode = "bridge" }

    task "terraform" {
      driver = "docker"

      config {
        image = "registry.matrix.michaelwashere.net:5000/terraform/tls:e744e60"
      }

      identity { env = true }

      env {
        TF_HTTP_USERNAME="_terraform"
        NOMAD_ADDR="unix://${NOMAD_SECRETS_DIR}/api.sock"
      }

      template {
        data = <<EOT
{{ with nomadVar "nomad/jobs/cert-renew" }}
TF_HTTP_PASSWORD="{{ .terraform_password }}"
NAMECHEAP_API_USER="{{ .namecheap_api_user }}"
NAMECHEAP_API_KEY="{{ .namecheap_api_key }}"
{{ end }}
EOT
        destination = "${NOMAD_SECRETS_DIR}/env"
        env = true
      }
    }
  }
}
