provider "vscale" {
  token = "${file(var.vscale_token)}"
}

# Create a web server
resource "vscale_scalet" "web" {
  location  = "${var.location}"
  make_from = "${var.make_from}"
  name      = "${var.name}"
  rplan     = "${var.rplan}"
  ssh_keys  = ["${vscale_ssh_key.kozlovkey1.id}"]

  provisioner "remote-exec" {
    inline = [
      "echo ${var.user}:`openssl rand -base64 9` | chpasswd",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("~/.ssh/appuser")}"
    }
  }
}

resource "vscale_ssh_key" "kozlovkey1" {
  name = "kozlovkey1"
  key  = "${file(var.vscale_sshkey)}"
}
