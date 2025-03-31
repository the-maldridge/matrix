terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.31.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
  }

  backend "http" {
    address        = "http://terrastate.matrix.michaelwashere.net/state/tls/main"
    lock_address   = "http://terrastate.matrix.michaelwashere.net/state/tls/main"
    unlock_address = "http://terrastate.matrix.michaelwashere.net/state/tls/main"
  }
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "nomad" {}

resource "acme_registration" "reg" {
  email_address = "maldridge@michaelwashere.net"
}

resource "acme_certificate" "cert" {
  account_key_pem           = acme_registration.reg.account_key_pem
  pre_check_delay           = 30
  common_name               = "matrix.michaelwashere.net"
  subject_alternative_names = ["*.matrix.michaelwashere.net"]

  dns_challenge {
    provider = "namecheap"
  }

  recursive_nameservers = ["1.1.1.1"]
}

resource "nomad_variable" "tls" {
  for_each = {
    "nomad/jobs/proxy" = "default"
  }

  path      = each.key
  namespace = each.value

  items = {
    certificate = "${acme_certificate.cert.certificate_pem}${acme_certificate.cert.issuer_pem}"
    key         = acme_certificate.cert.private_key_pem
  }
}
