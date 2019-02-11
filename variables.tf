variable "vscale_sshkey" {
  default = "~/.ssh/appuser.pub"
}

variable "vscale_token" {
  default = "vscale_token"
}

variable "aws_access_key" {
  description = "Path to access key"
  default     = "aws_access_key"
}

variable "aws_secret_key" {
  description = "Path to secret key"
  default     = "aws_secret_key"
}

variable "user" {
  default = "root"
}

variable "password" {
  default = "password"
}

variable "location" {
  default = "msk0"
}

variable "make_from" {
  default = "ubuntu_14.04_64_002_master"
}

variable "name" {
  default = "kozlovpavel"
}

variable "rplan" {
  default = "small"
}

variable "devs" {
  type    = "list"
  default = ["dev1.sovvvest", "dev2.sovvvest"]
}
