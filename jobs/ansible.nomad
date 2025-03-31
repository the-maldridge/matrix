job "ansible" {
  name        = "ansible"
  type        = "sysbatch"
  datacenters = ["MATRIX-CONTROL", "MATRIX"]

  parameterized {
    payload       = "forbidden"
    meta_required = ["COMMIT", "ANSIBLE_PLAYBOOK"]
    meta_optional = []
  }

  group "ansible" {
    count = 1

    network { mode = "host" }

    task "ansible" {
      driver = "docker"
      config {
        image        = "registry.matrix.michaelwashere.net:5000/ansible/ansible:${NOMAD_META_COMMIT}"
        network_mode = "host"
        privileged   = true
        command      = "/ansible/venv/bin/ansible-playbook"
        args = [
          "-D", "${NOMAD_META_ANSIBLE_PLAYBOOK}",
          "-c", "community.general.chroot",
          "-e", "ansible_host=/host",
          "--limit", "${node.unique.name}",
        ]
        volumes = ["/:/host"]
      }
    }
  }
}
