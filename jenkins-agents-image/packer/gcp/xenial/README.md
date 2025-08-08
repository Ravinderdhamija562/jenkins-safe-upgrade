# Ubuntu 16.04.7 jenkins runner

It contains files to build UB16 agents for Jenkins for GCP

## Pre-requisite

For GCP, **gcloud** cli tool configured to access **ns-cicd** project.

## Build Image

```bash
packer init .pkr.hcl
packer build -on-error=ask gcp-builder.pkr.hcl
```

The above command if run successfully, would create a new compute image with prefix `packer-ub1604` under [ns-cicd](<https://console.cloud.google.com/compute/images?project=ns-cicd&pageState=(%22images%22:(%22f%22:%22%255B%257B_22k_22_3A_22Name_22_2C_22t_22_3A10_2C_22v_22_3A_22_5C_22packer-ub2004_5C_22_22_2C_22i_22_3A_22name_22%257D%255D%22))>) project in GCP.

