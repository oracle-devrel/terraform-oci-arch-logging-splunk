## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_sch_service_connector" "vcn_flow_logs_connector" {
  compartment_id = var.compartment_ocid
  display_name   = "vcn_flow_logs_connector"
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = oci_logging_log_group.splunk_network_log_group.id
      log_id         = oci_logging_log.vcn_flow_logs.id
    }
  }
  target {
    kind      = "streaming"
    stream_id = oci_streaming_stream.splunk_vcn_flow_logs_stream.id
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_sch_service_connector" "loadbalancer_logs_connector" {
  compartment_id = var.compartment_ocid
  display_name   = "loadbalancer_logs_connector"
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = oci_logging_log_group.splunk_network_log_group.id
      log_id         = oci_logging_log.loadbalancer_access_logs.id
    }
    log_sources {
      compartment_id = var.compartment_ocid
      log_group_id   = oci_logging_log_group.splunk_network_log_group.id
      log_id         = oci_logging_log.loadbalancer_error_logs.id
    }
  }
  target {
    kind      = "streaming"
    stream_id = oci_streaming_stream.splunk_lb_logs_connector_stream.id
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
