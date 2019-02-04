# Cloud init templates

data "template_file" "user_data_worker" {
  count    = "${var.worker["count"]}"
  template = "${file("${path.module}/cloud_init.cfg")}"

  vars {
    hostname = "${var.worker["base_name"]}-${count.index}"
  }
}

resource "libvirt_cloudinit_disk" "worker" {
  count     = "${var.worker["count"]}"
  pool      = "vm_images"
  name      = "${var.worker["base_name"]}-${count.index}-cloud_init.iso"
  user_data = "${element(data.template_file.user_data_worker.*.rendered, count.index)}"
}

# Root disk for each instance

resource "libvirt_volume" "worker" {
  count            = "${var.worker["count"]}"
  pool             = "vm_images"
  base_volume_name = "bionic.img"
  base_volume_pool = "isos"
  size             = "${var.worker["disksize"]}"
  name             = "${var.worker["base_name"]}-${count.index}-boot_disk.img"
}

# Virtual Machines

resource "libvirt_domain" "worker" {
  count     = "${var.worker["count"]}"
  name      = "${var.worker["base_name"]}-${count.index}"
  memory    = "${var.worker["memory"]}"
  vcpu      = "${var.worker["vcpu"]}"
  cloudinit = "${element(libvirt_cloudinit_disk.worker.*.id, count.index)}"

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  disk {
    volume_id = "${element(libvirt_volume.worker.*.id, count.index)}"
  }

  network_interface {
    network_id     = "${libvirt_network.network.id}"
    wait_for_lease = true
  }
}

# Show vm ip address in the end
output "worker_ips" {
  value = "${libvirt_domain.worker.*.network_interface.0.addresses}"
}
