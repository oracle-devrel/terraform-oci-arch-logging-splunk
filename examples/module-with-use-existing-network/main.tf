## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}

terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "arch-logging-splunk" {
  source                   = "github.com/oracle-devrel/terraform-oci-arch-logging-splunk"
  tenancy_ocid             = var.tenancy_ocid
  user_ocid                = var.user_ocid
  fingerprint              = var.fingerprint
  region                   = var.region
  private_key_path         = var.private_key_path
  compartment_ocid         = var.compartment_ocid
  lb_listener_port         = 80
  lb_listener_backend_port = 80
  use_existing_vcn         = true
  vcn_id                   = oci_core_virtual_network.my_vcn.id
  lb_subnet_id             = oci_core_subnet.my_public_subnet.id
  compute_subnet_id        = oci_core_subnet.my_private_subnet.id
}

output "generated_ssh_private_key" {
  value     = module.arch-logging-splunk.generated_ssh_private_key
  sensitive = true
}

