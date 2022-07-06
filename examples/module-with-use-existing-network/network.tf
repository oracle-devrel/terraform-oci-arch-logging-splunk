## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_virtual_network" "my_vcn" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "myvcn"
  dns_label      = "myvcn"
}

resource "oci_core_nat_gateway" "my_nat_gw" {
  compartment_id = var.compartment_ocid
  display_name   = "nat_gateway"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "my_igw"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_route_table" "my_rt_pub" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_rt_pub"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.my_igw.id
  }
}

resource "oci_core_route_table" "my_rt_priv" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "my_rt_priv"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.my_nat_gw.id
  }
}

resource "oci_core_security_list" "my_http_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "my_httpx_sec_list"
  vcn_id         = oci_core_virtual_network.my_vcn.id

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
    source   = "192.168.0.0/16"
  }
}

resource "oci_core_subnet" "my_public_subnet" {
  cidr_block        = "192.168.1.0/24"
  display_name      = "my_public_subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.my_vcn.id
  dhcp_options_id   = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  security_list_ids = [oci_core_security_list.my_http_sec_list.id]
  route_table_id    = oci_core_route_table.my_rt_pub.id
  dns_label         = "pubsub"
}

resource "oci_core_subnet" "my_private_subnet" {
  cidr_block                 = "192.168.2.0/24"
  display_name               = "my_private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  route_table_id             = oci_core_route_table.my_rt_priv.id
  security_list_ids          = [oci_core_security_list.my_http_sec_list.id]
  prohibit_public_ip_on_vnic = true
  dns_label                  = "privsub"
}

