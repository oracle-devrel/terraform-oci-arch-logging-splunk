## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Checks if is using Flexible LB Shapes
locals {
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}

resource "oci_load_balancer" "lb01" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  compartment_id = var.compartment_ocid

  subnet_ids = [
    !var.use_existing_vcn ? oci_core_subnet.vcn01_lb_subnet[0].id : var.lb_subnet_id,
  ]

  display_name = "load_balancer_01"
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_load_balancer_backend_set" "lb_be" {
  name             = "lb_app01"
  load_balancer_id = oci_load_balancer.lb01.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.lb_listener_backend_port
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_listener" {
  load_balancer_id         = oci_load_balancer.lb01.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb_be.name
  port                     = var.lb_listener_port
  protocol                 = "HTTP"

}

resource "oci_load_balancer_backend" "lb_be_webserver" {
  count            = var.numberOfNodes
  load_balancer_id = oci_load_balancer.lb01.id
  backendset_name  = oci_load_balancer_backend_set.lb_be.name
  ip_address       = oci_core_instance.webserver[count.index].private_ip
  port             = var.lb_listener_backend_port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

