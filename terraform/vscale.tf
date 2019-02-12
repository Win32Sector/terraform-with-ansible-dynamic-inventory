provider "vscale" {
  token = "${file(var.vscale_token)}"
}

# Create a web server
resource "vscale_scalet" "web" {
  count     = "${length(var.devs)}"
  location  = "${var.location}"
  make_from = "${var.make_from}"
  name      = "${var.devs[count.index]}"
  rplan     = "${var.rplan}"
  ssh_keys  = ["${vscale_ssh_key.kozlovkey1.id}"]

  provisioner "remote-exec" {
    inline = [
      "echo ${var.user}:${random_string.password.result} | chpasswd",
      "hostnamectl set-hostname ${var.devs[count.index]}",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("~/.ssh/appuser")}"
    }
  }
}

resource "random_string" "password" {
  count   = "${length(var.devs)}"
  length  = 16
  special = false
}

resource "vscale_ssh_key" "kozlovkey1" {
  name = "kozlovkey1"
  key  = "${file(var.vscale_sshkey)}"
}

data "template_file" "inventory" {
  count = "${length(var.devs)}"

  template = "${file("inventory.tpl")}"

  vars = {
    dns_name = "${var.devs[count.index % length(var.devs)]}.devops.rebrain.srwx.net"
    user     = "${var.user}"
    key_path = "${var.vscale_privatesshkey}"
  }
}

resource "null_resource" "update_inventory" {
  triggers {
    template = "${data.template_file.inventory.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ../ansible/inventory"
  }
}

resource "null_resource" "playbook_execute" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory ../ansible/playbook.yml"
  }
}
