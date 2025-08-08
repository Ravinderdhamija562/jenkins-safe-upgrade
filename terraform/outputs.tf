output "jenkins_ec2_plugin_iam_role_arn" {
  description = "The ARN of the IAM role for jenkins ec2 plugin"
  value       = aws_iam_role.jenkins_eks_role.arn
}

output "jenkins_agent_sg_id" {
  description = "The ID of the Jenkins agent security group"
  value       = aws_security_group.jenkins_agent_sg.id
}

output "jenkins_agent_role_arn" {
  description = "The ARN of the Jenkins agent role"
  value       = aws_iam_role.jenkins_agent_role.arn
}

output "jenkins_agent_iam_profile_arn" {
  description = "The ARN of the Jenkins agent IAM profile"
  value       = aws_iam_instance_profile.jenkins_agent_instance_profile.arn
}