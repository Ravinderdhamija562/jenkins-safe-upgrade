variable "username" {
  type    = string
  default = "${env("USER")}"
}

variable "cloud_provider" {
  type    = string
  default = "gcp" # Change this to "gcp" if needed
}

locals {
  timestamp = formatdate("YYYYMMDD-HHmm", timestamp())
  iso_time = formatdate("EEEE MMMM D, YYYY 'at' hh:mm:ss ZZZ", timestamp())
  instance_name = "packer-ub1604-${local.timestamp}"
}

source "googlecompute" "ub1604" {
  disk_name               = "${local.instance_name}"
  disk_size               = 300
  disk_type               = "pd-ssd"
  image_description       = "Ubuntu 16.04 LTS Builder Image on ${local.iso_time}" # The description of the resulting image.
  image_family            = "ns-ub16" # The name of the image family to which the resulting image belongs.
  image_name              = "${local.instance_name}" #The unique name of the resulting image. Defaults to packer-{{timestamp}}
  image_storage_locations = ["us-west1"]
  labels = {
    department = "engineering-productivity"
    name       = "ns-builder"
    os_version = "ubuntu"
    release    = "1604"
    project    = "jenkins"
  }
  machine_type        = "e2-standard-8"
  network_project_id  = "ns-npe-shared-vpc"
  omit_external_ip    = true
  project_id          = "ns-cicd"
  source_image_family = "ub16-base" # The name of the source image family to use for the instance.
  ssh_username        = "${var.username}"
  startup_script_file = "startup.sh"
  subnetwork          = "shared-vpc-ns-usw1"
  tags                = ["allow-ssh"]
  use_iap             = true
  use_internal_ip     = true
  zone                = "us-west1-b"
  metadata = {
    "enable-oslogin" = "FALSE"
    "block-project-ssh-keys" = "TRUE"
  }
}

build {
  sources = ["source.googlecompute.ub1604"]

  // Iniital setup
  provisioner "shell" {
    pause_before = "1m0s"
    expect_disconnect = true
    inline       = [
      "sudo chmod 1777 /tmp",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade; [ -e /var/run/reboot-required ] && sudo reboot || true"
    ]
  }

  provisioner "file" {
    source      = "apt-packages.txt"
    destination = "/tmp/packages.txt"
  }

  provisioner "file" {
    source      = "requirements.txt"
    destination = "/tmp/requirements.txt"
  }
  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "provisioner_scripts/01-disk-partioning.sh",
      "provisioner_scripts/02-configure-apt-repos.sh",
      "provisioner_scripts/03-install-packages.sh",
      "provisioner_scripts/04-setup-pythonenv.sh",
      "provisioner_scripts/05-setup-nsadmin-user.sh",
      "provisioner_scripts/06-install-openjdk-17.sh",
      "provisioner_scripts/07-setup-conda.sh",
      "provisioner_scripts/08-install-jfrog-cli.sh",
      "provisioner_scripts/09-update-git-version.sh",
      "provisioner_scripts/10-setup-git.sh",
      "provisioner_scripts/11-install-custom-packages.sh"
    ]
  }
}
