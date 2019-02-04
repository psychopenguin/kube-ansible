# Cloud init templates

data "template_file" "user_data_master" {
  count    = "${var.master["count"]}"
  template = "${file("${path.module}/cloud_init.cfg")}"

  vars {
    hostname = "${var.master["base_name"]}-${count.index}"
  }
}

resource "libvirt_cloudinit_disk" "master" {
  count     = "${var.master["count"]}"
  pool      = "vm_images"
  name      = "${var.master["base_name"]}-${count.index}-cloud_init.iso"
  user_data = "${element(data.template_file.user_data_master.*.rendered, count.index)}"
}

# Root disk for each instance

resource "libvirt_volume" "master" {
  count            = "${var.master["count"]}"
  pool             = "vm_images"
  base_volume_name = "bionic.img"
  base_volume_pool = "isos"
  size             = "${var.master["disksize"]}"
  name             = "${var.master["base_name"]}-${count.index}-boot_disk.img"
}

# Virtual Machines

resource "libvirt_domain" "master" {
  count     = "${var.master["count"]}"
  name      = "${var.master["base_name"]}-${count.index}"
  memory    = "${var.master["memory"]}"
  vcpu      = "${var.master["vcpu"]}"
  cloudinit = "${element(libvirt_cloudinit_disk.master.*.id, count.index)}"

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  disk {
    volume_id = "${element(libvirt_volume.master.*.id, count.index)}"
  }

  network_interface {
    network_id     = "${libvirt_network.network.id}"
    wait_for_lease = true
  }
}

# Show vm ip address in the end
output "master_ips" {
  value = "${libvirt_domain.master.*.network_interface.0.addresses}"
}
