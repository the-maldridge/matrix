# The Matrix

Welcome to the Matrix.  This is a test cluster based on Hashicorp
Nomad that can be built, reset, and rebuilt again at will.  This repo
is broadly split up on the following lines:

## `ansible/`

Machine level configuration that sets up the bare-metal services and
other configuration on-host.  This directory can be used to generate a
fully self-contained docker image that can apply `ansible` at a
specific repo.

## `containers/`

The cluster contains a handful of custom containers that host boot
time network services.

## `jobs/`

A collection of Nomad jobspec files that define the base services in
the cluster.

## `terraform/`

There are several terraform workspaces running within the cluster
which relate to the network, the nomad control plane, and the TLS
certificate pipeline.
