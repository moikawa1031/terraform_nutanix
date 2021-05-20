#URL
#https://registry.terraform.io/providers/nutanix/nutanix/latest

terraform {
  required_providers {
    nutanix = {
      source = "nutanix/nutanix"
    }
  }
 required_version = ">= 0.13"
}

provider "nutanix" {
  username = "admin"
  password = "xxxxxx"
  endpoint = "192.168.51.20"
  insecure = true
  port     = 9440
}

data "nutanix_clusters" "clusters" {}

resource "nutanix_virtual_machine" "vm" {
  name        = "vm01-tf"
  cluster_uuid = data.nutanix_clusters.clusters.entities.0.metadata.uuid
  description = "Terraform test VM."
  num_vcpus_per_socket = 1
  num_sockets          = 1
  memory_size_mib      = 2048

#admin@NTNX-SGH103SLF3-A-CVM:192.168.51.22:~$ acli net.list
#Network name  Network UUID                          Type      Identifier  Subnet
#vlan_51       6718a9c7-a32a-4cfc-9b03-cd11bb2e2336  kBridged  0           192.168.51.0/24
  
  nic_list {
      subnet_uuid = "6718a9c7-a32a-4cfc-9b03-cd11bb2e2336"
  }

#admin@NTNX-SGH103SLF3-A-CVM:192.168.51.22:~$ acli image.list
#Image name   Image type  Image UUID
#CentOS7      kDiskImage  fc7a1647-4a18-4a09-b640-2cdd41da6b2a
  
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = "87c5c22f-5277-444a-b94d-6966c05547c5"
    }
  }

  disk_list {
    disk_size_bytes = 10 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }

}
