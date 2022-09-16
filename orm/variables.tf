## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.1"
}

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
#variable "fingerprint" {}
#variable "user_ocid" {}
#variable "private_key_path" {}
variable "availability_domain_name" {
  default = ""
}

variable "availability_domain_number" {
  default = 0
}

variable "use_existing_vcn" {
  default = false
}

variable "vcn_id" {
  default = ""
}

variable "lb_subnet_id" {
  default = ""
}

variable "compute_subnet_id" {
  default = ""
}

variable "ssh_public_key" {
  default = ""
}

variable "numberOfNodes" {
  default = 2
}

variable "igw_display_name" {
  default = "internet-gateway"
}

variable "vcn01_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vcn01_lb_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vcn01_compute_subnet_cidr_block" {
  default = "10.0.2.0/24"
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "lb_listener_port" {
  default = 80
}

variable "lb_listener_backend_port" {
  default = 8080
}

variable "InstanceShape" {
  default = "VM.Standard.E3.Flex"
}

variable "InstanceFlexShapeOCPUS" {
  default = 1
}

variable "InstanceFlexShapeMemory" {
  default = 1
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "9"
}
