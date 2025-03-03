terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
  }
}

provider "nomad" {
  address = "http://matrix-core.matrix.michaelwashere.net:4646"
}

