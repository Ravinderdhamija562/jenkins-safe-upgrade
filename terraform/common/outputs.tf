
output "log_group_arns" {
  value = { for name, lg in aws_cloudwatch_log_group.log_groups : name => lg.arn }
}