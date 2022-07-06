## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn01" {
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.vcn01_cidr_block
  dns_label      = "vcn01"
  compartment_id = var.compartment_ocid
  display_name   = "vcn01"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#IGW
resource "oci_core_internet_gateway" "vcn01_internet_gateway" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  enabled        = "true"
  display_name   = "vcn01_internet_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "vcn01_nat_gateway" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "vcn01_nat_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#Default route table vcn01
resource "oci_core_default_route_table" "vcn01_default_route_table" {
  count                      = !var.use_existing_vcn ? 1 : 0
  manage_default_resource_id = oci_core_vcn.vcn01[0].default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.vcn01_internet_gateway[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#Default security list
resource "oci_core_default_security_list" "vcn01_default_security_list" {
  count                      = !var.use_existing_vcn ? 1 : 0
  manage_default_resource_id = oci_core_vcn.vcn01[0].default_security_list_id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "vnc01_nat_route_table" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn01[0].id
  display_name   = "vcn01_nat_route_table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.vcn01_nat_gateway[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "vnc01_public_sec_list" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "vnc01_public_sec_list"
  vcn_id         = oci_core_vcn.vcn01[0].id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_security_list" "vnc01_private_sec_list" {
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "vnc01_public_sec_list"
  vcn_id         = oci_core_vcn.vcn01[0].id

  egress_security_rules {
    protocol    = "6"
    destination = var.vcn01_lb_subnet_cidr_block
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = 8080
      min = 8080
    }
  }
}

#vcn01 loadbalancer subnet
resource "oci_core_subnet" "vcn01_lb_subnet" {
  count             = !var.use_existing_vcn ? 1 : 0
  cidr_block        = var.vcn01_lb_subnet_cidr_block
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.vcn01[0].id
  security_list_ids = [oci_core_security_list.vnc01_public_sec_list[0].id]
  display_name      = "vcn01_lb_subnet"
  defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#vcn01 compute subnet
resource "oci_core_subnet" "vcn01_compute_subnet" {
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.vcn01_compute_subnet_cidr_block
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.vcn01[0].id
  security_list_ids          = [oci_core_security_list.vnc01_private_sec_list[0].id]
  display_name               = "vcn01_compute_subnet"
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  prohibit_public_ip_on_vnic = true
}






