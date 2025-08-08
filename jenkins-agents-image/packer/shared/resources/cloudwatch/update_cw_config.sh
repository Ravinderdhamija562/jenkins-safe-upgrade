#!/bin/bash
set -euo pipefail

CLOUDWATCH_CONFIG_FILE="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent-ssm.json"
CLOUDWATCH_AGENT_CTL="/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl"
LOG_FILE="/var/log/jenkins-update-cw-config-job.log" # Dedicated log for this script
CLOUDWATCH_CONFIG_SSM="/jenkins/agents/ubuntu/cloudwatch"
AWS_REGION="us-east-1"

# Ensure log file exists and redirect all output
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"
exec >> "$LOG_FILE" 2>&1

echo "--- CloudWatch Config Update from Workspace Script Started at $(date) ---"

echo "Fetch configuration file from SSM Parameter Store"

aws ssm get-parameter \
  --name "$CLOUDWATCH_CONFIG_SSM" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region "$AWS_REGION" > "$CLOUDWATCH_CONFIG_FILE"

echo "CloudWatch Agent configuration from SSM:"
cat "$CLOUDWATCH_CONFIG_FILE"

# ---  Discover Job Name from Workspace ---
JENKINS_WORKSPACE_BASE="/home/nsadmin/workspace"
inferred_job_name="unknown_job" # Default if no job found

echo "Searching for job workspace under: $JENKINS_WORKSPACE_BASE"

found_workspace_dir=$(ls -d "${JENKINS_WORKSPACE_BASE}/"* 2>/dev/null | grep -v '@tmp' | head -1)

if [ -n "$found_workspace_dir" ]; then
    # 1. Extract just the directory name (e.g., "MyJob" or "MyFolder_MyJob")
    raw_dir_name=$(basename "$found_workspace_dir")

    # Remove any "@<number>" suffixes (for pipeline concurrent builds)
    clean_dir_name=$(echo "$raw_dir_name" | sed -E 's/@[0-9]+$//')

    inferred_job_name="$clean_dir_name"
    echo "Found workspace directory: $found_workspace_dir"
    echo "Inferred Jenkins Job Name: $inferred_job_name"
else
    echo "No suitable workspace directory found under $JENKINS_WORKSPACE_BASE. Using default 'unknown_job'."
fi

# ---2. Modify CloudWatch Agent Configuration ---
echo "Attempting to update CloudWatch config with job name: $inferred_job_name"

# Add/update 'JenkinsJobName' dimension within 'metrics.append_dimensions'
echo "Setting JenkinsJobName dimension to: $inferred_job_name"

jq --arg job_name "$inferred_job_name" '
  .metrics.metrics_collected |= (
    # Iterate over each top-level key (e.g., "cpu", "mem") in metrics_collected
    map_values(
      # Ensure append_dimensions exists for each, then add/update JenkinsJobName
      . + {append_dimensions: (.append_dimensions // {} | . + {"JenkinsJobName": $job_name})}
    )
  )
' "$CLOUDWATCH_CONFIG_FILE" > temp_cw_config.json && mv temp_cw_config.json "$CLOUDWATCH_CONFIG_FILE"


echo "Updated CloudWatch Agent configuration file at: $CLOUDWATCH_CONFIG_FILE"
cat "$CLOUDWATCH_CONFIG_FILE"

# --- 3. Restart CloudWatch Agent ---
echo "Restarting CloudWatch Agent to apply new configuration."

if sudo "$CLOUDWATCH_AGENT_CTL" -a fetch-config -m ec2 -c file:"$CLOUDWATCH_CONFIG_FILE" -s; then
    echo "CloudWatch Agent configuration updated and restarted successfully."
else
    echo "ERROR: CloudWatch Agent failed to restart! Check agent logs for details."
    exit 1
fi

echo "--- CloudWatch Config Update from Workspace Script Finished at $(date) ---"
exit 0