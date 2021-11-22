## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn01" {
  cidr_block     = var.vcn01_cidr_block
  dns_label      = "vcn01"
  compartment_id = var.compartment_ocid
  display_name   = "vcn01"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#IGW
resource "oci_core_internet_gateway" "vcn01_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  enabled        = "true"
  display_name   = "vcn01_internet_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "vcn01_nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_nat_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#Default route table vcn01
resource "oci_core_default_route_table" "vcn01_default_route_table" {
  manage_default_resource_id = oci_core_vcn.vcn01.default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#Default security list
resource "oci_core_default_security_list" "vcn01_default_security_list" {
  manage_default_resource_id = oci_core_vcn.vcn01.default_security_list_id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "vnc01_nat_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vnc01_nat_route_table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.vcn01_nat_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


#vcn01 loadbalancer subnet
resource "oci_core_subnet" "vcn01_lb_subnet" {
  cidr_block     = var.vcn01_subnet_pub01_cidr_block
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01.id
  display_name   = "vcn01_lb_subnet"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 compute subnet
resource "oci_core_subnet" "vcn01_compute_subnet" {
  cidr_block                 = var.vcn01_subnet_pub02_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn01.id
  display_name               = "vcn01_compute_subnet"
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  prohibit_public_ip_on_vnic = true
}






