terraform {
  backend "http" {
    address = "http://terrastate.matrix.michaelwashere.net/state/nomad/main"
    lock_address = "http://terrastate.matrix.michaelwashere.net/state/nomad/main"
    unlock_address = "http://terrastate.matrix.michaelwashere.net/state/nomad/main"
  }
}
