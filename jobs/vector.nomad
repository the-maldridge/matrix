job "vector" {
  name = "vector"
  type = "system"
  datacenters = ["MATRIX", "MATRIX-CONTROL"]

  group "vector" {
    count = 1

    network {
      mode = "bridge"
    }

    volume "dockersocket" {
      type      = "host"
      source    = "dockersocket"
      read_only = true
    }

    task "vector" {
      driver = "docker"

      config {
        image = "docker.io/timberio/vector:0.45.0-alpine"
        args = ["-c", "/local/vector.yaml"]
      }

      resources {
        memory = 150
      }

      volume_mount {
        volume      = "dockersocket"
        destination = "/var/run/docker.sock"
        read_only   = true
      }

      template {
        data = yamlencode({
          sources = {
            docker = {
              type = "docker_logs"
              exclude_containers = [
                "vector-",
                "nomad_init_",
              ]
            }
          }
          sinks = {
            vlogs = {
              type = "elasticsearch"
              inputs = ["docker"]
              endpoints = ["http://logs.matrix.michaelwashere.net/insert/elasticsearch/"]
              api_version = "v8"
              compression = "gzip"
              healthcheck = { enabled = false }
              query = {
                "_time_field" = "timestamp"
                "_stream_fields" = "label.com.hashicorp.nomad.namespace,label.com.hashicorp.nomad.job_name,label.hashicorp.nomad.task_group_name,label.com.hashicorp.nomad.task_name,label.com.hashicorp.nomad.alloc_id"
                "_msg_field" = "message"
              }
            }
          }
        })
        destination = "local/vector.yaml"
      }
    }
  }
}
