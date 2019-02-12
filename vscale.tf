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

data "template_file" "list_of_devs_instances" {
  count = "${length(var.devs)}"

  template = <<EOF
  "$${dns_name} $${ip_address} $${root_password}"
  EOF

  vars = {
    dns_name      = "${var.devs[count.index % length(var.devs)]}.devops.rebrain.srwx.net"
    ip_address    = "${vscale_scalet.web.*.public_address[count.index % length(var.devs)]}"
    root_password = "${random_string.password.*.result[count.index % length(var.devs)]}"
  }
}

output "list_of_devs_instances" {
  value = "${data.template_file.list_of_devs_instances.*.rendered}"
}

resource "local_file" "output_list" {
    content = "${join("\n", data.template_file.list_of_devs_instances.*.rendered)}"
    filename = "devs.txt"

}
