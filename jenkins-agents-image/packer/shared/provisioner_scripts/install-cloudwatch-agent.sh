#!/bin/bash
color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Install cloudwatch agent${reset}"

# Create configuration file
cd /tmp
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

sudo mv /tmp/resources/cloudwatch/update_cw_config.sh /opt/aws/amazon-cloudwatch-agent/bin/update_cw_config.sh
chmod +x /opt/aws/amazon-cloudwatch-agent/bin/update_cw_config.sh

sudo mv /tmp/resources/cloudwatch/jenkins-cw-workspace-updater.service /etc/systemd/system/jenkins-cw-workspace-updater.service
sudo systemctl daemon-reload
sudo systemctl enable jenkins-cw-workspace-updater.service

#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Other cloudwatch metrics - https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html
# Cloud watch logs - sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
# sudo systemctl status amazon-cloudwatch-agent
# Cloudwatch agent configuration - cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json

# sudo systemctl status jenkins-cw-workspace-updater.service
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
# cat /var/log/jenkins-cw-workspace-job.log
# cat /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log