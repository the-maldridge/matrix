terraform {
  backend "http" {
    address = "http://terrastate.matrix.michaelwashere.net/state/routeros/main"
    lock_address = "http://terrastate.matrix.michaelwashere.net/state/routeros/main"
    unlock_address = "http://terrastate.matrix.michaelwashere.net/state/routeros/main"
  }
}
