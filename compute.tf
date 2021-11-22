## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.InstanceShape)
}

resource "oci_core_instance" "webserver" {
  count               = var.numberOfNodes
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availablity_domain_number]["name"] : var.availablity_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "webserver-${count.index}"
  fault_domain        = "FAULT-DOMAIN-${(count.index % 3) + 1}"
  shape               = var.InstanceShape

  create_vnic_details {
    subnet_id        = oci_core_subnet.vcn01_compute_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = false
  }

  source_details {
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
    boot_volume_size_in_gbs = "50"
  }

  provisioner "local-exec" {
    command = "sleep 240"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.InstanceFlexShapeMemory
      ocpus         = var.InstanceFlexShapeOCPUS
    }
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

