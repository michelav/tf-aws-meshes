resource "aws_instance" "master" {
    ami = var.ami
    instance_type = var.instance
    key_name = "ssh-key"
    tags = {
        Name = "master"
    }

    vpc_security_group_ids = concat([aws_security_group.global.id], var.ext_sg_ids)
}

resource "aws_instance" "node" {
    count = var.nodes
    ami = var.ami
    instance_type = var.instance
    key_name = "ssh-key"
    tags = {
        Name = "node${count.index}"
    }

    vpc_security_group_ids = concat([aws_security_group.global.id], var.ext_sg_ids)
}

resource "aws_key_pair" "auth" {
    key_name   = "ssh-key"
    public_key = file(var.ssh_public_key)
}

resource "aws_security_group" "global" {
    name = "global-sec-group"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
