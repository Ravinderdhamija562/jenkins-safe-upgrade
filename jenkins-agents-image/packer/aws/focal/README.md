# Ubuntu 20.04 jenkins runner

It contains files to build UB20 agents for Jenkins for AWS

## How to build

### Pre-requisite

Install **packer** on mac

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

### Build the image

1. Export the AWS credentials

```bash
export AWS_ACCESS_KEY_ID="********"
export AWS_SECRET_ACCESS_KEY="********"
export AWS_SESSION_TOKEN="********"
```

3. Build image

```bash
cd <current directory>
packer init .pkr.hcl
# Use one of the below
packer build --debug -var "github_token=<github_token> "ub20-template.pkr.hcl # It will prompt you to continue after each step,also it will save initial keys on the system
packer build --on-error=ask -var "github_token=<github_token> "ub20-template.pkr.hcl # It will prompt what to do in case of error
```