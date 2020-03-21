variable "ami" {
  type = string
}

variable "instance" {
  type = string
}

variable "nodes" {
  type = number
}

variable "ssh_public_key" {
  type = string
  description = "O caminho da chave ssh"
}

variable "ssh_private_key" {
  type = string
  description = "O caminho da chave privada ssh"
}

variable "ssh_user" {
  type = string
  description = "O caminho da chave ssh"
}

variable "ext_sg_ids" {
  type = list
  description = "External security groups identifiers"
  default = []
}