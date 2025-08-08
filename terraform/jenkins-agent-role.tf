resource "aws_iam_role" "jenkins_agent_role" {
  name                 = "npe-cisystem-${var.env}-jenkins-agent-role"
  description          = "Role for Jenkins agent to assume"
  path                 = var.role_path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": [
        "sts:TagSession",
        "sts:AssumeRole"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "jenkins_agent_cloudwatch_policy" {
  name   = "npe-cisystem-${var.env}-jenkins-agent-cloudWatch-policy"
  role   = aws_iam_role.jenkins_agent_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.cloudwatch_role_actions
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_agent_instance_profile" {
  name = "npe-cisystem-${var.env}-jenkins-agent-instance-profile"
  path = "/application_role/"
  role = aws_iam_role.jenkins_agent_role.name
}