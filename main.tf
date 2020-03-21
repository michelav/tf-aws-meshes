provider "aws" {
    version = "~> 2.22"
    region = "sa-east-1"
}

module "k8s-cluster" {
  source = "./modules/tf-aws-k8s"
  ami = "ami-02a3447be1ec3a38f"
  instance = "t2.micro"
  nodes = 2
  ssh_user = "ubuntu"
  ssh_public_key = "~/devel/keys/k8s-cluster.pub"
  ssh_private_key = "~/devel/keys/k8s-cluster"
  ext_sg_ids = [aws_security_group.k8s-sg.id]
}

resource "aws_security_group" "k8s-sg" {
    name = "k8s-sec-group"
    
    ingress {
        # TLS (change to whatever ports you need)
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        # Please restrict your ingress to only necessary IPs and ports.
        # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}