// -----------------------------
// Variables
// -----------------------------
variable "username" {
  type    = string
  default = "${env("USER")}"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "vpc_id" {
  type    = string
  default = "vpc-03d2bb0a568c9ede1"
}
variable "subnet_id" {
  type    = string
  default = "subnet-0698ba4c6752d7b3c"
}
variable "ubuntu_version" {
  type    = string
  default = 16.04
}

variable "company_tags" {
  type = map(string)
  default = {
    ep_team        = "ep"
    ep_project     = "jenkins"
    ep_environment = "non-prod"
  }
}
// -----------------------------
// Local Variables
// -----------------------------
locals {
  timestamp     = formatdate("YYYYMMDD-HHmm", timestamp())
  iso_time      = formatdate("EEEE MMMM D, YYYY 'at' hh:mm:ss ZZZ", timestamp())
  instance_name = "company-jenkins-ubuntu-packer-ub1604-${local.timestamp}"
}

// -----------------------------
// Source Configuration
// -----------------------------
source "amazon-ebs" "ubuntu_ut_ami" {
  region        = var.aws_region
  instance_type = var.instance_type

  source_ami_filter {
    filters = {
      name = "*company-jenkins-ubuntu-16.04-2025*"
    }
    most_recent = true
    owners      = ["156041411903"]
  }

  ami_name        = "company-jenkins-ubuntu-ut-${var.ubuntu_version}-${local.timestamp}"
  ami_description = "Ubuntu ${var.ubuntu_version} LTS Builder Image on ${local.iso_time} with base image ub16 base ami"
  vpc_id          = var.vpc_id
  subnet_id       = var.subnet_id
  ssh_timeout     = "10m"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 300
    volume_type           = "gp2"
    delete_on_termination = true
  }

  communicator = "ssh"
  ssh_username = "ubuntu"

  tags = {
    OS_Version                = "Ubuntu"
    Release                   = "xenial"
    Base_AMI_Name             = "{{ .SourceAMIName }}"
    Base_AMI_ID               = "{{ .SourceAMI }}"
    Name                      = "company-jenkins-ubuntu-xenial-16.04-ut-${local.timestamp}"
  }
}

// -----------------------------
// Build Configuration
// -----------------------------
build {
  sources = ["source.amazon-ebs.ubuntu_ut_ami"]

  provisioner "shell" {
    pause_before      = "1m0s"
    expect_disconnect = true

    inline = [
      // Wait for dpkg lock to be released
      "counter=1; max_retry=60", // Wait for a maximum of 5 minutes
      "while [ $counter -lt $max_retry ]; do",
      "  if sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; then",
      "    lock_pid=$(sudo fuser /var/lib/dpkg/lock-frontend)",
      "    echo $(ps aux | grep $lock_pid)",
      "    echo 'Waiting for lock on apt/dpkg...'; sleep 5",
      "  else",
      "    echo '*** The lock has been released'; break;",
      "  fi;",
      "  counter=$((counter + 1));",
      "done",
      "if [ $counter -ge $max_retry ]; then echo 'Error: dpkg lock not released'; exit 1; fi;",

      // Install coverage package
      "sudo -H pip3 install coverage",

      // Update and install required packages
      "sudo apt-get update -y || { echo 'apt-get update failed'; exit 1; }",
      "sudo apt install nfs-common -y",

      // Create and mount NFS share
      "sudo mkdir -p /var/www/html",
      "sudo chmod 777 -R /var/www/html",
      ]
  }
}
