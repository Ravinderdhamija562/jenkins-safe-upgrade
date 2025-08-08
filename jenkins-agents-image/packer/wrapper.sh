#!/bin/bash
set -e

usage() {
    echo "Usage: $0 <packer_script.pkr.hcl>"
    exit 1
}

if [[ $# -ne 1 ]]; then
    usage
fi

PACKER_SCRIPT="$1"
MANIFEST_BUCKET="ns-cicd-packer/ep-packer/packer-manifest"

if [[ ! -f "$PACKER_SCRIPT" ]]; then
    echo "Error: File '$PACKER_SCRIPT' not found!"
    exit 1
fi

SCRIPT_DIR=$(dirname "$PACKER_SCRIPT")
SCRIPT_BASENAME=$(basename "$PACKER_SCRIPT" .pkr.hcl)
TIMESTAMP=$(date +"%Y%m%d-%H%M")
BASE_NAME="${SCRIPT_BASENAME}-${TIMESTAMP}"

MANIFEST_FILE="${BASE_NAME}.json"
LOG_FILE="${BASE_NAME}.log"

pushd "$SCRIPT_DIR" > /dev/null

# Initialize Packer with the configuration file
if [[ ! -f ".pkr.hcl" ]]; then
    echo "Error: .pkr.hcl file not found in $SCRIPT_DIR."
    exit 1
fi

packer init .pkr.hcl
if [[ $? -ne 0 ]]; then
    echo "Packer initialization failed."
    exit 1
fi


# Run packer build, pass manifest/log file names as variables, tee output to log
if [[ "$SCRIPT_BASENAME" == "company-jenkins-ubuntu-20.04" ]]; then
    packer build -var "manifest_file=${MANIFEST_FILE}" -var "timestamp=${TIMESTAMP}" -var "github_token=${GITHUB_TOKEN}" "$SCRIPT_BASENAME.pkr.hcl" | tee "$LOG_FILE"
else
    packer build -var "manifest_file=${MANIFEST_FILE}" -var "timestamp=${TIMESTAMP}" "$SCRIPT_BASENAME.pkr.hcl" | tee "$LOG_FILE"
fi

# Call save_pkg_info.sh with consistent manifest file name
bash ../../shared/post-processor_scripts/save_pkg_info.sh \
    "pkg_info-${BASE_NAME}/packer_start_time.txt" \
    "${MANIFEST_FILE}" \
    "pkg_info-${BASE_NAME}/installed-packages.txt" \
    "pkg_info-${BASE_NAME}/manual-installed.txt"

# Upload both files to S3
aws s3 cp "$LOG_FILE" "s3://$MANIFEST_BUCKET/$LOG_FILE"
aws s3 cp "$MANIFEST_FILE" "s3://$MANIFEST_BUCKET/$MANIFEST_FILE"

popd > /dev/null

echo "Build log uploaded to s3://$MANIFEST_BUCKET/$LOG_FILE"
echo "Manifest uploaded to s3://$MANIFEST_BUCKET/$MANIFEST_FILE"