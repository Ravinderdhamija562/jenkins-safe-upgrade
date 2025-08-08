resource "aws_cloudwatch_log_group" "log_groups" {
  for_each = toset(var.jenkins_agents_cloudwatch_loggroups_names)

  name              = each.key
  retention_in_days = var.jenkins_agent_cloudwatch_loggroups_retention
  tags = {
    Name                      = each.key
    terraform                 = true
    "terraform.directory"     = "https://github.com/company/<repo>/tree/develop/Jenkins/terraform/common"
  }
}