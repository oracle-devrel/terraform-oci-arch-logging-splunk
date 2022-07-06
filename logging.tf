## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_logging_log_group" "splunk_network_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = "splunk_network_log_group"
}

/*
    {
      "endpoint": "n/a",
      "id": "flowlogs",
      "name": "Virtual Cloud Network (subnets)",
      "namespace": "n/a",
      "resource-types": [
        {
          "categories": [
            {
              "display-name": "Flow Logs (All records)",
              "name": "all",
              "parameters": []
            }
          ],
          "name": "subnet"
        }
      ],
      "service-principal-name": "n/a",
      "tenant-id": "n/a"
    },

*/

resource "oci_logging_log" "vcn_flow_logs" {
  display_name = "vcn_flow_logs"
  log_group_id = oci_logging_log_group.splunk_network_log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      service     = "flowlogs"
      resource    = !var.use_existing_vcn ? oci_core_subnet.vcn01_compute_subnet[0].id : var.compute_subnet_id
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }
  is_enabled = true
}

/*
    {
      "endpoint": "n/a",
      "id": "loadbalancer",
      "name": "Load Balancers",
      "namespace": "n/a",
      "resource-types": [
        {
          "categories": [
            {
              "display-name": "Access Logs",
              "name": "access",
              "parameters": []
            },
            {
              "display-name": "Error Logs",
              "name": "error",
              "parameters": []
            }
          ],
          "name": "loadbalancer"
        }
      ],
      "service-principal-name": "n/a",
      "tenant-id": "n/a"
    },
*/

resource "oci_logging_log" "loadbalancer_access_logs" {
  display_name = "loadbalancer_access_logs"
  log_group_id = oci_logging_log_group.splunk_network_log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "access"
      service     = "loadbalancer"
      resource    = oci_load_balancer.lb01.id
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }
  is_enabled = true
}

resource "oci_logging_log" "loadbalancer_error_logs" {
  display_name = "loadbalancer_error_logs"
  log_group_id = oci_logging_log_group.splunk_network_log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "error"
      service     = "loadbalancer"
      resource    = oci_load_balancer.lb01.id
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_ocid
  }
  is_enabled = true
}

