job "vector" {
  name        = "vector"
  type        = "system"
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
        image = "docker.io/timberio/vector:0.48.0-alpine"
        args  = ["-c", "/local/vector.yaml"]
        volumes = ["/dev:/dev"]
        privileged = true
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
          api = {
            enabled = true
          }
          sources = {
            docker = {
              type = "docker_logs"
              exclude_containers = [
                "vector-",
                "nomad_init_",
              ]
            }
            syslog = {
              type = "syslog"
              mode = "unix"
              path = "/dev/log"
            }
          }
          sinks = {
            vlogs = {
              type        = "elasticsearch"
              inputs      = ["docker", "syslog"]
              endpoints   = ["http://logs.matrix.michaelwashere.net:9428/insert/elasticsearch/"]
              api_version = "v8"
              compression = "gzip"
              healthcheck = { enabled = false }
              query = {
                "_time_field" = "timestamp"
                "_stream_fields" = join(",", formatlist("label.com.hashicorp.nomad.%s", [
                  "namespace", "job_name", "task_group_name", "task_name", "alloc_id",
                ]))
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
