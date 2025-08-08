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
  default = "m5a.xlarge"
}

variable "skip_create_ami" {
  type    = bool
  default = false
}

variable "source_ami" {
  type    = string
  default = "ami-055744c75048d8296"
}

variable "vpc_id" {
  type    = string
  default = "vpc-03d2bb0a568c9ede1"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0698ba4c6752d7b3c"
}

variable "volume_size" {
  type    = number
  default = 50
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_timeout" {
  type    = string
  default = "10m"
}

variable "ami_name_prefix" {
  type    = string
  default = "company-jenkins-ubuntu-18.04"
}

variable "ami_description_prefix" {
  type    = string
  default = "Ubuntu 18.04 LTS Builder Image"
}

variable "device_name" {
  type    = string
  default = "/dev/sda1"
}

variable "communicator" {
  type    = string
  default = "ssh"
}

variable "delete_on_termination" {
  type    = bool
  default = true
}

variable "company_tags" {
  type = map(string)
  default = {
    "team"        = "ep"
  }
}

variable "manifest_file" {
  type    = string
  default = ""
}

variable "timestamp" {
  type    = string
  default = ""
}

locals {
  timestamp                  = var.timestamp
  iso_time                   = formatdate("EEEE MMMM D, YYYY 'at' hh:mm:ss ZZZ", timestamp())
  instance_name              = "${var.ami_name_prefix}-${local.timestamp}"
  shared_scripts_path        = "${path.root}/../../shared/provisioner_scripts"
  shared_post_processor_path = "${path.root}/../../shared/post-processor_scripts"
  shared_resources_path      = "${path.root}/../../shared/resources"
  local_pkg_info_path        = "${path.root}/pkg_info-${local.instance_name}"
  server_pkg_info_path       = "/tmp/pkg_info"
}

source "amazon-ebs" "ubuntu_ami" {
  skip_create_ami = var.skip_create_ami
  region          = var.aws_region
  instance_type   = var.instance_type
  source_ami      = var.source_ami
  ami_name        = "${var.ami_name_prefix}-${local.timestamp}"
  ami_description = "${var.ami_description_prefix} on ${local.iso_time} with base image: ${var.source_ami}"
  vpc_id          = var.vpc_id
  subnet_id       = var.subnet_id
  ssh_timeout     = var.ssh_timeout
  launch_block_device_mappings {
    device_name           = var.device_name
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = var.delete_on_termination
  }
  communicator = var.communicator
  ssh_username = var.ssh_username
  tags = merge(
    {
      OS_Version    = "Ubuntu"
      Release       = "Bionic"
      Base_AMI_Name = "{{ .SourceAMIName }}"
      Base_AMI_ID   = "{{ .SourceAMI }}"
      Name          = "company-jenkins-ubuntu-18.04-${local.timestamp}"
    },
    var.company_tags
  )
}

build {
  sources = ["source.amazon-ebs.ubuntu_ami"]
  provisioner "shell-local" {
    inline = [
      "mkdir -p ${local.local_pkg_info_path}",
    ]
  }

  provisioner "shell" {
    pause_before      = "30s"
    expect_disconnect = true
    inline = [
      "echo \"$(date +%s)\" > /var/tmp/packer_start_time.txt",
      "echo 'Running apt-get update and upgrade'",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade; [ -e /var/run/reboot-required ] && sudo reboot || true"
    ]
  }

  provisioner "file" {
    direction   = "download"
    source      = "/var/tmp/packer_start_time.txt"
    destination = "${local.local_pkg_info_path}/packer_start_time.txt"
  }
  provisioner "file" {
    source      = "apt-packages.txt"
    destination = "/tmp/apt-packages.txt"
  }

  provisioner "file" {
    source      = "${local.shared_resources_path}"
    destination = "/tmp/"
  }

  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "${local.shared_scripts_path}/configure_repo.sh",
      "${local.shared_scripts_path}/install-packages.sh",
      "provisioner_scripts/00-perl_setup.sh",
      "${local.shared_scripts_path}/setup-nsadmin-user.sh",
      "${local.shared_scripts_path}/setup-nsadmin-sudo.sh",
      "${local.shared_scripts_path}/setup-nsadmin-keys.sh",
      "${local.shared_scripts_path}/update-git-version.sh",
      "${local.shared_scripts_path}/install-jfrog-cli.sh",
      "${local.shared_scripts_path}/install-openjdk-17.sh",
      "${local.shared_scripts_path}/install-cloudwatch-agent.sh",
      "${local.shared_scripts_path}/generate-installed-packages.sh"
    ]
  }

  provisioner "file" {
    direction   = "download"
    source      = "${local.server_pkg_info_path}/installed-packages.txt"
    destination = "${local.local_pkg_info_path}/installed-packages.txt"
  }

  provisioner "file" {
    direction   = "download"
    source      = "${local.server_pkg_info_path}/manual-installed.txt"
    destination = "${local.local_pkg_info_path}/manual-installed.txt"
  }

  post-processor "manifest" {
  output     = "${var.manifest_file}"
  strip_path = true
}
}