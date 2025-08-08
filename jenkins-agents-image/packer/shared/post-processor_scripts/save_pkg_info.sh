#!/bin/bash
set -e

# Input arguments
START_TIME_FILE="$1"
MANIFEST_FILE="$2"
PACKAGES_FILE="$3"
MANUAL_FILE="$4"
ENRICHED_MANIFEST_FILE="$MANIFEST_FILE"  

# Extract values
AMI_ID=$(jq -r '.builds[0].artifact_id' "$MANIFEST_FILE" | cut -d':' -f2)
REGION="us-east-1"

if [[ "$(uname)" == "Darwin" ]]; then
  BUILD_TIME=$(date -r $(jq -r '.builds[0].build_time' "$MANIFEST_FILE") '+%Y-%m-%d %H:%M:%S')
else
  BUILD_TIME=$(date -d @$(jq -r '.builds[0].build_time' "$MANIFEST_FILE") '+%Y-%m-%d %H:%M:%S')
fi

BUILDER_TYPE=$(jq -r '.builds[0].builder_type' "$MANIFEST_FILE")
INSTANCE_NAME=$(basename "$START_TIME_FILE" | sed 's/packer_start_time-//; s/.txt//')

# Fetch tags
aws ec2 describe-tags --filters Name=resource-id,Values="$AMI_ID" --region "$REGION" --output json > tags.json
TAGS=$(cat tags.json | jq '[.Tags[] | {(.Key): .Value}] | add')

# Read installed packages
DPKG_PACKAGES=$(jq -Rs -c 'split("\n") | map(select(length > 0))' "$PACKAGES_FILE")
MANUAL_TOOLS=$(jq -Rs -c 'split("\n") | map(select(length > 0))' "$MANUAL_FILE")

# Merge both into one list
ALL_PACKAGES=$(jq -n \
  --argjson dpkg "$DPKG_PACKAGES" \
  --argjson manual "$MANUAL_TOOLS" \
  '$dpkg + $manual'
)

# Calculate total time
END_TIME=$(date +%s)
START_TIME=$(cat "$START_TIME_FILE")
TOTAL_TIME=$((END_TIME - START_TIME))
TOTAL_TIME_MINUTES=$(echo "scale=2; $TOTAL_TIME / 60" | bc)

# If you want to include the log file name, you can derive it here or pass as an argument
LOG_FILE_NAME="${ENRICHED_MANIFEST_FILE%.json}.log"

# Build enriched manifest
jq -n \
  --arg ami_id "$AMI_ID" \
  --arg region "$REGION" \
  --arg instance "$INSTANCE_NAME" \
  --arg builder "$BUILDER_TYPE" \
  --arg build_time "$BUILD_TIME" \
  --arg build_log_file_name "$LOG_FILE_NAME" \
  --argjson total_time "$TOTAL_TIME" \
  --argjson total_time_minutes "$TOTAL_TIME_MINUTES" \
  --argjson packages "$ALL_PACKAGES" \
  --argjson tags "$TAGS" \
  '{
    ami_id: $ami_id,
    region: $region,
    instance_name: $instance,
    builder_type: $builder,
    build_time: $build_time,
    build_log_file_name: $build_log_file_name,
    total_time_seconds: $total_time,
    total_time_minutes: $total_time_minutes,
    tags: $tags,
    installed_packages: $packages
  }' > "$ENRICHED_MANIFEST_FILE"

# Clean up
rm -f tags.json || true