resource "aws_instance" "master" {
    ami = var.ami
    instance_type = var.instance
    key_name = "ssh-key"
    tags = {
        Name = "master"
    }

    provisioner "remote-exec" {
        inline = ["echo 'Master SSH is Up!'"]
        connection {
            type = "ssh"
            user = var.ssh_user
            host = self.public_ip 
            private_key = file(var.ssh_private_key)
        }
    }
    # provisioner "local-exec" {
    #     command = "echo 'Master is provisoned!'"
    # }

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

    provisioner "remote-exec" {
        inline = ["echo 'Node${count.index} SSH is Up!'"]
        connection {
            type = "ssh"
            user = var.ssh_user
            # host = aws_instance.node[*].public_ip
            host = self.public_ip
            private_key = file(var.ssh_private_key)
        }
    }

    # provisioner "local-exec" {
    #     command = "echo 'Node${count.index} - IP ${self.public_ip} - is provisoned!'"
    # }
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

    egress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

locals {
  kube_hosts = {
      master = aws_instance.master.public_ip, 
      nodes = aws_instance.node[*].public_ip
  }
}

resource "null_resource" "cluster-provision" {
    depends_on = [aws_instance.master, aws_instance.node]

    provisioner "local-exec" {
        command = "echo '${templatefile("${path.module}/inventory.tmpl", local.kube_hosts)}' > ${path.module}/inventory.yml"
    }
    # provisioner "local-exec" {
    #     command = "echo 'Cluster created!'"
    # }
}
