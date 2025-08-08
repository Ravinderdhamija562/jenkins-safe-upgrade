resource "aws_iam_role" "jenkins_eks_role" {
  name                 = "npe-cisystem-${var.env}-jenkins-agent-launcher"
  path                 = var.role_path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
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

resource "aws_iam_role_policy" "jenkins_ec2_policy" {
  name   = "npe-cisystem-${var.env}-jenkins-agent-launcher-policy"
  role   = aws_iam_role.jenkins_eks_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.ec2_actions
        Resource = "*"
      }
    ]
  })
}
