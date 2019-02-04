provider "libvirt" {
  uri = "qemu:///system"
}

# Network definition

resource "libvirt_network" "network" {
  name      = "kubernetes"
  addresses = ["192.168.42.0/24"]
  mode      = "nat"

  dhcp {
    enabled = true
  }
}

