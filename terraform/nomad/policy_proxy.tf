resource "nomad_acl_policy" "proxy" {
  name = "proxy-read"
  job_acl {
    namespace = "default"
    job_id    = "proxy"
  }

  rules_hcl = <<EOT
namespace "*" {
  policy = "read"
}
EOT
}
