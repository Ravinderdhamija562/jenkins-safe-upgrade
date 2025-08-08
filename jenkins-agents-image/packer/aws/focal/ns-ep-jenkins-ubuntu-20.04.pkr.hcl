variable "username" {
  type    = string
  default = "${env("USER")}"
}

variable "aws_region" {
  default = "us-east-1" # N. Virginia i.e. default region for ns-aws-nonprod account
}

variable "instance_type" {
  default = "m5a.xlarge"
}

variable "source_ami" {
  default = "ami-014f7ab33242ea43c" # ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20250111
}

variable "github_token" {
  type    = string
  default = ""
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
  instance_name              = "company-jenkins-ubuntu-20.04-${local.timestamp}"
  shared_scripts_path        = "${path.root}/../../shared/provisioner_scripts"
  shared_post_processor_path = "${path.root}/../../shared/post-processor_scripts"
  shared_resources_path      = "${path.root}/../../shared/resources"
  local_pkg_info_path        = "${path.root}/pkg_info-${local.instance_name}"
  server_pkg_info_path       = "/tmp/pkg_info"
}

source "amazon-ebs" "ubuntu_ami" {
  skip_create_ami = false          # If true, the AMI will not be created
  region          = var.aws_region #The name of the region to launch the instance in
  instance_type   = var.instance_type
  source_ami      = var.source_ami
  ami_name        = "company-jenkins-ubuntu-20.04-${local.timestamp}"                                          # The name of the resulting AMI
  ami_description = "Ubuntu 20.04 LTS Builder Image on ${local.iso_time} with base image: ${var.source_ami}" # The description of the resulting AMI
  vpc_id          = "vpc-03d2bb0a568c9ede1"                                                                  # only vpc present in N. Virginia region for ns-nonprod-ep-cicd aws account
  subnet_id       = "subnet-0698ba4c6752d7b3c"                                                               # Private subnet,Outbound to internet in N. Virginia region for ns-nonprod-ep-cicd aws account
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 300
    volume_type           = "gp2"
    delete_on_termination = true
  }
  communicator = "ssh"
  ssh_username = "ubuntu"
  tags = merge(
    {
      OS_Version    = "Ubuntu"
      Release       = "focal"
      Base_AMI_Name = "{{ .SourceAMIName }}"
      Base_AMI_ID   = "{{ .SourceAMI }}"
      Name          = "company-jenkins-ubuntu-20.04-${local.timestamp}"
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
      "echo \"$(/bin/date +%s)\" > /var/tmp/packer_start_time.txt",
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

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sshpass python3.8 python3.8-dev python3-pip git default-jre virtualenv jq",
      "sudo ln -s /usr/bin/python3.8 /usr/bin/python"
    ]
  }

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "echo cloning company service repo",
      "git clone --no-checkout --filter=blob:none https://${var.github_token}@github.com/company/service.git",
      "cd service",
      "git sparse-checkout init --cone",
      "git sparse-checkout set builder",
      "git checkout develop",
      "export NS_BUILD_DIR=$${PWD}",
      "DEBIAN_FRONTEND=noninteractive builder/run-devx-role-2004 --role jenkins_build_bot --inventory ./builder/ansible/jenkins_build_bot.ini",
      "sudo apt-get remove -y unattended-upgrades",
      "sudo apt-get -y autoremove && sudo apt-get -y autoclean && sudo apt-get -y clean",
      "sudo -u nsadmin -H git config --global url.'https://github.com/'.insteadOf 'git@github.com:'",
      "sudo -H pip config set --global global.index-url 'https://artifactory-rd.company.io/artifactory/api/pypi/company-py38/simple'",
      "sudo -H pip config set --global global.timeout 180",
      "cd && sudo rm -rf ~/.git-credentials ~/.dev-ansible-venv service"
    ]
  }

  provisioner "file" {
    source      = "${local.shared_resources_path}"
    destination = "/tmp/"
  }

  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "${local.shared_scripts_path}/setup-nsadmin-keys.sh",
      "${local.shared_scripts_path}/setup-nsadmin-sudo.sh",
      "provisioner_scripts/03-setup-nsadmin-shell.sh",
      "${local.shared_scripts_path}/install-jfrog-cli.sh",
      "${local.shared_scripts_path}/install-cloudwatch-agent.sh",
      "${local.shared_scripts_path}/generate-installed-packages.sh",
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
