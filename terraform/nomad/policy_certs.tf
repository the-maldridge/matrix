resource "nomad_acl_policy" "certs_admin" {
  name        = "certs-admin"
  description = "Manage certificates in Nomad variables"

  job_acl {
    namespace = "default"
    job_id    = "cert-renew"
  }

  rules_hcl = <<EOT
namespace "default" {
  variables {
    path "nomad/jobs/proxy" {
      capabilities = ["read", "write"]
    }
  }
}
EOT
}
