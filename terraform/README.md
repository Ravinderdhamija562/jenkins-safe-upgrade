# Terraform configuration

## Directory Structure

The `terraform` directory contains the following structure:

```bash
terraform/
├── envs/            # Jenkins-specific configurations
├── backend_configs/ # Backend configuration files for remote state
├── variables.tf
├── versions.tf
├── backend.tf
├── main.tf
├── outputs.tf
└── providers.tf
└── terraform.tfvars # Common terraform variables across all jenkins
└── README.md
```

## Usage

1. Navigate to the terraform directory.
2. Initialize Terraform with the environment-specific backend configuration

  ```bash
  ./tf-init.sh <ENV> # ENV can be one of the [beta,feture,main,test]
  ```

3. Plan the infrastructure changes using the environment-specific variable file

  ```bash
  ./tf-plan.sh <ENV>
  ```

4. Apply the changes

  ```bash
  ./tf-apply.sh <ENV>
  ```

## Prerequisites

- Ensure that Terraform is installed on your system. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).
- Export the variables `TF_VAR_access_key`, `TF_VAR_secret_key`, `TF_VAR_token`.

## Notes

- Use the appropriate `<desired_jenkins>` value to target the correct environment.
- Review the plan output carefully before applying changes to avoid unintended modifications to the infrastructure.