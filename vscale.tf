provider "vscale" {
  token = "${file(var.vscale_token)}"
}

# Create a web server
resource "vscale_scalet" "web" {
  location  = "msk0"
  make_from = "ubuntu_14.04_64_002_master"
  name      = "kozlovpavel"
  rplan     = "small"
  ssh_keys  = ["${vscale_ssh_key.kozlovkey1.id}"]

  provisioner "remote-exec" {
    inline = [
      "echo ${var.user}:${file(var.password)} | chpasswd",
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
